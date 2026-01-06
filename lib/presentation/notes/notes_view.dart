import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/core/constants/app_colors.dart';
import 'package:notes_app/presentation/auth/auth_view_model.dart';
import 'package:notes_app/presentation/widgets/app_searchbar.dart';

class NotesView extends ConsumerStatefulWidget {
  const NotesView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotesViewState();
}

class _NotesViewState extends ConsumerState<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.red,
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authProvider).signOut();
            },
            icon: const Icon(Icons.logout),
            color: AppColors.white,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [AppSearchbar()]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
