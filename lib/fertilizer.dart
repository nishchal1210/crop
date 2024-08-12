import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FertilizerCalculatorPage extends StatefulWidget {
  @override
  _FertilizerCalculatorPageState createState() =>
      _FertilizerCalculatorPageState();
}

class ResultsPage extends StatelessWidget {
  final String geminiResponse;

  ResultsPage({required this.geminiResponse});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fertilizer Calculation Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: _buildResponseCards(geminiResponse),
        ),
      ),
    );
  }

  Widget _buildResponseCards(String responseText) {
    // Split the response based on the markers **1, **2, **3
    RegExp sectionRegex = RegExp(r'\*\*\d\.\s.*?(?=\*\*\d\.|$)', dotAll: true);
    Iterable<RegExpMatch> matches = sectionRegex.allMatches(responseText);

    List<Map<String, String>> sections = [];

    for (var match in matches) {
      String sectionText = match.group(0)!.trim();
      String title = sectionText.split('\n').first.trim();
      String content = sectionText
          .substring(title.length)
          .trim()
          .replaceAll('*', ''); // Remove * characters
      sections.add({'title': title, 'content': content});
    }

    // Swap sorting to place **1 at the top and **2 after
    sections.sort((a, b) {
      if (a['title']!.contains('**1')) {
        return -1;
      } else if (b['title']!.contains('**1')) {
        return 1;
      } else {
        return 0;
      }
    });

    return Column(
      children: sections.map((section) {
        bool isGreenCard = section['title']!.contains('**1');
        Color cardColor = isGreenCard ? Colors.green[100]! : Colors.blue[100]!;

        return Card(
          margin: EdgeInsets.symmetric(
              vertical: 25.0, horizontal: 8.0), // Increased margin
          color: cardColor,
          child: Container(
            padding: EdgeInsets.all(
                isGreenCard ? 30.0 : 16.0), // Increased padding for green card
            constraints: isGreenCard
                ? BoxConstraints(
                    minHeight: 200.0) // Set minimum height for green card
                : BoxConstraints(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section['title']!.replaceAll('**', ''),
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  section['content']!,
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FertilizerCalculatorPageState extends State<FertilizerCalculatorPage> {
  String _selectedCrop = 'Bean';
  double _plotSize = 5.0;
  double _n = 50;
  double _p = 50;
  double _k = 25;
  String _selectedUnit = 'Acre';

  bool _isLoading = false;

  List<Map<String, String>> crops = [
    {'name': 'Bean', 'image': 'lib/images/icons8-bean-60.png'},
    {'name': 'Citrus', 'image': 'lib/images/icons8-citrus-50.png'},
    {'name': 'Cotton', 'image': 'lib/images/icons8-cotton-64.png'},
    {'name': 'Cucumber', 'image': 'lib/images/icons8-cucumber-48.png'},
    {'name': 'Ginger', 'image': 'lib/images/icons8-ginger-48.png'},
    {'name': 'Grape', 'image': 'lib/images/icons8-grape-96.png'},
    {'name': 'Maize', 'image': 'lib/images/icons8-maize-48.png'},
    {'name': 'Mango', 'image': 'lib/images/icons8-mango-96.png'},
    {'name': 'Melon', 'image': 'lib/images/icons8-melon-96.png'},
    {'name': 'Millet', 'image': 'lib/images/icons8-millet-100.png'},
    {'name': 'Okra', 'image': 'lib/images/icons8-okra-67.png'},
    {'name': 'Onion', 'image': 'lib/images/icons8-onion-96.png'},
    {'name': 'Papaya', 'image': 'lib/images/icons8-papaya-96.png'},
    {'name': 'Peanut', 'image': 'lib/images/icons8-peanut-64.png'},
    {'name': 'Pea', 'image': 'lib/images/icons8-pea-64.png'},
    {'name': 'Potato', 'image': 'lib/images/icons8-potato-96.png'},
  ];

  List<Map<String, String>> _filteredCrops = [];

  String? _geminiResponse;

  @override
  void initState() {
    super.initState();
    _filteredCrops = crops;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fertilizer Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Selected Crop: $_selectedCrop'),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: _showCropSelectionDialog,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _n.toString(),
                    decoration:
                        InputDecoration(labelText: 'Nutrient N (kg/ha)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _n = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: _p.toString(),
                    decoration:
                        InputDecoration(labelText: 'Nutrient P (kg/ha)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _p = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: _k.toString(),
                    decoration:
                        InputDecoration(labelText: 'Nutrient K (kg/ha)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _k = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Radio<String>(
                  value: 'Acre',
                  groupValue: _selectedUnit,
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                    });
                  },
                ),
                Text('Acre'),
                Radio<String>(
                  value: 'Hectare',
                  groupValue: _selectedUnit,
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                    });
                  },
                ),
                Text('Hectare'),
                Radio<String>(
                  value: 'Square Meter',
                  groupValue: _selectedUnit,
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                    });
                  },
                ),
                Text('Square Meter'),
              ],
            ),
            TextFormField(
              initialValue: _plotSize.toString(),
              decoration: InputDecoration(
                labelText: 'Plot Size ($_selectedUnit)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _plotSize = double.tryParse(value) ?? 0.0;
              },
            ),
            SizedBox(height: 40),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _calculateFertilizer,
                    child: Text('Calculate'),
                  ),
          ],
        ),
      ),
    );
  }

  void _showCropSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Crop'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: 'Search Crop'),
                onChanged: (value) {
                  setState(() {
                    _filteredCrops = crops
                        .where((crop) => crop['name']!
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredCrops.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.asset(_filteredCrops[index]['image']!),
                      title: Text(_filteredCrops[index]['name']!),
                      onTap: () {
                        setState(() {
                          _selectedCrop = _filteredCrops[index]['name']!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _calculateFertilizer() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/calculate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'crop': _selectedCrop,
        'n': _n,
        'p': _p,
        'k': _k,
        'plot_size': _plotSize,
        'unit': _selectedUnit,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      String geminiResponse = jsonDecode(response.body)['gemini_response'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(geminiResponse: geminiResponse),
        ),
      );
    } else {
      _showErrorDialog('Failed to calculate fertilizer. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
