import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/core/constants/app_strings.dart';

class AuthViewModel extends ChangeNotifier {
  final Ref ref;
  AuthViewModel(this.ref);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _auth.currentUser;

  Future<bool> signUp({required String email, required String password}) async {
    if (_isLoading) return false;
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message ?? AppStrings.failedToSignUp;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = AppStrings.failedToSignUp;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    if (_isLoading) return false;
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message ?? AppStrings.failedToLogin;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = AppStrings.failedToLogin;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      await _auth.signOut();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = AppStrings.failedToLogout;
      notifyListeners();
    }
  }

  // String _getErrorMessage(String code) {
  //   switch (code) {
  //     case 'weak-password':
  //       return 'The password provided is too weak.';
  //     case 'email-already-in-use':
  //       return 'An account already exists for that email.';
  //     case 'invalid-credential':
  //       return 'The provided credentials are invalid.';
  //     case 'user-disabled':
  //       return 'This user account has been disabled.';
  //     case 'user-not-found':
  //       return 'No user found for that email.';
  //     case 'wrong-password':
  //       return 'Wrong password provided.';
  //     case 'too-many-requests':
  //       return 'Too many requests. Please try again later.';
  //     case 'operation-not-allowed':
  //       return 'Email/password accounts are not enabled.';
  //     default:
  //       return 'Authentication failed. Please try again.';
  //   }
  // }
}

final authProvider = ChangeNotifierProvider<AuthViewModel>(
  (ref) => AuthViewModel(ref),
);
