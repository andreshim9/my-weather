import 'dart:math' as math;
import '../models/month_sun_day_model.dart';
import '../models/sun_time_model.dart';

/// 고정밀 천문 역학 기반 일출·일몰 및 태양 궤적 계산 서비스
class SunCalcService {
  static const double rad = math.pi / 180.0;
  static const double deg = 180.0 / math.pi;

  /// 위도, 경도, 날짜를 기반으로 일출, 일몰, 박명, 남중 계산
  static SunTimeModel calculateSunTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) {
    final targetDate = date ?? DateTime.now();
    final year = targetDate.year;
    final month = targetDate.month;
    final day = targetDate.day;

    final jd = _toJulianDay(year, month, day);

    final sunriseUtc = _calculateEventTime(jd, latitude, longitude, -0.8333, isSunrise: true);
    final sunsetUtc = _calculateEventTime(jd, latitude, longitude, -0.8333, isSunrise: false);

    final dawnUtc = _calculateEventTime(jd, latitude, longitude, -6.0, isSunrise: true);
    final duskUtc = _calculateEventTime(jd, latitude, longitude, -6.0, isSunrise: false);

    final goldenMorningStartUtc = _calculateEventTime(jd, latitude, longitude, -4.0, isSunrise: true);
    final goldenMorningEndUtc = _calculateEventTime(jd, latitude, longitude, 6.0, isSunrise: true);
    final goldenEveningStartUtc = _calculateEventTime(jd, latitude, longitude, 6.0, isSunrise: false);
    final goldenEveningEndUtc = _calculateEventTime(jd, latitude, longitude, -4.0, isSunrise: false);

    final solarNoonUtc = _calculateSolarNoon(jd, longitude);

    final sunrise = _toLocal(targetDate, sunriseUtc);
    final sunset = _toLocal(targetDate, sunsetUtc);
    final solarNoon = _toLocal(targetDate, solarNoonUtc);
    final dawn = _toLocal(targetDate, dawnUtc);
    final dusk = _toLocal(targetDate, duskUtc);
    final goldenMorningStart = _toLocal(targetDate, goldenMorningStartUtc);
    final goldenMorningEnd = _toLocal(targetDate, goldenMorningEndUtc);
    final goldenEveningStart = _toLocal(targetDate, goldenEveningStartUtc);
    final goldenEveningEnd = _toLocal(targetDate, goldenEveningEndUtc);

    final now = DateTime.now();
    final altitude = _calculateSunAltitude(now, latitude, longitude);
    final dayLength = sunset.difference(sunrise).inMinutes;
    double progress = 0.0;
    if (now.isBefore(sunrise)) {
      progress = 0.0;
    } else if (now.isAfter(sunset)) {
      progress = 1.0;
    } else if (dayLength > 0) {
      final passed = now.difference(sunrise).inMinutes;
      progress = (passed / dayLength).clamp(0.0, 1.0);
    }

    final isDay = now.isAfter(sunrise) && now.isBefore(sunset);

    return SunTimeModel(
      sunrise: sunrise,
      sunset: sunset,
      solarNoon: solarNoon,
      dawn: dawn,
      dusk: dusk,
      morningGoldenStart: goldenMorningStart,
      morningGoldenEnd: goldenMorningEnd,
      eveningGoldenStart: goldenEveningStart,
      eveningGoldenEnd: goldenEveningEnd,
      sunAltitude: altitude,
      dayProgress: progress,
      isDayTime: isDay,
    );
  }

  /// 특정 기간(N일간) 일출몰 리스트 산출
  static List<MonthSunDayModel> calculateSunTimesForRange({
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required int days,
  }) {
    return List.generate(days, (i) {
      final date = startDate.add(Duration(days: i));
      final sun = calculateSunTimes(latitude: latitude, longitude: longitude, date: date);
      final length = sun.sunset.difference(sun.sunrise);
      return MonthSunDayModel(
        date: date,
        sunrise: sun.sunrise,
        sunset: sun.sunset,
        solarNoon: sun.solarNoon,
        dayLength: length,
        solarTerm: _getSolarTerm(date.month, date.day),
      );
    });
  }

  /// 특정 월의 전체 날짜 일출몰 달력 데이터 생성
  static List<MonthSunDayModel> calculateSunTimesForMonth({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final List<MonthSunDayModel> list = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final sun = calculateSunTimes(latitude: latitude, longitude: longitude, date: date);
      final length = sun.sunset.difference(sun.sunrise);
      list.add(MonthSunDayModel(
        date: date,
        sunrise: sun.sunrise,
        sunset: sun.sunset,
        solarNoon: sun.solarNoon,
        dayLength: length,
        solarTerm: _getSolarTerm(month, day),
      ));
    }

    return list;
  }

  static double _toJulianDay(int year, int month, int day) {
    int y = year;
    int m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + day + b - 1524.5;
  }

  static double _calculateSolarNoon(double jd, double longitude) {
    final t = (jd - 2451545.0) / 36525.0;
    final l0 = (280.46646 + t * (36000.76983 + t * 0.0003032)) % 360;
    final m = (357.52911 + t * (35999.05029 - 0.0001537 * t)) % 360;
    final e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t);

    final eps0 = 23.439291 - t * (0.0130042 + 0.00000016 * t);
    final y = math.tan(eps0 / 2 * rad) * math.tan(eps0 / 2 * rad);
    final eot = 4 * deg * (y * math.sin(2 * l0 * rad) - 2 * e * math.sin(m * rad) + 4 * y * e * math.sin(m * rad) * math.cos(2 * l0 * rad) - 0.5 * y * y * math.sin(4 * l0 * rad) - 1.25 * e * e * math.sin(2 * m * rad));

    final solarNoonMin = 720.0 - 4.0 * longitude - eot;
    return solarNoonMin / 60.0;
  }

  static double _calculateEventTime(double jd, double lat, double lon, double zenithAngle, {required bool isSunrise}) {
    final solarNoonUtcHours = _calculateSolarNoon(jd, lon);
    final t = (jd - 2451545.0) / 36525.0;
    final m = (357.52911 + t * (35999.05029 - 0.0001537 * t)) % 360;
    final l0 = (280.46646 + t * (36000.76983 + t * 0.0003032)) % 360;
    final c = (1.914602 - t * (0.004817 + 0.000014 * t)) * math.sin(m * rad) +
        (0.019993 - 0.000101 * t) * math.sin(2 * m * rad) +
        0.000289 * math.sin(3 * m * rad);
    final theta = l0 + c;
    final eps0 = 23.439291 - t * 0.0130042;
    final decl = math.asin(math.sin(eps0 * rad) * math.sin(theta * rad));

    final cosH = (math.sin(zenithAngle * rad) - math.sin(lat * rad) * math.sin(decl)) /
        (math.cos(lat * rad) * math.cos(decl));

    if (cosH > 1.0) {
      return isSunrise ? 0.0 : 24.0;
    }
    if (cosH < -1.0) {
      return isSunrise ? 0.0 : 24.0;
    }

    final hourAngleDeg = math.acos(cosH) * deg;
    final deltaHours = hourAngleDeg / 15.0;

    if (isSunrise) {
      return (solarNoonUtcHours - deltaHours + 24) % 24;
    } else {
      return (solarNoonUtcHours + deltaHours + 24) % 24;
    }
  }

  static DateTime _toLocal(DateTime baseDate, double utcHours) {
    final offsetHours = baseDate.timeZoneOffset.inMilliseconds / 3600000.0;
    final localTotalMinutes = (((utcHours + offsetHours) % 24 + 24) % 24) * 60.0;
    final hour = (localTotalMinutes.round() ~/ 60) % 24;
    final min = localTotalMinutes.round() % 60;

    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, min);
  }

  static double _calculateSunAltitude(DateTime time, double lat, double lon) {
    final jd = _toJulianDay(time.year, time.month, time.day);
    final t = (jd - 2451545.0) / 36525.0;
    final l0 = (280.46646 + t * 36000.76983) % 360;
    final m = (357.52911 + t * 35999.05029) % 360;
    final c = 1.914602 * math.sin(m * rad);
    final theta = l0 + c;
    final eps0 = 23.439291;
    final decl = math.asin(math.sin(eps0 * rad) * math.sin(theta * rad));

    final utcTime = time.toUtc();
    final currentUtcHours = utcTime.hour + utcTime.minute / 60.0 + utcTime.second / 3600.0;
    final solarNoonUtc = _calculateSolarNoon(jd, lon);
    final hourAngle = (currentUtcHours - solarNoonUtc) * 15.0 * rad;

    final sinAlt = math.sin(lat * rad) * math.sin(decl) +
        math.cos(lat * rad) * math.cos(decl) * math.cos(hourAngle);

    return math.asin(sinAlt.clamp(-1.0, 1.0)) * deg;
  }

  /// 24절기 매핑
  static String? _getSolarTerm(int month, int day) {
    if (month == 2 && day == 4) return '입춘 🌱';
    if (month == 2 && day == 19) return '우수 💧';
    if (month == 3 && day == 6) return '경칩 🐸';
    if (month == 3 && day == 21) return '춘분 🌸';
    if (month == 4 && day == 5) return '청명 🌿';
    if (month == 4 && day == 20) return '곡우 🌾';
    if (month == 5 && day == 6) return '입하 ☀️';
    if (month == 5 && day == 21) return '소만 🍃';
    if (month == 6 && day == 6) return '망종 🌾';
    if (month == 6 && day == 21) return '하지 ☀️';
    if (month == 7 && day == 7) return '소서 🌊';
    if (month == 7 && day == 23) return '대서 🔥';
    if (month == 8 && day == 8) return '입추 🍁';
    if (month == 8 && day == 23) return '처서 🌾';
    if (month == 9 && day == 8) return '백로 🍂';
    if (month == 9 && day == 23) return '추분 🌕';
    if (month == 10 && day == 8) return '한로 🌾';
    if (month == 10 && day == 23) return '상강 ❄️';
    if (month == 11 && day == 7) return '입동 ☃️';
    if (month == 11 && day == 22) return '소설 ❄️';
    if (month == 12 && day == 7) return '대설 ⛄';
    if (month == 12 && day == 22) return '동지 🌑';
    if (month == 1 && day == 6) return '소한 🥶';
    if (month == 1 && day == 20) return '대한 🧊';
    return null;
  }
}
