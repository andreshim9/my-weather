import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/weather_model.dart';

class WeatherService {
  final http.Client _client = http.Client();

  /// 위치 기반 실시간 날씨 & 7일 주간 예보 조회
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.openMeteoEndpoint}?'
        'latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m'
        '&hourly=temperature_2m,weather_code'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,uv_index_max'
        '&timezone=auto',
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data, locationName);
      } else {
        return WeatherModel.mock(locationName);
      }
    } catch (e) {
      return WeatherModel.mock(locationName);
    }
  }
}
