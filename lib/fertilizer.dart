import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FertilizerCalculatorPage extends StatefulWidget {
  @override
  _FertilizerCalculatorPageState createState() =>
      _FertilizerCalculatorPageState();
}

class _FertilizerCalculatorPageState extends State<FertilizerCalculatorPage> {
  String _selectedCrop = 'Bean';
  double _plotSize = 5.0;
  double _n = 50;
  double _p = 50;
  double _k = 25;
  String _selectedUnit = 'Acre';

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

  Map<String, dynamic>? _fertilizerResults;

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
                    decoration: InputDecoration(labelText: 'Nutrient N'),
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
                    decoration: InputDecoration(labelText: 'Nutrient P'),
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
                    decoration: InputDecoration(labelText: 'Nutrient K'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _k = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
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
                  value: 'Gunta',
                  groupValue: _selectedUnit,
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                    });
                  },
                ),
                Text('Gunta'),
              ],
            ),
            TextFormField(
              initialValue: _plotSize.toString(),
              decoration:
                  InputDecoration(labelText: 'Plot Size ($_selectedUnit)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _plotSize = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateFertilizer,
              child: Text('Calculate'),
            ),
            SizedBox(height: 20),
            _fertilizerResults != null
                ? _buildFertilizerResult()
                : Text('No results yet'),
          ],
        ),
      ),
    );
  }

  void _showCropSelectionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
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
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                children: _filteredCrops.map((crop) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCrop = crop['name']!;
                      });
                      Navigator.pop(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          crop['image']!,
                          width: 40,
                          height: 40,
                        ),
                        Text(crop['name']!),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFertilizerResult() {
    if (_fertilizerResults == null) return Text('No results yet');

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Fertilizer Amounts (for one season):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildFertilizerRow(
                'Urea',
                _fertilizerResults!['Urea']?['kg'] ?? '0.0',
                'kg',
                _fertilizerResults!['Urea']?['bags'] ?? '0.0',
                'bags'),
            SizedBox(height: 10),
            _buildFertilizerRow(
                'SSP',
                _fertilizerResults!['SSP']?['kg'] ?? '0.0',
                'kg',
                _fertilizerResults!['SSP']?['bags'] ?? '0.0',
                'bags'),
            SizedBox(height: 10),
            _buildFertilizerRow(
                'MOP',
                _fertilizerResults!['MOP']?['kg'] ?? '0.0',
                'kg',
                _fertilizerResults!['MOP']?['bags'] ?? '0.0',
                'bags'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to product finding page or perform another action
              },
              child: Text('Find Products'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFertilizerRow(
      String name, String kg, String kgUnit, String bags, String bagUnit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: TextStyle(fontSize: 16)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$kg $kgUnit'),
            Text('$bags $bagUnit'),
          ],
        ),
      ],
    );
  }

  void _calculateFertilizer() async {
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

    if (response.statusCode == 200) {
      setState(() {
        _fertilizerResults = jsonDecode(response.body);
      });
    } else {
      _showErrorDialog('Failed to calculate fertilizer. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
