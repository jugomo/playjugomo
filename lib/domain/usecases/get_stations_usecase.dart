import '../entities/radio_station.dart';
import '../repositories/radio_repository.dart';

/// Use case for fetching the station list, with optional search support.
class GetStationsUseCase {
  final RadioRepository repository;

  GetStationsUseCase(this.repository);

  Future<List<RadioStation>> call({String? query}) {
    return repository.getStations(query: query);
  }
}
