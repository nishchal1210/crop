import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userId;
  final String imageUrl;
  final String description;
  final Timestamp timestamp;

  Post({
    required this.postId,
    required this.userId,
    required this.imageUrl,
    required this.description,
    required this.timestamp,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      userId: doc['userId'],
      imageUrl: doc['imageUrl'],
      description: doc['description'],
      timestamp: doc['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'imageUrl': imageUrl,
      'description': description,
      'timestamp': timestamp,
    };
  }
}
