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
    this.obscureText,
    this.onToggleVisibility,
    this.validator,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? errorMsg;
  final bool? isObscure;
  final bool? obscureText;
  final VoidCallback? onToggleVisibility;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final bool showObscure = obscureText ?? isObscure ?? false;

    return TextFormField(
      obscureText: showObscure,
      controller: controller,
      cursorColor: AppColors.red,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.red),
        ),
        hintText: hintText ?? AppStrings.emptyString,
        suffixIcon: onToggleVisibility != null
            ? IconButton(
                icon: Icon(
                  showObscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.black54,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMsg ?? AppStrings.emptyString;
        }
        if (validator != null) {
          return validator!(value);
        }
        return null;
      },
    );
  }
}
