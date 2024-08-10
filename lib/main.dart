import 'package:crop/authpage.dart';
import 'package:crop/fertilizer.dart';
import 'package:crop/screens/feed_screen.dart';
import 'package:crop/screens/upload_post_screen.dart';
import 'package:crop/waste_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'disease_detection.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'weather.dart';
import 'weather_service.dart';
import 'location_services.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'post_page.dart';
import 'firebase_options.dart';
import 'cultivation_tips.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crop/utils/widgets.dart';
import 'package:crop/screens/add_post_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class AgroShopLocatorPage extends StatefulWidget {
  @override
  _AgroShopLocatorPageState createState() => _AgroShopLocatorPageState();
}

class _AgroShopLocatorPageState extends State<AgroShopLocatorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Up Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      routes: {
        '/upload': (context) => UploadPostScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final double horizontalPadding = 40;
  final double verticalPadding = 25;
  final user = FirebaseAuth.instance.currentUser!;
  final WeatherService weatherService = WeatherService();
  final LocationService locationService = LocationService();
  late Future<Weather> futureWeather;
  int _screenIndex = 0; // To keep track of the selected tab
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  List mySmartDevices = [
    // [ smartDeviceName, iconPath , powerStatus ]
    ["Go to Disease Detection", "lib/images/icons8-disease-48.png"],
    ["Crop Analysis", "lib/images/icons8-crop-64.png"],
    ["Waste Management", "lib/images/icons8-waste-48.png"],
    ["Fertilizer Calculator", "lib/images/icons8-fertilizer-60.png"],
    ["Cultivation Tips", "lib/images/icons8-tips-64.png"],
  ];

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  void _getWeather() async {
    try {
      final position = await locationService.getCurrentLocation();
      setState(() {
        futureWeather =
            weatherService.fetchWeather(position.latitude, position.longitude);
      });
    } catch (error) {
      setState(() {
        futureWeather = Future.error(error.toString());
      });
    }
  }

  List<Widget> _screens() => [_homeContent(), FeedScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens().elementAt(_screenIndex),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            gap: 8,
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            padding: EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.people,
                text: 'Community',
              ),
              GButton(
                icon: Icons.shop,
                text: 'Shops',
              ),
              GButton(
                icon: Icons.person,
                text: 'You',
              ),
            ],
            selectedIndex: _screenIndex,
            onTabChange: (index) {
              setState(() {
                _screenIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _homeContent() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Agriculture App'),
      ),
      body: Stack(
        children: [
          // Background image
          // Positioned.fill(
          //   child: Image.asset(
          //     '',
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 5,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.holiday_village,
                        size: 45,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Home,',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Text('User!', style: TextStyle(fontSize: 40.0)),
                        ],
                      ),
                      GestureDetector(
                        // onTap: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => WeatherDetailPage(), // Replace with your weather detail page
                        //     ),
                        //   );
                        // },
                        child: FutureBuilder<Weather>(
                          future: futureWeather,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData) {
                              return Text('No weather data');
                            } else {
                              final weather = snapshot.data!;
                              return Column(
                                children: [
                                  Text(
                                    weather.cityName,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${weather.temperature}°C',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    weather.description,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: Divider(
                    thickness: 1,
                    color: Color.fromARGB(255, 204, 204, 204),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    "Tools",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    itemCount: mySmartDevices.length,
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1 / 1.3,
                    ),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          SmartDeviceBox(
                              smartDeviceName: mySmartDevices[index][0],
                              iconPath: mySmartDevices[index][1]),
                          ElevatedButton(
                            onPressed: () {
                              switch (index) {
                                case 0:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DiseaseDetectionPage()),
                                  );
                                  break;
                                case 1:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyHomePage()),
                                  );
                                  break;
                                case 2:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CropSelectionScreen()),
                                  );
                                  break;
                                case 3:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FertilizerCalculatorPage()),
                                  );
                                  break;
                                case 4:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CultivationTipsPage()),
                                  );
                                  break;
                              }
                            },
                            child: Text(mySmartDevices[index][0]),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  String soilType = 'Sandy';
  String soilPh = '1';

  String soilMoisture = 'Low';

  final List<String> soilTypes = ['Sandy', 'Loamy', 'Clay'];
  final List<String> soilPhValues =
      List<String>.generate(14, (index) => (index + 1).toString());
  final List<String> soilMoistureLevels = ['Low', 'Medium', 'High'];

  Future<void> _submitData() async {
    final url = Uri.parse('http://127.0.0.1:5000/predict_crops');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'soil_ph': soilPh,
        'soil_type': soilType,
        'soil_moisture': soilMoisture,
      }),
    );

    final responseData = json.decode(response.body);

    // Clean the response data
    final cleanedPredictedCrops = (responseData['predicted_crops']
            as List<dynamic>)
        .map((crop) => crop.toString().replaceAll('*', '').replaceAll('#', ''))
        .toList();

    if (response.statusCode == 200) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PredictionResultScreen(cleanedPredictedCrops),
        ),
      );
    } else {
      // Handle error response
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to get prediction. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: soilType,
                decoration: const InputDecoration(labelText: 'Soil Type'),
                items: soilTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    soilType = newValue!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: soilPh,
                decoration: const InputDecoration(labelText: 'Soil pH'),
                items: soilPhValues.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    soilPh = newValue!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: soilMoisture,
                decoration: const InputDecoration(labelText: 'Soil Moisture'),
                items: soilMoistureLevels.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    soilMoisture = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _submitData();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class PredictionResultScreen extends StatelessWidget {
  final List<dynamic> predictedCrops;

  PredictionResultScreen(this.predictedCrops);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Predicted Crops')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Suitable Crops for Your Soil:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  color:
                      Colors.lightGreen[100], // Set card color to green shade
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      _buildCombinedResultText(predictedCrops),
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildCombinedResultText(List<dynamic> crops) {
    return crops.join('\n\n');
  }
}
