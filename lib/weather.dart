// models/weather.dart
class Weather {
  final String description;
  final double temperature;
  final String cityName;

  Weather(
      {required this.description,
      required this.temperature,
      required this.cityName});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['weather'][0]['description'],
      temperature: json['main']['temp'],
      cityName: json['name'],
    );
  }
}
