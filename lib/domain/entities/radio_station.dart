import 'package:equatable/equatable.dart';

/// Core domain entity representing a radio station.
class RadioStation extends Equatable {
  final String id;
  final String name;
  final String streamUrl;
  final String country;
  final String tags;
  final String favicon;
  final bool isFavorite;

  const RadioStation({
    required this.id,
    required this.name,
    required this.streamUrl,
    required this.country,
    required this.tags,
    required this.favicon,
    this.isFavorite = false,
  });

  RadioStation copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? country,
    String? tags,
    String? favicon,
    bool? isFavorite,
  }) {
    return RadioStation(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      country: country ?? this.country,
      tags: tags ?? this.tags,
      favicon: favicon ?? this.favicon,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, name, streamUrl, country, tags, favicon, isFavorite];
}
