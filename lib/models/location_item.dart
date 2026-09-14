class LocationItem {
  final String name;
  final String description;
  final double latitude;
  final double longitude;

  const LocationItem({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString();
    final admin1 = (json['admin1'] ?? '').toString();
    final country = (json['country'] ?? '').toString();
    final desc = (json['description'] ?? [admin1, country].where((s) => s.isNotEmpty).join(', ')).toString();

    return LocationItem(
      name: name,
      description: desc.isNotEmpty ? desc : '대한민국',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
