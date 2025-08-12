// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String weatherDescription = '';
  double temperature = 0.0;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final position = await LocationService.getCurrentLocation();
      final weather = await WeatherService.fetchWeather(
        position.latitude,
        position.longitude,
      );

      setState(() {
        weatherDescription = weather['weather'][0]['description'];
        temperature = weather['main']['temp'];
      });
    } catch (e) {
      print("❗ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Info')),
      body: Center(
        child: weatherDescription.isEmpty
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🌤 $weatherDescription',
                      style: const TextStyle(fontSize: 24)),
                  Text('🌡 $temperature°F',
                      style: const TextStyle(fontSize: 20)),
                ],
              ),
      ),
    );
  }
}
