import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

class CropSelectionScreen extends StatefulWidget {
  @override
  _CropSelectionScreenState createState() => _CropSelectionScreenState();
}

class _CropSelectionScreenState extends State<CropSelectionScreen> {
  final List<Crop> crops = [
    Crop(name: 'Rice', wastes: ['Straw', 'Husk']),
    Crop(name: 'Wheat', wastes: ['Straw', 'Bran']),
    Crop(name: 'Sugarcane', wastes: ['Bagasse', 'Molasses']),
    Crop(name: 'Maize', wastes: ['Stalks', 'Cobs']),
    Crop(name: 'Cotton', wastes: ['Stalks', 'Lint']),
    Crop(name: 'Groundnut', wastes: ['Shells', 'Haulms']),
    Crop(name: 'Soybean', wastes: ['Stems', 'Pods']),
    Crop(name: 'Paddy', wastes: ['Straw', 'Husk']),
    Crop(name: 'Barley', wastes: ['Straw', 'Hull']),
    Crop(name: 'Millet', wastes: ['Stalks', 'Husks']),
    Crop(name: 'Tea', wastes: ['Spent Leaves', 'Stems']),
    Crop(name: 'Coffee', wastes: ['Pulp', 'Husk']),
    Crop(name: 'Jute', wastes: ['Stalks', 'Leaves']),
    Crop(name: 'Tobacco', wastes: ['Stems', 'Leaves']),
    Crop(name: 'Peas', wastes: ['Pods', 'Vines']),
    Crop(name: 'Chickpea', wastes: ['Stalks', 'Pods']),
    Crop(name: 'Mustard', wastes: ['Stalks', 'Seed Cake']),
    Crop(name: 'Sunflower', wastes: ['Stalks', 'Seed Hulls']),
    Crop(name: 'Sesame', wastes: ['Stalks', 'Seed Hulls']),
    Crop(name: 'Coconut', wastes: ['Shells', 'Husks']),
    Crop(name: 'Banana', wastes: ['Leaves', 'Stalks']),
    Crop(name: 'Potato', wastes: ['Peels', 'Stalks']),
    Crop(name: 'Tomato', wastes: ['Leaves', 'Stems']),
    Crop(name: 'Onion', wastes: ['Peels', 'Stalks']),
    Crop(name: 'Garlic', wastes: ['Peels', 'Stalks']),
    Crop(name: 'Carrot', wastes: ['Peels', 'Leaves']),
    Crop(name: 'Cabbage', wastes: ['Leaves', 'Stalks']),
    Crop(name: 'Cauliflower', wastes: ['Leaves', 'Stalks']),
    Crop(name: 'Spinach', wastes: ['Leaves', 'Stalks']),
    Crop(name: 'Lettuce', wastes: ['Leaves', 'Stalks']),
    Crop(name: 'Pepper', wastes: ['Stems', 'Leaves']),
    Crop(name: 'Mango', wastes: ['Leaves', 'Peels']),
    Crop(name: 'Apple', wastes: ['Peels', 'Cores']),
    Crop(name: 'Grapes', wastes: ['Stems', 'Peels']),
    Crop(name: 'Orange', wastes: ['Peels', 'Pulp']),
    Crop(name: 'Lemon', wastes: ['Peels', 'Pulp']),
    Crop(name: 'Pineapple', wastes: ['Peels', 'Leaves']),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Crop'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 1,
          ),
          itemCount: crops.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WasteSelectionScreen(crops[index]),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: Center(
                  child: Text(
                    crops[index].name,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Crop {
  final String name;
  final List<String> wastes;

  Crop({required this.name, required this.wastes});
}

class WasteSelectionScreen extends StatefulWidget {
  final Crop selectedCrop;

  WasteSelectionScreen(this.selectedCrop);

  @override
  _WasteSelectionScreenState createState() => _WasteSelectionScreenState();
}

class _WasteSelectionScreenState extends State<WasteSelectionScreen> {
  String? selectedWaste;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Waste'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 1,
                ),
                itemCount: widget.selectedCrop.wastes.length,
                itemBuilder: (context, index) {
                  final waste = widget.selectedCrop.wastes[index];
                  final bool isSelected = selectedWaste == waste;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedWaste = waste;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          waste,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedWaste != null) {
                _submitData(widget.selectedCrop.name, selectedWaste!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a waste option')),
                );
              }
            },
            child: Text('Submit'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitData(String crop, String waste) async {
    final url = Uri.parse('http://127.0.0.1:5000/submit_waste');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'crop': crop, 'waste': waste}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final cleanedPredictedCrops =
            (responseData['predicted_crops'] as List<dynamic>)
                .map((crop) =>
                    crop.toString().replaceAll('*', '').replaceAll('#', ''))
                .toList();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultsPage(cleanedPredictedCrops),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class ResultsPage extends StatelessWidget {
  final List<String> predictedCrops;

  ResultsPage(this.predictedCrops);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: Center(
        child: predictedCrops.isNotEmpty
            ? SingleChildScrollView(
                child: _buildResultCards(predictedCrops[0]),
              )
            : Text('No predictions available'),
      ),
    );
  }

  Widget _buildResultCards(String resultText) {
    // Regular expression to split text on any integer followed by a space or punctuation
    List<String> components = resultText.split(RegExp(r'(?<=\d[\s.,:])'));

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
              components[index].trim(),
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
