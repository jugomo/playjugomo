import '../entities/radio_station.dart';

/// Repository contract for radio stations. Implemented by the data layer.
abstract class RadioRepository {
  /// Returns stations from the API, filtered by [query] when provided.
  Future<List<RadioStation>> getStations({String? query});

  /// Returns the IDs of stations marked as favourites.
  Future<List<String>> getFavoriteIds();

  /// Adds or removes [stationId] from favourites based on its current state.
  Future<void> toggleFavorite(String stationId);
}
