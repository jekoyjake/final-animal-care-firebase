import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Color? textColor;
  final Color? fillColor;

  const CustomTextField({
    required this.label,
    this.controller,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    this.textColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      style: TextStyle(color: textColor),
      // Set text color

      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor), // Set label text color
        filled: true,
        fillColor: fillColor, // Set background color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.blue, // Adjust the color as needed
            width: 2.0, // Adjust the width as needed
          ),
        ),
      ),
    );
  }
}
