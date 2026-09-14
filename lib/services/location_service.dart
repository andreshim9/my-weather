import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_item.dart';

class LocationService {
  final http.Client _client = http.Client();

  /// Open-Meteo Geocoding API를 활용한 실시간 위치 검색
  Future<List<LocationItem>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      final uri = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?'
        'name=${Uri.encodeComponent(trimmed)}'
        '&count=15'
        '&language=ko'
        '&format=json',
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['results'] is List) {
          final List<LocationItem> list = (data['results'] as List)
              .map((item) => LocationItem.fromJson(item))
              .toList();
          return list;
        }
      }
    } catch (_) {}

    return [];
  }
}
