import '../repositories/radio_repository.dart';

/// Removes a station from the ignored list so it can be fetched from the API again.
class UnignoreStationUseCase {
  final RadioRepository repository;

  UnignoreStationUseCase(this.repository);

  Future<void> call(String id) => repository.unignoreStation(id);
}
