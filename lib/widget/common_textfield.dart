import 'package:flutter/material.dart';

class CommonTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final FormFieldValidator? validator;
  final Widget? suffixIcon;

  const CommonTextfield(
      {super.key,
      required this.controller,
      required this.label,
      required this.obscureText,
      required this.validator,
      this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey, width: 1)),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
