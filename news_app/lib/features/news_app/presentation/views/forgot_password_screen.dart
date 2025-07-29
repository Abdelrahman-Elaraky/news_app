import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _selectedQuestion;
  String? _answer;
  bool _emailValidated = false;
  bool _answerVerified = false;
  bool _isLoading = false;

  final List<String> _securityQuestions = [
    "What's your mother's maiden name?",
    "What was your first pet's name?",
    "What city were you born in?",
  ];

  Future<bool> _validateEmailExists(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('registeredEmail');
    return email.trim() == savedEmail;
  }

  Future<bool> _verifyAnswer(String email, String question, String answer) async {
    // Replace this with actual security question verification logic
    await Future.delayed(const Duration(seconds: 1));
    return answer.trim().toLowerCase() == 'flutter';
  }

  void _submitEmail() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      final exists = await _validateEmailExists(_email!.trim());

      setState(() {
        _isLoading = false;
        _emailValidated = exists;
      });

      if (!exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not found')),
        );
      }
    }
  }

  void _submitAnswer() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedQuestion == null || _answer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a question and provide an answer')),
        );
        return;
      }

      setState(() => _isLoading = true);

      final verified = await _verifyAnswer(_email!, _selectedQuestion!, _answer!);

      setState(() {
        _isLoading = false;
        _answerVerified = verified;
      });

      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Answer verified! You can reset your password now.')),
        );
        // Navigate or reset password logic here
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect answer')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _emailValidated
                ? _answerVerified
                    ? const Center(child: Text('Password reset successful!'))
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Security Question'),
                              items: _securityQuestions
                                  .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                                  .toList(),
                              value: _selectedQuestion,
                              onChanged: (val) => setState(() => _selectedQuestion = val),
                              validator: (val) =>
                                  val == null || val.isEmpty ? 'Please select a question' : null,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Answer'),
                              onSaved: (val) => _answer = val?.trim(),
                              validator: (val) =>
                                  val == null || val.isEmpty ? 'Answer is required' : null,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _submitAnswer,
                              child: const Text('Verify'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Back to login'),
                            ),
                          ],
                        ),
                      )
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Your email address'),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (val) => _email = val?.trim(),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(val.trim())) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _submitEmail,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
