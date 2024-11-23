import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';

class Input extends StatelessWidget {
  const Input({
    super.key,
    this.controller,
    this.validation,
    this.secureText,
    this.icon,
    this.hintText,
    this.keyboardType,
    this.initialValue,
  });

  final String? initialValue;
  final TextEditingController? controller;
  final ValidationBuilder? validation;
  final bool? secureText;
  final Icon? icon;
  final String? hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validation?.build(),
      obscureText: secureText ?? false,
      initialValue: initialValue,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        fillColor: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[100]
            : Colors.grey[900],
        filled: true,
        prefixIcon: icon,
        border: const OutlineInputBorder(borderSide: BorderSide.none),
        hintText: hintText,
      ),
    );
  }
}
