import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../constants/api_constants.dart';
import '../models/month_sun_day_model.dart';
import '../models/sun_time_model.dart';
import '../models/weather_model.dart';

/// 안드로이드 홈 화면 바탕화면 위젯 동기화 서비스
class WidgetService {
  /// 모든 바탕화면 위젯 데이터 갱신 및 Native AppWidget 업데이트 트리거
  static Future<void> updateAllWidgets({
    required WeatherModel weather,
    required SunTimeModel sunTime,
    List<MonthSunDayModel>? weekSunDays,
  }) async {
    if (kIsWeb) return;

    try {
      final timeFormatter = DateFormat('HH:mm');
      final dateFormatter = DateFormat('M월 d일 (E)', 'ko_KR');
      final dayFormat = DateFormat('M/d(E)', 'ko_KR');
      final now = DateTime.now();
      final dayLength = sunTime.sunset.difference(sunTime.sunrise);
      final dayLengthStr = '시간 분';

      // 1. 단일 날씨 & 일출몰 데이터 저장
      await HomeWidget.saveWidgetData<String>('weather_location', weather.locationName);
      await HomeWidget.saveWidgetData<String>('weather_temp', '°C');
      await HomeWidget.saveWidgetData<String>('weather_condition', ' ');
      await HomeWidget.saveWidgetData<String>('sun_sunrise', timeFormatter.format(sunTime.sunrise));
      await HomeWidget.saveWidgetData<String>('sun_sunset', timeFormatter.format(sunTime.sunset));
      await HomeWidget.saveWidgetData<String>('sun_noon', timeFormatter.format(sunTime.solarNoon));
      await HomeWidget.saveWidgetData<String>('sun_day_length', dayLengthStr);
      await HomeWidget.saveWidgetData<String>('widget_date', dateFormatter.format(now));

      // 2. 3일간 예보 데이터 저장 (오늘, 내일, 모레)
      for (int i = 0; i < 3; i++) {
        final prefix = 'day_';
        if (i < weather.dailyForecasts.length) {
          final df = weather.dailyForecasts[i];
          await HomeWidget.saveWidgetData<String>('date', i == 0 ? '오늘' : (i == 1 ? '내일' : '모레'));
          await HomeWidget.saveWidgetData<String>('subdate', dayFormat.format(df.date));
          await HomeWidget.saveWidgetData<String>('icon', df.weatherIcon);
          await HomeWidget.saveWidgetData<String>('desc', df.weatherDescription);
          await HomeWidget.saveWidgetData<String>('temp', '° / °');
        }

        if (weekSunDays != null && i < weekSunDays.length) {
          final s = weekSunDays[i];
          await HomeWidget.saveWidgetData<String>('sunrise', timeFormatter.format(s.sunrise));
          await HomeWidget.saveWidgetData<String>('sunset', timeFormatter.format(s.sunset));
        }
      }

      // 3. Android AppWidget 업데이트 요청
      await HomeWidget.updateWidget(
        name: ApiConstants.widgetWeatherSunProvider,
        androidName: ApiConstants.widgetWeatherSunProvider,
      );
      await HomeWidget.updateWidget(
        name: ApiConstants.widgetWalkGoldenProvider,
        androidName: ApiConstants.widgetWalkGoldenProvider,
      );
      await HomeWidget.updateWidget(
        name: ApiConstants.widgetThreeDaysProvider,
        androidName: ApiConstants.widgetThreeDaysProvider,
      );
    } catch (_) {
      // 위젯 갱신 예외 방어
    }
  }
}