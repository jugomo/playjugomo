import '../repositories/radio_repository.dart';

/// Use case for toggling the favourite state of a station.
class ToggleFavoriteUseCase {
  final RadioRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<void> call(String stationId) {
    return repository.toggleFavorite(stationId);
  }
}
