import 'package:flutter/material.dart';
import 'package:crop/post.dart';
import 'package:crop/services/firestore_service.dart';
import 'package:crop/widgets/post_widget.dart';
import 'package:crop/screens/upload_post_screen.dart';

class FeedScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Feed'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UploadPostScreen()));
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: _firestoreService.fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return Center(child: Text('No posts yet.'));
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostWidget(post: posts[index]);
            },
          );
        },
      ),
    );
  }
}
