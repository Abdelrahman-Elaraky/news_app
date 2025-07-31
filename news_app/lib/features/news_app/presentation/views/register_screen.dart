import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/validation_utils.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/password_form_field.dart';
import '../widgets/date_picker_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formData = <String, dynamic>{
    'firstName': '',
    'lastName': '',
    'email': '',
    'phoneNumber': '',
    'dateOfBirth': '',
    'password': '',
    'confirmPassword': '',
    'securityQuestion': '',
    'securityAnswer': '',
    'termsAccepted': false,
  };

  final List<String> _securityQuestions = [
    "What’s your mother’s maiden name?",
    "What was the name of your first pet?",
    "In what city were you born?",
  ];

  bool _submitted = false;
  bool _isLoading = false;

  Future<void> _saveUserLocally({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String dateOfBirth,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_name', '$firstName $lastName');
    await prefs.setString('registeredEmail', email.trim().toLowerCase());  // normalize email
    await prefs.setString('user_phone', phoneNumber);
    await prefs.setString('user_dob', dateOfBirth);
    await prefs.setString('registeredPassword', password); // save password as is (no trim)
    await prefs.setString('securityQuestion', securityQuestion);
    await prefs.setString('securityAnswer', securityAnswer.toLowerCase().trim());
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);

    if (!_formData['termsAccepted']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must accept the Terms & Conditions")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_formData['password'] != _formData['confirmPassword']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1)); // Simulate delay

      await _saveUserLocally(
        firstName: _formData['firstName'],
        lastName: _formData['lastName'],
        email: _formData['email'],
        phoneNumber: _formData['phoneNumber'],
        dateOfBirth: _formData['dateOfBirth'],
        password: _formData['password'],
        securityQuestion: _formData['securityQuestion'],
        securityAnswer: _formData['securityAnswer'],
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );

      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextFormField(
                label: 'First Name',
                initialValue: _formData['firstName'],
                required: true,
                onChanged: (val) => setState(() => _formData['firstName'] = val),
                validator: (val) {
                  if (!_submitted) return null;
                  val = val?.trim();
                  if (val == null || val.isEmpty) return 'First Name is required';
                  if (val.length < 2 || val.length > 50 || !RegExp(r'^[a-zA-Z]+$').hasMatch(val)) {
                    return 'First Name must be 2–50 letters';
                  }
                  return null;
                },
                onSaved: (val) => _formData['firstName'] = val?.trim() ?? '',
              ),
              CustomTextFormField(
                label: 'Last Name',
                initialValue: _formData['lastName'],
                required: true,
                onChanged: (val) => setState(() => _formData['lastName'] = val),
                validator: (val) {
                  if (!_submitted) return null;
                  val = val?.trim();
                  if (val == null || val.isEmpty) return 'Last Name is required';
                  if (val.length < 2 || val.length > 50 || !RegExp(r'^[a-zA-Z]+$').hasMatch(val)) {
                    return 'Last Name must be 2–50 letters';
                  }
                  return null;
                },
                onSaved: (val) => _formData['lastName'] = val?.trim() ?? '',
              ),
              CustomTextFormField(
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                initialValue: _formData['email'],
                required: true,
                onChanged: (val) => setState(() => _formData['email'] = val),
                validator: (val) {
                  if (!_submitted) return null;
                  val = val?.trim();
                  if (val == null || val.isEmpty) return 'Email is required';
                  if (!ValidationUtils.validateEmail(val)) return 'Invalid email format';
                  return null;
                },
                onSaved: (val) => _formData['email'] = val?.trim() ?? '',
              ),
              CustomTextFormField(
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                initialValue: _formData['phoneNumber'],
                onChanged: (val) => setState(() => _formData['phoneNumber'] = val),
                validator: (val) {
                  if (!_submitted) return null;
                  val = val?.trim();
                  if (val != null && val.isNotEmpty && !ValidationUtils.validatePhone(val)) {
                    return 'Invalid phone number';
                  }
                  return null;
                },
                onSaved: (val) => _formData['phoneNumber'] = val?.trim() ?? '',
              ),
              DatePickerFormField(
                label: 'Date of Birth (YYYY-MM-DD)',
                initialDate: _formData['dateOfBirth'] != ''
                    ? DateTime.tryParse(_formData['dateOfBirth'])
                    : null,
                onChanged: (val) => setState(() => _formData['dateOfBirth'] = val ?? ''),
                validator: (val) {
                  if (!_submitted) return null;
                  if (val != null && val.isNotEmpty) {
                    try {
                      final dob = DateTime.parse(val);
                      final age = DateTime.now().year - dob.year;
                      if (age < 13) return 'You must be at least 13 years old';
                    } catch (_) {
                      return 'Invalid date (use YYYY-MM-DD)';
                    }
                  }
                  return null;
                },
                onSaved: (val) => _formData['dateOfBirth'] = val?.trim() ?? '',
              ),
              PasswordFormField(
                label: 'Password',
                initialValue: _formData['password'],
                required: true,
                onChanged: (val) => setState(() => _formData['password'] = val),
                validator: (val) {
                  if (!_submitted) return null;
                  val = val?.trim();
                  if (val == null || val.isEmpty) return 'Password is required';
                  if (!ValidationUtils.validatePassword(val)) {
                    return 'Password must be 8+ chars, with upper, number & special char';
                  }
                  return null;
                },
                onSaved: (val) => _formData['password'] = val ?? '', // don't trim password
              ),
              PasswordFormField(
                label: 'Confirm Password',
                initialValue: _formData['confirmPassword'],
                required: true,
                onChanged: (val) => setState(() => _formData['confirmPassword'] = val),
                validator: (val) {
                  if (!_submitted) return null;
                  val = val?.trim();
                  if (val == null || val.isEmpty) return 'Confirm Password is required';
                  if (val != _formData['password']) return 'Passwords do not match';
                  return null;
                },
                onSaved: (val) => _formData['confirmPassword'] = val ?? '',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Security Question'),
                value: _formData['securityQuestion'].isNotEmpty
                    ? _formData['securityQuestion']
                    : null,
                items: _securityQuestions
                    .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                    .toList(),
                onChanged: (val) => setState(() => _formData['securityQuestion'] = val ?? ''),
                validator: (val) {
                  if (!_submitted) return null;
                  if (val == null || val.isEmpty) return 'Please select a security question';
                  return null;
                },
              ),
              CustomTextFormField(
                label: 'Your Answer',
                required: true,
                onChanged: (val) => setState(() => _formData['securityAnswer'] = val),
                validator: (val) {
                  if (!_submitted) return null;
                  if (val == null || val.trim().isEmpty) return 'Answer is required';
                  return null;
                },
                onSaved: (val) => _formData['securityAnswer'] = val?.trim() ?? '',
              ),
              CheckboxListTile(
                title: const Text('I agree to the Terms & Conditions'),
                value: _formData['termsAccepted'],
                onChanged: (value) => setState(() => _formData['termsAccepted'] = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
