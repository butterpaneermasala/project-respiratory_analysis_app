import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In package

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // GoogleSignIn instance

  // Sign in method with Google Sign-In and Firebase Authentication
  Future<User?> signIn() async {
    try {
      // Step 1: Trigger the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // If the user cancels the sign-in process
        print("Google Sign-In canceled.");
        return null;
      }

      // Step 2: Retrieve authentication details from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Step 3: Create Firebase credential from Google authentication details
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  // Sign out from both Google and Firebase
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();  // Sign out from Google
      await _firebaseAuth.signOut();  // Sign out from Firebase
      print("User signed out successfully");
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  // Get the current user from Firebase
  Future<User?> getCurrentUser() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.getIdToken(true); // Force token refresh if needed
      }
      return user;
    } catch (e) {
      print("Error getting current user: $e");
      return null;
    }
  }

  // Check if the user is signed in with Firebase
  bool isSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Manually refresh the token before performing authenticated operations
  Future<String?> getFreshToken() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        String? token = await user.getIdToken(true); // Forces refresh
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
