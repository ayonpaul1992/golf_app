import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = '3795744d43a72c72b4cac99cd2c6ad52';

  static Future<Map<String, dynamic>> fetchWeather(
      double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$_apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print("🌤 Weather data fetched successfully ${response.body}");
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
