import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DBService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Save the 11 medical parameters to the user's profile
  Future<void> saveParameters(List<double> rawInputs, double riskScore) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    // SetOptions(merge: true) ensures we don't delete their name and email!
    await _db.collection('users').doc(user.uid).set({
      'parameters': rawInputs, 
      'riskScore': riskScore,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 2. Fetch the profile one-time (for form initialization / Persistence Fix)
  Future<DocumentSnapshot?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _db.collection('users').doc(user.uid).get();
  }

  // 3. Listen to the user's live data for the Sidebar (The culprit method)
  Stream<DocumentSnapshot> getUserData() {
    final user = _auth.currentUser;
    return _db.collection('users').doc(user?.uid).snapshots();
  }

  // 4. Save the 1 to 5 star rating
  Future<void> saveRating(int stars) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).set({
      'appRating': stars,
    }, SetOptions(merge: true));
  }
}