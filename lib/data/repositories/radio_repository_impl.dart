import '../../domain/entities/radio_station.dart';
import '../../domain/repositories/radio_repository.dart';
import '../datasources/radio_local_datasource.dart';
import '../datasources/radio_remote_datasource.dart';

/// [RadioRepository] implementation that combines remote and local data.
class RadioRepositoryImpl implements RadioRepository {
  final RadioRemoteDataSource remoteDataSource;
  final RadioLocalDataSource localDataSource;

  RadioRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<RadioStation>> getStations({String? query}) async {
    final models = await remoteDataSource.getStations(query: query);
    final favoriteIds = localDataSource.getFavoriteIds().toSet();
    return models
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
}
