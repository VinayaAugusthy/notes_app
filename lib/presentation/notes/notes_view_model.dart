import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesViewModel extends ChangeNotifier {
  Ref ref;
  NotesViewModel(this.ref);

  TextEditingController searchController = TextEditingController();
}

final notesProvider = ChangeNotifierProvider<NotesViewModel>(
  (ref) => NotesViewModel(ref),
);
