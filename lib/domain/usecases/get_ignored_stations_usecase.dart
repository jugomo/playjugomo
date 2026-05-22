import '../entities/ignored_station.dart';
import '../repositories/radio_repository.dart';

/// Returns the list of stations the user has permanently hidden.
class GetIgnoredStationsUseCase {
  final RadioRepository repository;

  GetIgnoredStationsUseCase(this.repository);

  List<IgnoredStation> call() => repository.getIgnoredStations();
}
