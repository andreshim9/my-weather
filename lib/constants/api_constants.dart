/// 공공데이터 및 외부 API 설정
class ApiConstants {
  // Open-Meteo 날씨 API (무료 및 전세계 좌표 지원)
  static const String openMeteoEndpoint = 'https://api.open-meteo.com/v1/forecast';

  // 홈 위젯 키 상수
  static const String appGroupId = 'group.com.example.pet_weather_widget';
  static const String widgetWeatherSunProvider = 'WeatherSunWidgetProvider';
  static const String widgetWalkGoldenProvider = 'WalkGoldenWidgetProvider';
  static const String widgetThreeDaysProvider = 'ThreeDaysForecastWidgetProvider';
}
