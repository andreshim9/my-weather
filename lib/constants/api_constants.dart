/// 공공데이터포털 및 외부 API 상수 정의
class ApiConstants {
  // 공공데이터포털 인코딩/디코딩 API KEY
  static const String dataGoKrApiKey =
      'zvLquy9e8csAaIEOQIew66aHufdkglL%2BjBttslQW4A1iGtSNEpZIrB523LswGa4RuHNj4Kz0lI00UqG4CK9XEg%3D%3D';

  // 전국 동물병원 정보 API 엔드포인트
  static const String animalHospitalEndpoint =
      'https://apis.data.go.kr/1741000/animal_hospitals';

  // 한국관광공사 반려동물 동반 여행 정보 API 엔드포인트
  static const String korPetTourEndpoint =
      'https://apis.data.go.kr/B551011/KorPetTourService2';

  // Open-Meteo 날씨 API (무료 및 전세계 좌표 지원, 일출일몰 검증용)
  static const String openMeteoEndpoint =
      'https://api.open-meteo.com/v1/forecast';

  // 홈 위젯 키 상수
  static const String appGroupId = 'group.com.example.pet_weather_widget';
  static const String widgetWeatherSunProvider = 'WeatherSunWidgetProvider';
  static const String widgetWalkGoldenProvider = 'WalkGoldenWidgetProvider';
  static const String widgetThreeDaysProvider = 'ThreeDaysForecastWidgetProvider';
  static const String widgetPetTourProvider = 'PetTourWidgetProvider';
}
