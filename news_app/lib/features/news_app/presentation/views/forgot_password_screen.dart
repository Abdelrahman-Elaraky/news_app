import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeySecurity = GlobalKey<FormState>();
  final _formKeyReset = GlobalKey<FormState>();

  String? _emailInput;
  String? _selectedQuestion;
  String? _answerInput;
  String? _newPassword;

  bool _emailValidated = false;
  bool _answerVerified = false;
  bool _passwordReset = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  late String? _savedEmail;
  late String? _savedQuestion;
  late String? _savedAnswer;

  final List<String> _securityQuestions = [
    "What’s your mother’s maiden name?",
    "What was the name of your first pet?",
    "In what city were you born?",
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedEmail = prefs.getString('registeredEmail');
      _savedQuestion = prefs.getString('securityQuestion');
      _savedAnswer = prefs.getString('securityAnswer');
    });
  }

  Future<void> _validateEmail() async {
    final form = _formKeyEmail.currentState!;
    if (form.validate()) {
      form.save();

      setState(() => _isLoading = true);

      await Future.delayed(const Duration(milliseconds: 500));

      final valid = (_emailInput?.trim().toLowerCase() == _savedEmail?.toLowerCase());

      setState(() {
        _isLoading = false;
        _emailValidated = valid;
      });

      if (!valid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not found')),
        );
      }
    }
  }

  Future<void> _verifySecurityAnswer() async {
    final form = _formKeySecurity.currentState!;
    if (form.validate()) {
      form.save();

      if (_selectedQuestion == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your security question')),
        );
        return;
      }

      setState(() => _isLoading = true);

      await Future.delayed(const Duration(milliseconds: 500));

      final answerMatches = _savedAnswer != null &&
          _answerInput != null &&
          _answerInput!.trim().toLowerCase() == _savedAnswer;

      final questionMatches = _selectedQuestion == _savedQuestion;

      setState(() {
        _isLoading = false;
        _answerVerified = (answerMatches && questionMatches);
      });

      if (_answerVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification successful! You can reset your password now.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect security question or answer')),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    final form = _formKeyReset.currentState!;
    if (form.validate()) {
      form.save();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registeredPassword', _newPassword!.trim());

      setState(() => _passwordReset = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : !_emailValidated
                ? Form(
                    key: _formKeyEmail,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Enter your registered email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                          onSaved: (val) => _emailInput = val?.trim(),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _validateEmail,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  )
                : !_answerVerified
                    ? Form(
                        key: _formKeySecurity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Security Question'),
                              value: _selectedQuestion,
                              items: _securityQuestions
                                  .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedQuestion = val),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Please select your security question'
                                  : null,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Answer'),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Answer is required';
                                }
                                return null;
                              },
                              onSaved: (val) => _answerInput = val?.trim(),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _verifySecurityAnswer,
                              child: const Text('Verify'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _emailValidated = false;
                                  _answerVerified = false;
                                  _selectedQuestion = null;
                                  _answerInput = null;
                                  _emailInput = null;
                                });
                              },
                              child: const Text('Back'),
                            )
                          ],
                        ),
                      )
                    : !_passwordReset
                        ? Form(
                            key: _formKeyReset,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Enter your new password',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'New Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (val.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  onSaved: (val) => _newPassword = val?.trim(),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _resetPassword,
                                  child: const Text('Reset Password'),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 80),
                                const SizedBox(height: 20),
                                const Text('Password has been reset successfully.'),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed('/login');
                                  },
                                  child: const Text('Back to Login'),
                                )
                              ],
                            ),
                          ),
      ),
    );
  }
}
