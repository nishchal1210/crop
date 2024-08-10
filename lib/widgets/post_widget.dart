import 'package:flutter/material.dart';
import 'package:crop/post.dart';

class PostWidget extends StatelessWidget {
  final Post post;

  PostWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.network(post.imageUrl),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(post.description),
          ),
        ],
      ),
    );
  }
}
