import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/core/constants/app_colors.dart';
import 'package:notes_app/core/constants/app_strings.dart';
import 'package:notes_app/presentation/notes/notes_view_model.dart';

class AppSearchbar extends ConsumerStatefulWidget {
  const AppSearchbar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppSearchbarState();
}

class _AppSearchbarState extends ConsumerState<AppSearchbar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _searchController,
      cursorColor: AppColors.black54,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        hintText: AppStrings.search,
        hintStyle: const TextStyle(color: AppColors.black54),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.black26),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.black),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.black54),
                onPressed: () {
                  _searchController.clear();
                  ref.read(notesProvider).updateSearchQuery('');
                  FocusScope.of(context).unfocus();
                },
              )
            : const Icon(Icons.search, color: AppColors.black54),
      ),
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        ref.read(notesProvider).updateSearchQuery(value);
      },
      onFieldSubmitted: (value) {
        FocusScope.of(context).unfocus();
      },
    );
  }
}
