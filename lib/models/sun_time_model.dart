class SunTimeModel {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime solarNoon;
  final DateTime dawn;
  final DateTime dusk;
  final DateTime morningGoldenStart;
  final DateTime morningGoldenEnd;
  final DateTime eveningGoldenStart;
  final DateTime eveningGoldenEnd;
  final double sunAltitude; // 현재 태양 고도 (도, °)
  final double dayProgress; // 0.0 ~ 1.0 (하루 중 낮 진행도)
  final bool isDayTime;

  SunTimeModel({
    required this.sunrise,
    required this.sunset,
    required this.solarNoon,
    required this.dawn,
    required this.dusk,
    required this.morningGoldenStart,
    required this.morningGoldenEnd,
    required this.eveningGoldenStart,
    required this.eveningGoldenEnd,
    required this.sunAltitude,
    required this.dayProgress,
    required this.isDayTime,
  });

  /// 일출까지 남은 시간 or 일몰까지 남은 시간
  String get remainingTimeStatus {
    final now = DateTime.now();
    if (now.isBefore(sunrise)) {
      final diff = sunrise.difference(now);
      return '일출까지 ${diff.inHours}시간 ${diff.inMinutes % 60}분 남음';
    } else if (now.isBefore(sunset)) {
      final diff = sunset.difference(now);
      return '일몰까지 ${diff.inHours}시간 ${diff.inMinutes % 60}분 남음';
    } else {
      final tomorrowSunrise = sunrise.add(const Duration(days: 1));
      final diff = tomorrowSunrise.difference(now);
      return '내일 일출까지 ${diff.inHours}시간 ${diff.inMinutes % 60}분 남음';
    }
  }

  /// 산책 골든아워 상태 판별
  String get walkGoldenHourStatus {
    final now = DateTime.now();
    if (now.isAfter(morningGoldenStart) && now.isBefore(morningGoldenEnd)) {
      return '아침 산책 골든아워 진행 중 ✨';
    } else if (now.isAfter(eveningGoldenStart) && now.isBefore(eveningGoldenEnd)) {
      return '저녁 산책 골든아워 진행 중 🐾';
    } else if (now.isBefore(morningGoldenStart)) {
      return '일출 전 산책 준비 시간';
    } else if (now.isAfter(morningGoldenEnd) && now.isBefore(eveningGoldenStart)) {
      return '낮 시간대 (그늘 산책 권장)';
    } else {
      return '야간 산책 시간 (야광 조끼/리드줄 권장)';
    }
  }
}
