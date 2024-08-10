// services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather.dart';

class WeatherService {
  static const String apiKey = '2810cf148234adc72f50378cb0a018c8';
  static const String apiUrl = 'http://api.openweathermap.org/data/2.5/weather';

  Future<Weather> fetchWeather(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        '$apiUrl?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
