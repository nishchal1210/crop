// create_post_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _description;
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadPost() async {
    if (_image != null && _description != null && _description!.isNotEmpty) {
      try {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child(DateTime.now().toString() + '.jpg');
        final uploadTask = storageRef.putFile(_image!);

        final snapshot = await uploadTask.whenComplete(() => {});
        final imageUrl = await snapshot.ref.getDownloadURL();

        // Add post details to Firestore
        await FirebaseFirestore.instance.collection('posts').add({
          'imageUrl': imageUrl,
          'description': _description,
          'userEmail': FirebaseAuth.instance.currentUser!.email,
          'timestamp': Timestamp.now(),
        });

        setState(() {
          _image = null;
          _descriptionController.clear();
        });
      } catch (error) {
        print("Error uploading post: $error");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to upload post')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select an image and provide a description')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null)
              Image.file(
                _image!,
                height: 200,
                width: 200,
              ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                _description = value;
              },
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _uploadPost,
              child: Text('Upload Post'),
            ),
          ],
        ),
      ),
    );
  }
}
