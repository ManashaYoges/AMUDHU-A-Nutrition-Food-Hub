import 'package:firebase_auth/firebase_auth.dart';

/// Exception thrown by [AuthService] with user-friendly error messages.
class AuthServiceException implements Exception {
  final String message;
  final String? code;

  const AuthServiceException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Reusable Firebase Authentication service for AMUDHU.
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently authenticated user, or null if none.
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently authenticated.
  bool get isSignedIn => _auth.currentUser != null;

  /// Register a new account with email and password.
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      throw const AuthServiceException(
        'Please provide an email address.',
        code: 'empty-email',
      );
    }
    if (password.isEmpty) {
      throw const AuthServiceException(
        'Please enter a password.',
        code: 'empty-password',
      );
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_mapAuthErrorMessage(e), code: e.code);
    } catch (e) {
      throw const AuthServiceException(
        'An unexpected error occurred during registration. Please try again.',
        code: 'unknown',
      );
    }
  }

  /// Sign in with existing email and password.
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      throw const AuthServiceException(
        'Please enter your email address.',
        code: 'empty-email',
      );
    }
    if (password.isEmpty) {
      throw const AuthServiceException(
        'Please enter your password.',
        code: 'empty-password',
      );
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_mapAuthErrorMessage(e), code: e.code);
    } catch (e) {
      throw const AuthServiceException(
        'An unexpected error occurred during login. Please try again.',
        code: 'unknown',
      );
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_mapAuthErrorMessage(e), code: e.code);
    } catch (e) {
      throw const AuthServiceException(
        'Failed to sign out. Please try again.',
        code: 'sign-out-failed',
      );
    }
  }

  /// Send a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      throw const AuthServiceException(
        'Please enter your email address.',
        code: 'empty-email',
      );
    }
    try {
      await _auth.sendPasswordResetEmail(email: cleanEmail);
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_mapAuthErrorMessage(e), code: e.code);
    }
  }

  /// Map Firebase Auth exception codes to clean, human-readable error messages.
  static String _mapAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address format is invalid. Please check and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email address. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please verify your password and try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'email-already-in-use':
        return 'An account already exists for this email address. Please log in instead.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase. Please enable it in the Firebase Console.';
      case 'network-request-failed':
        return 'Network error: please check your internet connection.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please wait a moment and try again.';
      case 'channel-error':
        return 'Please ensure both email and password are provided.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
