part of 'stations_cubit.dart';

abstract class StationsState extends Equatable {
  const StationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load has been triggered.
class StationsInitial extends StationsState {}

/// Stations are being fetched from the API.
class StationsLoading extends StationsState {}

/// Stations loaded successfully.
///
/// [isSearching] is true while a search query is active.
/// [permanentIds] is the union of pinned and base station IDs; used by the UI
/// to decide whether to show the Save button on a search result.
class StationsLoaded extends StationsState {
  final List<RadioStation> stations;
  final List<RadioStation> favorites;
  final bool isSearching;
  final Set<String> permanentIds;

  const StationsLoaded({
    required this.stations,
    required this.favorites,
    this.isSearching = false,
    this.permanentIds = const {},
  });

  @override
  List<Object?> get props => [stations, favorites, isSearching, permanentIds];
}

/// An error occurred while loading stations.
class StationsError extends StationsState {
  final String message;

  const StationsError(this.message);

  @override
  List<Object?> get props => [message];
}
