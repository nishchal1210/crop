import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io' as io;
import 'dart:html' as html;
import 'package:crop/post.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:crop/comments.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> uploadPost(String description, XFile imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    String imageUrl = '';
    try {
      if (kIsWeb) {
        // Web-specific handling
        final bytes = await imageFile.readAsBytes();
        final uint8List = Uint8List.fromList(bytes);
        final blob = html.Blob([uint8List]);

        // Create a reference to Firebase Storage
        final storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

        // Upload the Blob to Firebase Storage
        final uploadTask = storageRef.putBlob(blob);
        final snapshot = await uploadTask.whenComplete(() => {});
        imageUrl = await snapshot.ref.getDownloadURL();
      } else {
        // Mobile-specific handling
        final storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(io.File(imageFile.path));
        final snapshot = await uploadTask.whenComplete(() => {});
        imageUrl = await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading image: $e');
      return;
    }

    // Ensure that imageUrl is not empty before proceeding
    if (imageUrl.isNotEmpty) {
      final post = Post(
        postId: _db.collection('posts').doc().id,
        userId: user.uid,
        imageUrl: imageUrl,
        description: description,
        timestamp: Timestamp.now(),
      );

      try {
        await _db.collection('posts').doc(post.postId).set(post.toMap());
      } catch (e) {
        print('Error saving post: $e');
      }
    } else {
      print('Failed to obtain image URL');
    }
  }

  Stream<List<Post>> fetchPosts() {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromDocument(doc)).toList());
  }
}
