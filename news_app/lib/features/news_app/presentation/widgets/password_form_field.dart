import 'package:flutter/material.dart';

class PasswordFormField extends StatefulWidget {
  final String label;
  final bool required;
  final String? initialValue;
  final String? errorText;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PasswordFormField({
    super.key,
    required this.label,
    this.required = false,
    this.initialValue,
    this.errorText,
    this.onSaved,
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: widget.initialValue, 
        obscureText: _obscure,
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: widget.errorText,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        validator: widget.validator ??
            (value) {
              if (widget.required && (value == null || value.isEmpty)) {
                return '${widget.label} is required';
              }
              return null;
            },
        onChanged: widget.onChanged,
        onSaved: widget.onSaved,
      ),
    );
  }
}
