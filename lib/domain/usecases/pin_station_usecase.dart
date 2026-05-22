import '../entities/radio_station.dart';
import '../repositories/radio_repository.dart';

/// Persists a station so it always appears at the top of the All Stations list,
/// even when the API does not return it in the default load.
class PinStationUseCase {
  final RadioRepository repository;

  PinStationUseCase(this.repository);

  Future<void> call(RadioStation station) => repository.pinStation(station);
}
