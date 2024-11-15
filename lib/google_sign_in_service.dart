import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in method
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      return user;
    } catch (error) {
      print('Sign in failed: $error');
      return null;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('User signed out successfully');
    } catch (error) {
      print('Sign out failed: $error');
    }
  }

  // Get current user
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _googleSignIn.currentUser != null;
  }
}
