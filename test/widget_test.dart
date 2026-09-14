import 'package:flutter_test/flutter_test.dart';
import 'package:my_weather/services/sun_calc_service.dart';

void main() {
  test('SunCalcService calculates valid sunrise and sunset for Seoul', () {
    final sunTime = SunCalcService.calculateSunTimes(
      latitude: 37.5665,
      longitude: 126.9780,
    );

    expect(sunTime.sunrise.hour, inInclusiveRange(4, 8));
    expect(sunTime.sunset.hour, inInclusiveRange(17, 21));
    expect(sunTime.sunset.isAfter(sunTime.sunrise), isTrue);
  });

  test('SunCalcService calculates 30-day monthly sun calendar data', () {
    final monthDays = SunCalcService.calculateSunTimesForMonth(
      latitude: 37.5665,
      longitude: 126.9780,
      year: 2026,
      month: 9,
    );

    expect(monthDays.length, equals(30));
    expect(monthDays.first.sunrise, isNotNull);
    expect(monthDays.first.sunset, isNotNull);
  });
}
