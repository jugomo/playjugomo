import '../entities/radio_station.dart';
import '../repositories/radio_repository.dart';

/// Fetches the station list from the repository, with optional search support.
class GetStationsUseCase {
  final RadioRepository repository;

  GetStationsUseCase(this.repository);

  Future<List<RadioStation>> call({String? query}) {
    return repository.getStations(query: query);
  }
}
