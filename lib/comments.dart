import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String commentId;
  final String userId;
  final String comment;
  final Timestamp timestamp;

  Comment({
    required this.commentId,
    required this.userId,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      commentId: doc['commentId'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'userId': userId,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}
