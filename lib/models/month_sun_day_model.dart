class MonthSunDayModel {
  final DateTime date;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime solarNoon;
  final Duration dayLength;
  final String? solarTerm; // 24절기 (입춘, 춘분, 하지, 입추, 추분, 동지 등)

  MonthSunDayModel({
    required this.date,
    required this.sunrise,
    required this.sunset,
    required this.solarNoon,
    required this.dayLength,
    this.solarTerm,
  });

  String get formattedDayLength {
    final hours = dayLength.inHours;
    final minutes = dayLength.inMinutes % 60;
    return '${hours}시간 ${minutes}분';
  }
}
