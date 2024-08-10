import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class DiseaseDetectionPage extends StatefulWidget {
  const DiseaseDetectionPage({super.key});

  @override
  _DiseaseDetectionPageState createState() => _DiseaseDetectionPageState();
}

class _DiseaseDetectionPageState extends State<DiseaseDetectionPage> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  String _result = '';

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _result = ''; // Reset result when a new image is picked
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null) return;

    setState(() {
      _isLoading = true;
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:5000/analyze'),
    );
    request.files.add(http.MultipartFile.fromBytes('file', _imageBytes!,
        filename: 'image.jpg'));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final resultData = json.decode(responseData);
      setState(() {
        _result = resultData['text'];
      });
    } else {
      setState(() {
        _result = 'Error: Failed to analyze image';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Disease Detection'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageBytes == null
                  ? Text('No image selected.')
                  : Image.memory(_imageBytes!, height: 200),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Analyze Image'),
              ),
              SizedBox(height: 20),
              Text('It may take up to 30 seconds to generate result'),
              SizedBox(
                height: 20,
              ),
              _isLoading
                  ? CircularProgressIndicator()
                  : _result.isEmpty
                      ? Container()
                      : _buildResultCards(_result),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCards(String resultText) {
    // Remove all asterisks from the result text
    String cleanedText = resultText.replaceAll('*', '');

    // Split the cleaned text into components by '##'
    List<String> components = cleanedText.split('##');

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: components.length,
      itemBuilder: (context, index) {
        // Skip empty components
        if (components[index].trim().isEmpty) {
          return SizedBox.shrink();
        }

        return Card(
          margin: EdgeInsets.all(8.0),
          color: _getCardColor(index),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              components[index],
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        );
      },
    );
  }

  Color _getCardColor(int index) {
    switch (index % 4) {
      case 0:
        return Colors.blue[100]!;
      case 1:
        return Colors.green[100]!;
      case 2:
        return Colors.orange[100]!;
      case 3:
        return Colors.purple[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
