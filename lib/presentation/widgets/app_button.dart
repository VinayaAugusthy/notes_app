import 'package:flutter/material.dart';
import 'package:notes_app/core/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  final VoidCallback onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }
}
