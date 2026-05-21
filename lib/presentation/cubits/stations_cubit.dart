import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/radio_station.dart';
import '../../domain/usecases/get_stations_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

part 'stations_state.dart';

/// Manages the station list and the favourites state.
class StationsCubit extends Cubit<StationsState> {
  final GetStationsUseCase _getStationsUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  List<RadioStation> _allStations = [];

  StationsCubit({
    required GetStationsUseCase getStationsUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
  })  : _getStationsUseCase = getStationsUseCase,
        _toggleFavoriteUseCase = toggleFavoriteUseCase,
        super(StationsInitial());

  /// Loads stations from the API, optionally filtered by [query].
  Future<void> loadStations({String? query}) async {
    emit(StationsLoading());
    try {
      _allStations = await _getStationsUseCase(query: query);
      _emitLoaded();
    } catch (e) {
      emit(StationsError(e.toString()));
    }
  }

  /// Toggles the favourite state of [station] and updates the in-memory list.
  Future<void> toggleFavorite(RadioStation station) async {
    await _toggleFavoriteUseCase(station.id);
    _allStations = _allStations.map((s) {
      return s.id == station.id ? s.copyWith(isFavorite: !s.isFavorite) : s;
    }).toList();
    _emitLoaded();
  }

  void _emitLoaded() {
    final favorites = _allStations.where((s) => s.isFavorite).toList();
    emit(StationsLoaded(stations: List.from(_allStations), favorites: favorites));
  }
}
