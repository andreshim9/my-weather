class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final int weatherCode;
  final String weatherDescription;
  final String weatherIcon;
  final int precipitationProbability;
  final double uvIndex;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.weatherCode,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.precipitationProbability,
    required this.uvIndex,
  });
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final String weatherIcon;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.weatherIcon,
  });
}

class WeatherModel {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final String weatherDescription;
  final String weatherIcon;
  final int precipitationProbability;
  final double uvIndex;
  final String locationName;
  final DateTime updatedAt;
  final List<DailyForecast> dailyForecasts;
  final List<HourlyForecast> hourlyForecasts;

  WeatherModel({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.precipitationProbability,
    required this.uvIndex,
    required this.locationName,
    required this.updatedAt,
    required this.dailyForecasts,
    required this.hourlyForecasts,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String location) {
    final current = json['current'] ?? {};
    final daily = json['daily'] ?? {};
    final hourly = json['hourly'] ?? {};

    final code = (current['weather_code'] as num?)?.toInt() ?? 0;
    final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 20.0;
    final appTemp = (current['apparent_temperature'] as num?)?.toDouble() ?? temp;
    final hum = (current['relative_humidity_2m'] as num?)?.toInt() ?? 50;
    final wind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 2.0;

    final maxUv = (daily['uv_index_max'] is List && (daily['uv_index_max'] as List).isNotEmpty)
        ? (daily['uv_index_max'][0] as num).toDouble()
        : 3.5;
    final precipProb = (daily['precipitation_probability_max'] is List && (daily['precipitation_probability_max'] as List).isNotEmpty)
        ? (daily['precipitation_probability_max'][0] as num).toInt()
        : 0;

    final info = _interpretWeatherCode(code);

    // 7일간 일별 예보 파싱
    final List<DailyForecast> dailyList = [];
    if (daily['time'] is List) {
      final times = daily['time'] as List;
      final maxTemps = daily['temperature_2m_max'] as List? ?? [];
      final minTemps = daily['temperature_2m_min'] as List? ?? [];
      final codes = daily['weather_code'] as List? ?? [];
      final precips = daily['precipitation_probability_max'] as List? ?? [];
      final uvs = daily['uv_index_max'] as List? ?? [];

      for (int i = 0; i < times.length && i < 7; i++) {
        final dTime = DateTime.tryParse(times[i].toString()) ?? DateTime.now().add(Duration(days: i));
        final dCode = (i < codes.length) ? (codes[i] as num).toInt() : code;
        final dInfo = _interpretWeatherCode(dCode);

        dailyList.add(DailyForecast(
          date: dTime,
          maxTemp: (i < maxTemps.length) ? (maxTemps[i] as num).toDouble() : temp + 2,
          minTemp: (i < minTemps.length) ? (minTemps[i] as num).toDouble() : temp - 5,
          weatherCode: dCode,
          weatherDescription: dInfo['desc'] ?? '맑음',
          weatherIcon: dInfo['icon'] ?? '☀️',
          precipitationProbability: (i < precips.length) ? (precips[i] as num).toInt() : 0,
          uvIndex: (i < uvs.length) ? (uvs[i] as num).toDouble() : 3.0,
        ));
      }
    }

    // 24시간 시간별 예보 파싱
    final List<HourlyForecast> hourlyList = [];
    if (hourly['time'] is List) {
      final hTimes = hourly['time'] as List;
      final hTemps = hourly['temperature_2m'] as List? ?? [];
      final hCodes = hourly['weather_code'] as List? ?? [];
      final now = DateTime.now();

      for (int i = 0; i < hTimes.length; i++) {
        final hTime = DateTime.tryParse(hTimes[i].toString());
        if (hTime != null && hTime.isAfter(now.subtract(const Duration(hours: 1)))) {
          final hCode = (i < hCodes.length) ? (hCodes[i] as num).toInt() : 0;
          final hInfo = _interpretWeatherCode(hCode);
          hourlyList.add(HourlyForecast(
            time: hTime,
            temperature: (i < hTemps.length) ? (hTemps[i] as num).toDouble() : temp,
            weatherCode: hCode,
            weatherIcon: hInfo['icon'] ?? '☀️',
          ));
          if (hourlyList.length >= 24) break;
        }
      }
    }

    return WeatherModel(
      temperature: temp,
      apparentTemperature: appTemp,
      humidity: hum,
      windSpeed: wind,
      weatherCode: code,
      weatherDescription: info['desc'] ?? '맑음',
      weatherIcon: info['icon'] ?? '☀️',
      precipitationProbability: precipProb,
      uvIndex: maxUv,
      locationName: location,
      updatedAt: DateTime.now(),
      dailyForecasts: dailyList.isNotEmpty ? dailyList : _mockDailyList(),
      hourlyForecasts: hourlyList.isNotEmpty ? hourlyList : _mockHourlyList(temp),
    );
  }

  static Map<String, String> _interpretWeatherCode(int code) {
    switch (code) {
      case 0:
        return {'desc': '맑음', 'icon': '☀️'};
      case 1:
      case 2:
      case 3:
        return {'desc': '구름조금/흐림', 'icon': '⛅'};
      case 45:
      case 48:
        return {'desc': '안개', 'icon': '🌫️'};
      case 51:
      case 53:
      case 55:
        return {'desc': '이슬비', 'icon': '🌦️'};
      case 61:
      case 63:
      case 65:
        return {'desc': '비', 'icon': '🌧️'};
      case 71:
      case 73:
      case 75:
        return {'desc': '눈', 'icon': '❄️'};
      case 80:
      case 81:
      case 82:
        return {'desc': '소나기', 'icon': '🌦️'};
      case 95:
      case 96:
      case 99:
        return {'desc': '뇌우', 'icon': '⛈️'};
      default:
        return {'desc': '맑음', 'icon': '☀️'};
    }
  }

  static List<DailyForecast> _mockDailyList() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.add(Duration(days: i));
      return DailyForecast(
        date: date,
        minTemp: 18.0 + (i % 3),
        maxTemp: 26.0 + (i % 4),
        weatherCode: i % 2 == 0 ? 0 : 2,
        weatherDescription: i % 2 == 0 ? '맑음' : '구름조금',
        weatherIcon: i % 2 == 0 ? '☀️' : '⛅',
        precipitationProbability: i % 2 == 0 ? 10 : 30,
        uvIndex: 4.5,
      );
    });
  }

  static List<HourlyForecast> _mockHourlyList(double currentTemp) {
    final now = DateTime.now();
    return List.generate(24, (i) {
      final time = now.add(Duration(hours: i));
      return HourlyForecast(
        time: time,
        temperature: currentTemp + (i > 6 && i < 16 ? 3.0 : -2.0),
        weatherCode: 0,
        weatherIcon: (time.hour >= 6 && time.hour <= 18) ? '☀️' : '🌙',
      );
    });
  }

  factory WeatherModel.mock(String location) {
    return WeatherModel(
      temperature: 23.5,
      apparentTemperature: 24.1,
      humidity: 55,
      windSpeed: 2.1,
      weatherCode: 0,
      weatherDescription: '맑음',
      weatherIcon: '☀️',
      precipitationProbability: 10,
      uvIndex: 4.2,
      locationName: location,
      updatedAt: DateTime.now(),
      dailyForecasts: _mockDailyList(),
      hourlyForecasts: _mockHourlyList(23.5),
    );
  }
}
