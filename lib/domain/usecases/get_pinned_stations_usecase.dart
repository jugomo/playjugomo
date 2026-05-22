import '../entities/radio_station.dart';
import '../repositories/radio_repository.dart';

/// Returns locally pinned stations with their current favourite flag applied.
class GetPinnedStationsUseCase {
  final RadioRepository repository;

  GetPinnedStationsUseCase(this.repository);

  List<RadioStation> call() => repository.getPinnedStations();
}
