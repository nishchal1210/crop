import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop/services/firestore_service.dart';
import 'dart:io' as io;
import 'dart:html' as html; // Web-specific imports
import 'package:flutter/foundation.dart' show kIsWeb;

class UploadPostScreen extends StatefulWidget {
  @override
  _UploadPostScreenState createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _imageFile;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web-specific image picking
      final fileInput = html.FileUploadInputElement();
      fileInput.accept = 'image/*';
      fileInput.onChange.listen((e) async {
        final files = fileInput.files;
        if (files!.isEmpty) return;
        final reader = html.FileReader();
        reader.readAsDataUrl(files[0]!);
        reader.onLoadEnd.listen((e) async {
          setState(() {
            _imageFile = XFile(reader.result as String);
          });
        });
      });
      fileInput.click();
    } else {
      // Mobile-specific image picking
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_imageFile != null && _descriptionController.text.isNotEmpty) {
      await _firestoreService.uploadPost(
          _descriptionController.text, _imageFile!);
      Navigator.of(context).pop(); // Navigate back after upload
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Post'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 10),
            if (kIsWeb)
              _imageFile == null
                  ? Text('No image selected.')
                  : Image.network(_imageFile!.path) // Use network image in web
            else
              _imageFile == null
                  ? Text('No image selected.')
                  : Image.file(
                      io.File(_imageFile!.path)), // Use file image in mobile
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 10),
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
