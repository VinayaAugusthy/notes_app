import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/core/constants/app_strings.dart';
import 'package:notes_app/domain/models/note_model.dart';

class NotesViewModel extends ChangeNotifier {
  Ref ref;
  NotesViewModel(this.ref);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController searchController = TextEditingController();

  bool _isLoading = false;
  List<NoteModel> _notes = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<NoteModel> get notes => _notes;
  String? get errorMessage => _errorMessage;

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<bool> saveNote({
    required String title,
    required String content,
    String? noteId,
  }) async {
    try {
      if (currentUserId == null) {
        _errorMessage = AppStrings.userNotAuthenticated;
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final now = DateTime.now();
      final noteData = {
        'title': title.trim(),
        'content': content.trim(),
        'user_id': currentUserId!,
        'updated_at': Timestamp.fromDate(now),
      };

      if (noteId == null) {
        noteData['created_at'] = Timestamp.fromDate(now);
        await _firestore.collection('notes').add(noteData);
      } else {
        await _firestore.collection('notes').doc(noteId).update(noteData);
      }

      _isLoading = false;
      notifyListeners();
      await fetchNotes();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to save note: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchNotes() async {
    try {
      if (currentUserId == null) {
        _notes = [];
        notifyListeners();
        return;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('notes')
          .where('user_id', isEqualTo: currentUserId)
          .orderBy('updated_at', descending: true)
          .get();

      _notes = querySnapshot.docs
          .map((doc) => NoteModel.fromMap(doc.id, doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch notes: ${e.toString()}';
      _notes = [];
      notifyListeners();
    }
  }

  Future<NoteModel?> fetchNoteById(String noteId) async {
    try {
      if (currentUserId == null) {
        _errorMessage = AppStrings.userNotAuthenticated;
        notifyListeners();
        return null;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final docSnapshot = await _firestore
          .collection('notes')
          .doc(noteId)
          .get();

      if (!docSnapshot.exists) {
        _isLoading = false;
        _errorMessage = AppStrings.noteNotFound;
        notifyListeners();
        return null;
      }

      final data = docSnapshot.data()!;
      final note = NoteModel.fromMap(noteId, data);

      if (note.userId != currentUserId) {
        _isLoading = false;
        _errorMessage = AppStrings.noPermissionToAccessNote;
        notifyListeners();
        return null;
      }

      _isLoading = false;
      notifyListeners();
      return note;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '${AppStrings.failedToFetchNote}: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    try {
      if (currentUserId == null) {
        _errorMessage = AppStrings.userNotAuthenticated;
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestore.collection('notes').doc(noteId).delete();

      _isLoading = false;
      notifyListeners();
      await fetchNotes();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete note: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}

final notesProvider = ChangeNotifierProvider<NotesViewModel>(
  (ref) => NotesViewModel(ref),
);
