import '../../domain/entities/ignored_station.dart';
import '../../domain/entities/radio_station.dart';
import '../../domain/repositories/radio_repository.dart';
import '../datasources/radio_local_datasource.dart';
import '../datasources/radio_remote_datasource.dart';

/// Combines [RadioRemoteDataSource] and [RadioLocalDataSource] to satisfy
/// the [RadioRepository] contract.
class RadioRepositoryImpl implements RadioRepository {
  final RadioRemoteDataSource remoteDataSource;
  final RadioLocalDataSource localDataSource;

  RadioRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Fetches from the API, strips ignored stations, and applies favourite flags.
  @override
  Future<List<RadioStation>> getStations({String? query}) async {
    final models = await remoteDataSource.getStations(query: query);
    final favoriteIds = localDataSource.getFavoriteIds().toSet();
    final ignoredIds =
        localDataSource.getIgnoredStations().map((s) => s.id).toSet();
    return models
        .where((m) => !ignoredIds.contains(m.id))
        .map((m) => m.toEntity(isFavorite: favoriteIds.contains(m.id)))
        .toList();
  }

  @override
  Future<List<String>> getFavoriteIds() async {
    return localDataSource.getFavoriteIds();
  }

  @override
  Future<void> toggleFavorite(String stationId) async {
    final ids = List<String>.from(localDataSource.getFavoriteIds());
    if (ids.contains(stationId)) {
      ids.remove(stationId);
    } else {
      ids.add(stationId);
    }
    await localDataSource.saveFavoriteIds(ids);
  }

  // ── Ignored ───────────────────────────────────────────────────────────────

  @override
  List<IgnoredStation> getIgnoredStations() {
    return localDataSource.getIgnoredStations();
  }

  /// Adds to the ignored list and removes from pinned in one operation
  /// so the station does not surface again through the pinned path.
  @override
  Future<void> ignoreStation(String id, String name) async {
    final ignored =
        List<IgnoredStation>.from(localDataSource.getIgnoredStations());
    if (!ignored.any((s) => s.id == id)) {
      ignored.add(IgnoredStation(id: id, name: name));
      await localDataSource.saveIgnoredStations(ignored);
    }
    final pinned =
        localDataSource.getPinnedStations().where((s) => s.id != id).toList();
    await localDataSource.savePinnedStations(pinned);
  }

  @override
  Future<void> unignoreStation(String id) async {
    final current = localDataSource
        .getIgnoredStations()
        .where((s) => s.id != id)
        .toList();
    await localDataSource.saveIgnoredStations(current);
  }

  // ── Pinned ────────────────────────────────────────────────────────────────

  /// Returns pinned stations with the current favourite flag applied.
  @override
  List<RadioStation> getPinnedStations() {
    final favoriteIds = localDataSource.getFavoriteIds().toSet();
    return localDataSource.getPinnedStations().map((s) {
      return s.copyWith(isFavorite: favoriteIds.contains(s.id));
    }).toList();
  }

  @override
  Future<void> pinStation(RadioStation station) async {
    final current = localDataSource.getPinnedStations();
    if (!current.any((s) => s.id == station.id)) {
      await localDataSource.savePinnedStations([station, ...current]);
    }
  }
}
