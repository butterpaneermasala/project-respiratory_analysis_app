import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in method
  Future<User?> signIn() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        print("User canceled the sign-in.");
        return null;
      }

      // Obtain the Google Sign-In authentication credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        print("Google Sign-In did not provide an ID token.");
        return null;
      }

      // Log the ID token for debugging purposes
      print("Google ID Token: ${googleAuth.idToken}");

      // Force token refresh if it's close to expiration
      await googleUser.authentication; // Refresh token

      // Create a new credential for Firebase Authentication
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Log the Firebase user for debugging purposes
      print("Signed in as: ${userCredential.user?.email}");

      // Return the Firebase user
      return userCredential.user;
    } catch (error) {
      print("Error signing in: $error");
      return null;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      // Sign out from Firebase and Google
      await _auth.signOut();
      await _googleSignIn.signOut();
      print('User signed out successfully');
    } catch (error) {
      print('Sign out failed: $error');
    }
  }

  // Get current user with token refresh if necessary
  Future<User?> getCurrentUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Refresh the token to avoid expiration issues
        await user.getIdToken(true); // Force token refresh
        print("Token refreshed for current user");
      }
      return user;
    } catch (e) {
      print("Error getting current user: $e");
      return null;
    }
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // Refresh token manually before performing authenticated operations
  Future<String?> getFreshToken() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Refresh the user's token
        String? token = await user.getIdToken(true); // Forces refresh
        print("Fresh token: $token");
        return token;
      } else {
        print('No user is signed in');
        return null;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }
}
