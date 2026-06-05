import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firebase_database_service.dart';
import '../../../models/firebase_models.dart';

/// State representation for authentication.
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// StateNotifier handling authentication methods with FirebaseAuth.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    // Listen to authentication state changes dynamically
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      state = state.copyWith(user: user, isLoading: false);
    });
  }

  StreamSubscription<User?>? _authSubscription;

  /// Clear current error message from state
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Dynamic helper to extract error codes safely across platforms (including Web JS interop).
  String _getExceptionCode(dynamic e) {
    try {
      if (e is FirebaseAuthException) {
        return e.code;
      }
    } catch (_) {}

    try {
      if (e != null && e.code != null) {
        return e.code.toString();
      }
    } catch (_) {}

    try {
      final str = e.toString().toLowerCase();
      if (str.contains('user-not-found')) return 'user-not-found';
      if (str.contains('wrong-password')) return 'wrong-password';
      if (str.contains('invalid-email')) return 'invalid-email';
      if (str.contains('email-already-in-use')) return 'email-already-in-use';
      if (str.contains('weak-password')) return 'weak-password';
      if (str.contains('network-request-failed')) return 'network-request-failed';
      if (str.contains('invalid-credential')) return 'invalid-credential';
    } catch (_) {}

    return 'unknown_error';
  }

  /// Sign in with Email and Password
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Dynamic profile sync on login
      if (credential.user != null) {
        final uid = credential.user!.uid;
        try {
          final profile = await FirebaseDatabaseService.instance.getUserProfile(uid);
          await FirebaseDatabaseService.instance.createUserProfile(profile.copyWith(
            lastLogin: DateTime.now().millisecondsSinceEpoch,
          ));
        } catch (_) {
          // Fallback if profile does not exist in DB yet
          final newProfile = FirebaseUserProfile(
            uid: uid,
            name: credential.user!.displayName ?? 'User',
            email: credential.user!.email ?? email.trim(),
            photoUrl: credential.user!.photoURL ?? '',
            createdAt: DateTime.now().millisecondsSinceEpoch,
            lastLogin: DateTime.now().millisecondsSinceEpoch,
            level: 1,
            xp: 0,
            coins: 0,
            streak: 0,
          );
          await FirebaseDatabaseService.instance.createUserProfile(newProfile);
          await FirebaseDatabaseService.instance.updateTreeState(
            uid,
            FirebaseTreeState(
              treeLevel: 1,
              treeStage: 'Seed',
              growthPercentage: 0.0,
              lastGrowthDate: '',
              treeType: 'Oak',
            ),
          );
        }
      }

      return true;
    } catch (e) {
      final code = _getExceptionCode(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getReadableErrorMessage(code),
      );
      return false;
    }
  }

  /// Register user with Email and Password
  Future<bool> signUp(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Update display name and initialize user database documents
      if (credential.user != null) {
        final uid = credential.user!.uid;
        await credential.user!.updateDisplayName(name);

        final profile = FirebaseUserProfile(
          uid: uid,
          name: name,
          email: email.trim(),
          photoUrl: '',
          createdAt: DateTime.now().millisecondsSinceEpoch,
          lastLogin: DateTime.now().millisecondsSinceEpoch,
          level: 1,
          xp: 0,
          coins: 0,
          streak: 0,
        );
        
        await FirebaseDatabaseService.instance.createUserProfile(profile);
        await FirebaseDatabaseService.instance.updateTreeState(
          uid,
          FirebaseTreeState(
            treeLevel: 1,
            treeStage: 'Seed',
            growthPercentage: 0.0,
            lastGrowthDate: '',
            treeType: 'Oak',
          ),
        );
        await FirebaseDatabaseService.instance.updateSettings(
          uid,
          FirebaseSettings(
            theme: 'light',
            notificationsEnabled: true,
            language: 'en',
          ),
        );
      }
      return true;
    } catch (e) {
      final code = _getExceptionCode(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getReadableErrorMessage(code),
      );
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      final code = _getExceptionCode(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getReadableErrorMessage(code),
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await FirebaseAuth.instance.signOut();
    state = AuthState();
  }

  String _getReadableErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account exists with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'weak-password':
        return 'The password chosen is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: $code';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Provider to access auth notifier and state throughout the application.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
