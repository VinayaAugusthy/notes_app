import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/core/constants/app_strings.dart';
import 'package:notes_app/core/utils/app_snackbar.dart';
import 'package:notes_app/presentation/notes/notes_view_model.dart';
import 'package:notes_app/presentation/widgets/app_button.dart';
import 'package:notes_app/presentation/widgets/app_loader.dart';
import 'package:notes_app/presentation/widgets/app_text_form_field.dart';

class AddEditNotesView extends ConsumerStatefulWidget {
  const AddEditNotesView({super.key, this.noteId});

  final String? noteId;

  @override
  ConsumerState<AddEditNotesView> createState() => _AddEditNotesViewState();
}

class _AddEditNotesViewState extends ConsumerState<AddEditNotesView> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool get isEditMode => widget.noteId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode && widget.noteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadNote();
      });
    }
  }

  Future<void> _loadNote() async {
    final notesVM = ref.read(notesProvider);
    final note = await notesVM.fetchNoteById(widget.noteId!);

    if (mounted) {
      if (note != null) {
        titleController.text = note.title;
        contentController.text = note.content;
      } else {
        final errorMessage = notesVM.errorMessage;
        if (errorMessage != null) {
          AppSnackbar.showError(context, errorMessage);
        }
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (formKey.currentState?.validate() ?? false) {
      final notesVM = ref.read(notesProvider);
      final success = await notesVM.saveNote(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        noteId: widget.noteId,
      );

      if (mounted) {
        if (success) {
          AppSnackbar.showSuccess(
            context,
            isEditMode
                ? AppStrings.noteUpdatedSuccessfully
                : AppStrings.noteCreatedSuccessfully,
          );
          Navigator.pop(context);
        } else {
          AppSnackbar.showError(
            context,
            notesVM.errorMessage ?? AppStrings.failedToSaveNote,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesVM = ref.watch(notesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? AppStrings.editNote : AppStrings.addNote),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: notesVM.isLoading && isEditMode && titleController.text.isEmpty
              ? AppLoader()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      AppTextFormField(
                        controller: titleController,
                        hintText: AppStrings.title,
                        errorMsg: AppStrings.titleRequired,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: contentController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          hintText: AppStrings.content,
                        ),
                        maxLines: 10,
                        minLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.contentRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      notesVM.isLoading
                          ? AppLoader()
                          : AppButton(
                              onPressed: _handleSave,
                              buttonText: AppStrings.save,
                            ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
