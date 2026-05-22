import '../repositories/radio_repository.dart';

/// Permanently hides a station from all lists.
/// Also removes it from pinned storage so it does not linger there.
class IgnoreStationUseCase {
  final RadioRepository repository;

  IgnoreStationUseCase(this.repository);

  Future<void> call(String id, String name) => repository.ignoreStation(id, name);
}
