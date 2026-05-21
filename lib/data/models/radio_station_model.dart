import '../../domain/entities/radio_station.dart';

/// Extends [RadioStation] with JSON deserialisation from the API response.
class RadioStationModel extends RadioStation {
  const RadioStationModel({
    required super.id,
    required super.name,
    required super.streamUrl,
    required super.country,
    required super.tags,
    required super.favicon,
    super.isFavorite = false,
  });

  factory RadioStationModel.fromJson(Map<String, dynamic> json) {
    return RadioStationModel(
      id: json['stationuuid'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Station',
      streamUrl: json['url_resolved'] as String? ?? json['url'] as String? ?? '',
      country: json['country'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
      favicon: json['favicon'] as String? ?? '',
    );
  }

  RadioStation toEntity({bool isFavorite = false}) {
    return RadioStation(
      id: id,
      name: name,
      streamUrl: streamUrl,
      country: country,
      tags: tags,
      favicon: favicon,
      isFavorite: isFavorite,
    );
  }
}
