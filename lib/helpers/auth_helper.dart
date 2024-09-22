import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthHelper {
  AuthHelper._();

  static final AuthHelper authHelper = AuthHelper._();
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static GoogleSignIn googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>> signInGuestUser() async {
    Map<String, dynamic> res = {};

    try {
      UserCredential userCredential = await firebaseAuth.signInAnonymously();
      User? user = userCredential.user;

      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "network-request-failed":
          res['error'] = "No Internet Available";
          break;
        case "operation-not-allowed":
          res['error'] = "This is disabled by admin..";
          break;
        default:
          res['error'] = "${e.code}";
          break;
      }
    }

    return res;
  }

  Future<Map<String, dynamic>> signUpUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    Map<String, dynamic> res = {};

    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "network-request-failed":
          res['error'] = "No Internet Available";
          break;
        case "operation-not-allowed":
          res['error'] = "This is disabled by admin..";
          break;
        case "weak-password":
          res['error'] = "Password is not valid";
          break;
        case "email-already-in-use":
          res['error'] = "This email is already exists..";
          break;
        default:
          res['error'] = "${e.code}";
          break;
      }
    }

    return res;
  }

  Future<Map<String, dynamic>> signInUserWithEmailAndPassword(
      {required String email, required String password}) async {
    Map<String, dynamic> res = {};

    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "network-request-failed":
          res['error'] = "No Internet Available";
          break;
        case "operation-not-allowed":
          res['error'] = "This is disabled by admin..";
          break;
        case "invalid-credential":
          res['error'] = "Invalid credentials.";
          break;
        default:
          res['error'] = "${e.code}";
          break;
      }
    }

    return res;
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    Map<String, dynamic> res = {};
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      User? user = userCredential.user;

      res['user'] = user;
    } catch (e) {
      res['error'] = "${e}";
    }
    return res;
  }

  Future<void> updateUsername(String displayName) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      await user.updateProfile(displayName: displayName);
      await user.reload();
      user = firebaseAuth.currentUser;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        await user.reload();
        return true;
      } on FirebaseAuthException catch (e) {
        print("Failed to update password: ${e.message}");
        return false;
      }
    } else {
      print("No user is signed in");
      return false;
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }
}
