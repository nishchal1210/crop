import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CultivationTipsPage extends StatefulWidget {
  @override
  _CultivationTipsPageState createState() => _CultivationTipsPageState();
}

class CropSelectionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> crops = ['Wheat', 'Rice', 'Corn', 'Soybean'];

    return SimpleDialog(
      title: Text('Select Crop'),
      children: crops.map((crop) {
        return SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, crop);
          },
          child: Text(crop),
        );
      }).toList(),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final String tips;

  ResultsPage({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cultivation Tips'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(tips, style: TextStyle(fontSize: 16.0)),
            // Add more widgets if needed
          ],
        ),
      ),
    );
  }
}

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

class _CultivationTipsPageState extends State<CultivationTipsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedCrop = '';
  DateTime? _selectedDate;
  String? _tips;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _checkForExistingData();
  }

  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  void _selectCrop() async {
    String? selectedCrop = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CropSelectionDialog();
      },
    );

    if (selectedCrop != null) {
      setState(() {
        _selectedCrop = selectedCrop;
        _selectedDate = null; // Reset date
        _tips = null; // Reset tips
      });
      _checkForExistingData();
    }
  }

  void _checkForExistingData() async {
    if (_currentUser != null && _selectedCrop.isNotEmpty) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('cultivation_tips')
          .doc(_selectedCrop)
          .get();

      if (snapshot.exists) {
        setState(() {
          _selectedDate =
              (snapshot.data() as Map<String, dynamic>)['sowing_date'].toDate();
          _tips = (snapshot.data() as Map<String, dynamic>)['tips'];
        });
        _showBottomSheet();
      }
    }
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _sendDataToBackend() async {
    if (_selectedCrop.isNotEmpty &&
        _selectedDate != null &&
        _currentUser != null) {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/get_tips'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'crop': _selectedCrop,
          'sowing_date': _selectedDate!.toIso8601String(),
          'user_id': _currentUser!.uid,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tips = data['predicted_crops'];
        if (tips != null) {
          setState(() {
            _tips = tips;
          });
          _saveToFirebase(tips);
          _showBottomSheet();
        }
      } else {
        // Handle error
      }
    }
  }

  Future<void> _saveToFirebase(String tips) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('cultivation_tips')
        .doc(_selectedCrop)
        .set({
      'sowing_date': _selectedDate,
      'tips': tips,
      'timestamp': Timestamp.now(),
    });
  }

  void _showBottomSheet() {
    if (_tips != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.67, // 2/3rd height
            child: DraggableScrollableSheet(
              initialChildSize: 1.0,
              maxChildSize: 1.0,
              minChildSize: 1.0,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Text(
                      'Cultivation Tips for $_selectedCrop',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _tips!,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cultivation Tips'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a Crop:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _selectCrop,
              child:
                  Text(_selectedCrop.isEmpty ? 'Select Crop' : _selectedCrop),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedDate != null)
              Row(
                children: [
                  Text(
                    'Sowing Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _selectDate,
                    child: Text('Change Date'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      textStyle: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            if (_selectedDate == null)
              ElevatedButton(
                onPressed: _selectDate,
                child: Text('Select Sowing Date'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 16),
            if (_selectedDate != null && _tips == null)
              ElevatedButton(
                onPressed: _sendDataToBackend,
                child: Text('Get Tips'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
