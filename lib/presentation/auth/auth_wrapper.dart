import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/presentation/auth/auth_view_model.dart';
import 'package:notes_app/presentation/auth/login_view.dart';
import 'package:notes_app/presentation/notes/notes_view.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.watch(authProvider);

    if (authViewModel.currentUser == null) {
      return const LoginView();
    } else {
      return const NotesView();
    }
  }
}
