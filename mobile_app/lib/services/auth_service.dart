import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Notice the 3 parameters here: email, password, name
  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      User? user = cred.user;
      
      if (user != null) {
  await user.updateDisplayName(name); // ✅ This fixes the "Hello User" bug
  await _db.collection('users').doc(user.uid).set({
    'uid': user.uid,
    'name': name,
    'email': email,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
      return user;
    } catch (e) {
      print("Sign Up Error: $e");
      return null;
    }
  }

  // Notice the 2 parameters here: email, password
  Future<User?> login(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return cred.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}