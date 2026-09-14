import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_item.dart';
import '../models/month_sun_day_model.dart';
import '../models/sun_time_model.dart';
import '../models/weather_model.dart';
import '../services/sun_calc_service.dart';
import '../services/weather_service.dart';
import '../services/widget_service.dart';

enum ViewMode { day, week, month }

class AppStateProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  // State Variables
  bool _isLoading = true;
  bool _isDarkMode = true; // 기본값 다크 테마
  double _fontScale = 1.0; // 글자 크기 배율 (0.85, 1.0, 1.15, 1.30)
  String? _errorMessage;
  double _latitude = 37.5665; // 기본: 서울
  double _longitude = 126.9780;
  String _currentLocationName = '서울특별시';
  bool _isCustomLocation = false;

  List<LocationItem> _savedLocations = [];

  ViewMode _viewMode = ViewMode.day;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  MonthSunDayModel? _selectedCalendarDay;

  WeatherModel? _weather;
  SunTimeModel? _sunTime;
  List<MonthSunDayModel> _weekSunDays = [];
  List<MonthSunDayModel> _monthSunDays = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  double get fontScale => _fontScale;
  String? get errorMessage => _errorMessage;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get currentLocationName => _currentLocationName;
  bool get isCustomLocation => _isCustomLocation;
  List<LocationItem> get savedLocations => _savedLocations;

  ViewMode get viewMode => _viewMode;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  MonthSunDayModel? get selectedCalendarDay => _selectedCalendarDay;

  WeatherModel? get weather => _weather;
  SunTimeModel? get sunTime => _sunTime;
  List<MonthSunDayModel> get weekSunDays => _weekSunDays;
  List<MonthSunDayModel> get monthSunDays => _monthSunDays;

  AppStateProvider() {
    initData();
  }

  /// 글자 크기 배율 변경 및 저장
  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('font_scale', scale);
    } catch (_) {}
  }

  /// 화이트/다크 테마 토글
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', _isDarkMode);
    } catch (_) {}
  }

  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void selectCalendarDay(MonthSunDayModel day) {
    _selectedCalendarDay = day;
    notifyListeners();
  }

  void changeMonth(int year, int month) {
    _selectedYear = year;
    _selectedMonth = month;
    _calculateMonthData();
    notifyListeners();
  }

  /// 사용자가 원하는 지정 위치로 변경 및 저장
  Future<void> setCustomLocation({
    required double latitude,
    required double longitude,
    required String locationName,
    String? description,
    bool autoSave = true,
  }) async {
    _latitude = latitude;
    _longitude = longitude;
    _currentLocationName = locationName;
    _isCustomLocation = true;

    if (autoSave) {
      final item = LocationItem(
        name: locationName,
        description: description ?? '지정한 위치',
        latitude: latitude,
        longitude: longitude,
      );
      await addSavedLocation(item);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('custom_lat', latitude);
      await prefs.setDouble('custom_lon', longitude);
      await prefs.setString('custom_name', locationName);
      await prefs.setBool('is_custom_loc', true);
    } catch (_) {}

    await refreshAllData();
  }

  /// 내가 저장한 위치에 추가
  Future<void> addSavedLocation(LocationItem item) async {
    if (!_savedLocations.any((loc) => loc.name == item.name)) {
      _savedLocations.insert(0, item);
      notifyListeners();
      await _persistSavedLocations();
    }
  }

  /// 내가 저장한 위치에서 삭제
  Future<void> removeSavedLocation(LocationItem item) async {
    _savedLocations.removeWhere((loc) => loc.name == item.name);
    notifyListeners();
    await _persistSavedLocations();
  }

  Future<void> _persistSavedLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = _savedLocations.map((e) => e.toJson()).toList();
      await prefs.setString('saved_locations_json', json.encode(listJson));
    } catch (_) {}
  }

  /// 내 현재 GPS 위치로 복귀
  Future<void> useCurrentGpsLocation() async {
    _isCustomLocation = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_custom_loc', false);
    } catch (_) {}

    await _fetchLocation();
    await refreshAllData();
  }

  /// 초기 데이터 로드
  Future<void> initData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
      _fontScale = prefs.getDouble('font_scale') ?? 1.0;

      // 저장된 위치 목록 복원
      final savedStr = prefs.getString('saved_locations_json');
      if (savedStr != null) {
        final List<dynamic> decoded = json.decode(savedStr);
        _savedLocations = decoded.map((d) => LocationItem.fromJson(d)).toList();
      }

      final isCustom = prefs.getBool('is_custom_loc') ?? false;
      if (isCustom) {
        _latitude = prefs.getDouble('custom_lat') ?? 37.5665;
        _longitude = prefs.getDouble('custom_lon') ?? 126.9780;
        _currentLocationName = prefs.getString('custom_name') ?? '서울특별시';
        _isCustomLocation = true;
      } else {
        await _fetchLocation();
      }
    } catch (_) {
      await _fetchLocation();
    }

    await refreshAllData();
  }

  /// GPS 위치 가져오기 및 주소 변환
  Future<void> _fetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 5),
    );

    _latitude = position.latitude;
    _longitude = position.longitude;

    if (!kIsWeb) {
      try {
        final placemarks = await placemarkFromCoordinates(_latitude, _longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final admin = p.administrativeArea ?? '';
          final locality = p.locality ?? p.subLocality ?? p.thoroughfare ?? '';
          _currentLocationName = '$admin $locality'.trim();
          if (_currentLocationName.isEmpty) {
            _currentLocationName = '내 위치';
          }
        }
      } catch (_) {
        _currentLocationName = '내 위치';
      }
    } else {
      _currentLocationName = '내 위치 (GPS)';
    }
  }

  /// 모든 데이터 (날씨, 일출몰 일/주/월 데이터) 새로고침
  Future<void> refreshAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. 오늘의 일출일몰 계산
      _sunTime = SunCalcService.calculateSunTimes(
        latitude: _latitude,
        longitude: _longitude,
      );

      // 2. 일주일(7일간) 일출일몰 계산
      _weekSunDays = SunCalcService.calculateSunTimesForRange(
        latitude: _latitude,
        longitude: _longitude,
        startDate: DateTime.now(),
        days: 7,
      );

      // 3. 한달(월간 30일) 일출일몰 계산
      _calculateMonthData();

      // 4. 날씨 & 주간 예보 조회
      _weather = await _weatherService.fetchWeather(
        latitude: _latitude,
        longitude: _longitude,
        locationName: _currentLocationName,
      );

      // 5. 홈 위젯 동기화
      if (_weather != null && _sunTime != null) {
        await WidgetService.updateAllWidgets(
          weather: _weather!,
          sunTime: _sunTime!,
          weekSunDays: _weekSunDays,
        );
      }
    } catch (e) {
      _errorMessage = '데이터를 불러오는 중 오류가 발생했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateMonthData() {
    _monthSunDays = SunCalcService.calculateSunTimesForMonth(
      latitude: _latitude,
      longitude: _longitude,
      year: _selectedYear,
      month: _selectedMonth,
    );

    final now = DateTime.now();
    if (_selectedYear == now.year && _selectedMonth == now.month) {
      _selectedCalendarDay = _monthSunDays.firstWhere(
        (d) => d.date.day == now.day,
        orElse: () => _monthSunDays.first,
      );
    } else if (_monthSunDays.isNotEmpty) {
      _selectedCalendarDay = _monthSunDays.first;
    }
  }
}
