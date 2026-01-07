import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/core/constants/app_colors.dart';
import 'package:notes_app/core/constants/app_strings.dart';
import 'package:notes_app/core/utils/app_snackbar.dart';
import 'package:notes_app/presentation/auth/auth_view_model.dart';
import 'package:notes_app/presentation/notes/add_edit_notes_view.dart';
import 'package:notes_app/presentation/notes/notes_view_model.dart';
import 'package:notes_app/presentation/widgets/app_confirmation_dialog.dart';
import 'package:notes_app/presentation/widgets/app_loader.dart';
import 'package:notes_app/presentation/widgets/app_searchbar.dart';

class NotesView extends ConsumerStatefulWidget {
  const NotesView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotesViewState();
}

class _NotesViewState extends ConsumerState<NotesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notesProvider).fetchNotes();
    });
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    String noteId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AppConfirmationDialog(
          title: AppStrings.deleteNote,
          content: AppStrings.deleteNoteConfirmation,
        );
      },
    );

    if (confirmed == true && mounted) {
      final notesVM = ref.read(notesProvider);
      final success = await notesVM.deleteNote(noteId);

      if (context.mounted) {
        if (success) {
          AppSnackbar.showSuccess(context, AppStrings.noteDeletedSuccessfully);
        } else {
          AppSnackbar.showError(
            context,
            notesVM.errorMessage ?? AppStrings.failedToDeleteNote,
          );
        }
      }
    }
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AppConfirmationDialog(
          title: AppStrings.logout,
          content: AppStrings.logoutConfirmation,
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(authProvider).signOut();
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.showError(context, AppStrings.failedToLogout);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesVM = ref.watch(notesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.notes),
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              AppSearchbar(),
              SizedBox(height: 10),
              Expanded(
                child: notesVM.isLoading
                    ? AppLoader()
                    : notesVM.filteredNotes.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.noNotesFound,
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : _buildNotesList(notesVM),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditNotesView()),
          );
          if (mounted) {
            ref.read(notesProvider).fetchNotes();
          }
        },
        backgroundColor: AppColors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  ListView _buildNotesList(NotesViewModel notesVM) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: notesVM.filteredNotes.length,
      itemBuilder: (context, index) {
        final note = notesVM.filteredNotes[index];
        return ListTile(
          title: Text(
            note.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            note.content,
            style: TextStyle(color: AppColors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditNotesView(noteId: note.id),
                    ),
                  );
                  if (mounted) {
                    ref.read(notesProvider).fetchNotes();
                  }
                },
                icon: Icon(Icons.edit, color: AppColors.blue),
              ),
              IconButton(
                onPressed: () {
                  _showDeleteConfirmationDialog(context, note.id);
                },
                icon: const Icon(Icons.delete, color: AppColors.red),
              ),
            ],
          ),
        );
      },
    );
  }
}
