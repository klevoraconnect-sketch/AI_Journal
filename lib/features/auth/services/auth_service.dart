import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../config/supabase_config.dart';
import '../../../core/services/encryption_service.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final EncryptionService _encryptionService = EncryptionService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get current user as UserModel
  UserModel? get currentUserModel {
    final user = currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
      photoUrl: user.userMetadata?['photo_url'] as String?,
      createdAt: DateTime.parse(user.createdAt),
      lastLoginAt: user.lastSignInAt != null
          ? DateTime.parse(user.lastSignInAt!)
          : null,
    );
  }

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
        },
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      // Initialize encryption key with password
      await _encryptionService.initializeKey(userPassword: password);

      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? email,
        displayName: displayName,
        photoUrl: null,
        createdAt: DateTime.parse(response.user!.createdAt),
        lastLoginAt: null,
      );
    } on AuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed');
      }

      // Initialize encryption key with password
      await _encryptionService.initializeKey(userPassword: password);

      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? email,
        displayName: response.user!.userMetadata?['display_name'] as String?,
        photoUrl: response.user!.userMetadata?['photo_url'] as String?,
        createdAt: DateTime.parse(response.user!.createdAt),
        lastLoginAt: response.user!.lastSignInAt != null
            ? DateTime.parse(response.user!.lastSignInAt!)
            : null,
      );
    } on AuthException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign in with Google OAuth
  Future<UserModel> signInWithGoogle() async {
    try {
      // Sign in with Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Failed to get Google tokens');
      }

      // Sign in to Supabase with Google tokens
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw Exception('Google sign in failed');
      }

      // Initialize encryption key (random key for OAuth users)
      await _encryptionService.initializeKey();

      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        displayName: response.user!.userMetadata?['full_name'] as String? ??
            googleUser.displayName,
        photoUrl: response.user!.userMetadata?['avatar_url'] as String? ??
            googleUser.photoUrl,
        createdAt: DateTime.parse(response.user!.createdAt),
        lastLoginAt: response.user!.lastSignInAt != null
            ? DateTime.parse(response.user!.lastSignInAt!)
            : null,
      );
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Clear encryption key
      await _encryptionService.clearKey();

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Supabase
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
