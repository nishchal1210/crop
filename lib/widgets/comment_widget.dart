import 'package:flutter/material.dart';
import 'package:crop/comments.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;

  CommentWidget({required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(comment.comment),
      subtitle: Text(
          comment.userId), // You might want to replace this with a username
      trailing: Text(comment.timestamp.toDate().toString()),
    );
  }
}
