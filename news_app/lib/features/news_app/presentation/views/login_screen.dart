import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_text_form_field.dart';
import '../widgets/password_form_field.dart';
import '../../utils/validation_utils.dart';
import '../views/home_screen.dart';
import '../../data/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'email': '',
    'password': '',
    'rememberMe': false,
  };

  bool _isLoading = false;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      final email = prefs.getString('rememberedEmail') ?? '';
      final password = prefs.getString('rememberedPassword') ?? '';
      setState(() {
        _formData['email'] = email;
        _formData['password'] = password;
        _formData['rememberMe'] = true;
      });

      final savedEmail = prefs.getString('registeredEmail');
      final savedPassword = prefs.getString('registeredPassword');

      final normalizedEmail = email.trim().toLowerCase();
      final savedEmailNormalized = savedEmail?.trim().toLowerCase();

      if (normalizedEmail == savedEmailNormalized && password == savedPassword) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToHome(email);
        });
      }
    }
  }

 
 void _navigateToHome(String email) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => HomeScreen(
        user: User(
          id: '1',             
          email: email,
          passwordHash: '',    
          firstName: '',       
          lastName: '',        
        ),
      ),
    ),
  );
}

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('registeredEmail');
    final savedPassword = prefs.getString('registeredPassword');

    await Future.delayed(const Duration(seconds: 1)); // Simulate delay

    final inputEmail = _formData['email']?.trim().toLowerCase();
    final savedEmailNormalized = savedEmail?.trim().toLowerCase();

    if (inputEmail == savedEmailNormalized && _formData['password'] == savedPassword) {
      if (_formData['rememberMe']) {
        await prefs.setBool('rememberMe', true);
        await prefs.setString('rememberedEmail', _formData['email']);
        await prefs.setString('rememberedPassword', _formData['password']);
      } else {
        await prefs.remove('rememberMe');
        await prefs.remove('rememberedEmail');
        await prefs.remove('rememberedPassword');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );

      _navigateToHome(_formData['email']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            children: [
              const SizedBox(height: 40),
              const FlutterLogo(size: 80),
              const SizedBox(height: 20),
              CustomTextFormField(
                label: 'Email',
                initialValue: _formData['email'],
                keyboardType: TextInputType.emailAddress,
                required: true,
                onChanged: (val) => _formData['email'] = val,
                onSaved: (val) => _formData['email'] = val?.trim() ?? '',
                validator: (val) {
                  val = val?.trim();
                  if (val == null || val.isEmpty) return 'Email is required';
                  if (!ValidationUtils.validateEmail(val)) return 'Invalid email format';
                  return null;
                },
              ),
              PasswordFormField(
                label: 'Password',
                required: true,
                initialValue: _formData['password'],
                onChanged: (val) => _formData['password'] = val,
                onSaved: (val) => _formData['password'] = val ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Password is required';
                  return null;
                },
              ),
              CheckboxListTile(
                title: const Text('Remember Me'),
                value: _formData['rememberMe'],
                onChanged: (val) {
                  setState(() => _formData['rememberMe'] = val ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitLogin,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Login'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/forgot'),
                child: const Text('Forgot password?'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
