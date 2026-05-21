part of 'stations_cubit.dart';

/// Possible states for [StationsCubit].
abstract class StationsState extends Equatable {
  const StationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load has been triggered.
class StationsInitial extends StationsState {}

/// Stations are being fetched from the API.
class StationsLoading extends StationsState {}

/// Stations loaded successfully. Contains the full list and the favourites.
class StationsLoaded extends StationsState {
  final List<RadioStation> stations;
  final List<RadioStation> favorites;

  const StationsLoaded({required this.stations, required this.favorites});

  @override
  List<Object?> get props => [stations, favorites];
}

/// An error occurred while loading stations.
class StationsError extends StationsState {
  final String message;

  const StationsError(this.message);

  @override
  List<Object?> get props => [message];
}
