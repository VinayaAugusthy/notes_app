import 'package:flutter/material.dart';
import 'package:notes_app/core/constants/app_colors.dart';
import 'package:notes_app/core/constants/app_strings.dart';

class AppConfirmationDialog extends StatelessWidget {
  const AppConfirmationDialog({super.key, this.title, this.content});

  final String? title;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentTextStyle: const TextStyle(color: AppColors.black),
      title: Text(title ?? ""),
      content: Text(content ?? ""),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            AppStrings.no,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.red,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.red),
          child: const Text(
            AppStrings.yes,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),
          ),
        ),
      ],
    );
  }
}
