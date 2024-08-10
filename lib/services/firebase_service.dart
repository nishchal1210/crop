import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUserData(
      String userId, String cropName, DateTime sowingDate, String tips) async {
    // Reference to Firestore
    DocumentReference userRef = _firestore.collection('users').doc(userId);

    // Create or update the user's data
    await userRef.set({
      'email': 'user@example.com', // Example field, replace with actual data
    }, SetOptions(merge: true));

    // Reference to the cultivation_tips subcollection
    CollectionReference tipsRef = userRef.collection('cultivation_tips');

    // Create or update the crop document
    await tipsRef.doc(cropName).set({
      'sowing_date': Timestamp.fromDate(sowingDate),
      'tips': tips,
      'timestamp': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
