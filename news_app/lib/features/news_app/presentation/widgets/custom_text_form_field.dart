import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String? initialValue; 
  final String? errorText;
  final bool required;
  final TextInputType keyboardType;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    required this.label,
    this.initialValue,
    this.errorText,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.onSaved,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
        validator: validator ??
            (value) {
              if (required && (value == null || value.isEmpty)) {
                return '$label is required';
              }
              return null;
            },
        onChanged: onChanged,
        onSaved: onSaved,
      ),
    );
  }
}

