import 'package:flutter/material.dart';
import 'package:notes_app/core/constants/app_colors.dart';
import 'package:notes_app/core/constants/app_strings.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorMsg,
    this.isObscure,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? errorMsg;
  final bool? isObscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isObscure ?? false,
      controller: controller,
      cursorColor: AppColors.red,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.red),
        ),
        hintText: hintText ?? AppStrings.emptyString,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMsg ?? AppStrings.emptyString;
        } else {
          return null;
        }
      },
    );
  }
}
