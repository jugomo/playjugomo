import '../entities/ignored_station.dart';
import '../entities/radio_station.dart';

/// Contract for all station data operations.
/// Implemented by [RadioRepositoryImpl] in the data layer.
abstract class RadioRepository {
  /// Returns stations from the API, filtered by [query] when provided.
  /// Ignored stations are excluded and favorite flags are applied.
  Future<List<RadioStation>> getStations({String? query});

  /// Returns the IDs of stations marked as favourites.
  Future<List<String>> getFavoriteIds();

  /// Adds or removes [stationId] from favourites based on its current state.
  Future<void> toggleFavorite(String stationId);

  /// Returns all stations the user has permanently hidden.
  List<IgnoredStation> getIgnoredStations();

  /// Marks [id] as ignored and removes it from the pinned list if present.
  Future<void> ignoreStation(String id, String name);

  /// Removes [id] from the ignored list so it can be fetched again.
  Future<void> unignoreStation(String id);

  /// Returns pinned stations with their current favourite flag applied.
  List<RadioStation> getPinnedStations();

  /// Persists [station] so it always appears at the top of the main list.
  Future<void> pinStation(RadioStation station);
}
