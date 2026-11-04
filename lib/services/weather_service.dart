import 'dart:convert';
import 'api_config.dart';
import 'package:driver_pos/services/api_http.dart' as http;

class WeatherService {
  static Future<Map<String, dynamic>> fetchWeather(double lat, double lon,
      {http.Client? client,
      bool? useProxy,
      String? apiKey,
      String? baseUrl}) async {
    final proxy = useProxy ?? ApiConfig.useWeatherProxy;
    final url = proxy
        ? Uri.parse('${baseUrl ?? ApiConfig.baseUrl}/public/weather').replace(
            queryParameters: {
                'lat': '$lat',
                'lon': '$lon',
                'units': 'imperial'
              })
        : Uri.https('api.openweathermap.org', '/data/2.5/weather', {
            'lat': '$lat',
            'lon': '$lon',
            'units': 'imperial',
            'appid': apiKey ?? ApiConfig.weatherApiKey
          });
    final response = await (client?.get(url) ?? http.get(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load weather data');
    }
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }
}
