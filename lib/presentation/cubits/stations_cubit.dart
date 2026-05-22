import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/radio_station.dart';
import '../../domain/usecases/get_pinned_stations_usecase.dart';
import '../../domain/usecases/get_stations_usecase.dart';
import '../../domain/usecases/ignore_station_usecase.dart';
import '../../domain/usecases/pin_station_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

part 'stations_state.dart';

/// Manages the station list, search state, favourites, ignored, and pinned stations.
///
/// Internal state tracks three separate lists:
/// - [_pinnedStations] — user-saved stations loaded from local storage at startup.
/// - [_baseStations] — the last non-search API result.
/// - [_allStations] — what is currently displayed (merge of pinned + base, or search results).
///
/// [_permanentIds] is the union of pinned and base IDs; it determines whether
/// a search result already exists in the permanent list (used to show/hide the Save button).
class StationsCubit extends Cubit<StationsState> {
  final GetStationsUseCase _getStationsUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final IgnoreStationUseCase _ignoreStationUseCase;
  final PinStationUseCase _pinStationUseCase;
  final GetPinnedStationsUseCase _getPinnedStationsUseCase;

  List<RadioStation> _pinnedStations = [];
  List<RadioStation> _baseStations = [];
  List<RadioStation> _allStations = [];
  bool _isSearching = false;
  Set<String> _permanentIds = {};

  StationsCubit({
    required GetStationsUseCase getStationsUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
    required IgnoreStationUseCase ignoreStationUseCase,
    required PinStationUseCase pinStationUseCase,
    required GetPinnedStationsUseCase getPinnedStationsUseCase,
  })  : _getStationsUseCase = getStationsUseCase,
        _toggleFavoriteUseCase = toggleFavoriteUseCase,
        _ignoreStationUseCase = ignoreStationUseCase,
        _pinStationUseCase = pinStationUseCase,
        _getPinnedStationsUseCase = getPinnedStationsUseCase,
        super(StationsInitial()) {
    _pinnedStations = _getPinnedStationsUseCase();
    // Seed permanent IDs with pinned so the Save button works before first base load.
    _permanentIds = _pinnedStations.map((s) => s.id).toSet();
  }

  /// Loads stations from the API, optionally filtered by [query].
  ///
  /// Without a query: updates [_baseStations], merges with pinned, clears search mode.
  /// With a query: stores search results in [_allStations] and sets search mode;
  /// [_permanentIds] is not changed so the Save button reflects the permanent list.
  Future<void> loadStations({String? query}) async {
    emit(StationsLoading());
    try {
      final fetched = await _getStationsUseCase(query: query);
      if (query == null || query.trim().isEmpty) {
        _baseStations = fetched;
        _isSearching = false;
        _allStations = _mergeWithPinned(fetched);
        _permanentIds = _allStations.map((s) => s.id).toSet();
      } else {
        _isSearching = true;
        _allStations = fetched;
      }
      _emitLoaded();
    } catch (e) {
      emit(StationsError(e.toString()));
    }
  }

  /// Toggles the favourite flag for [station] and updates all in-memory lists.
  Future<void> toggleFavorite(RadioStation station) async {
    await _toggleFavoriteUseCase(station.id);
    final newFav = !station.isFavorite;
    _allStations = _allStations
        .map((s) => s.id == station.id ? s.copyWith(isFavorite: newFav) : s)
        .toList();
    _pinnedStations = _pinnedStations
        .map((s) => s.id == station.id ? s.copyWith(isFavorite: newFav) : s)
        .toList();
    _emitLoaded();
  }

  /// Hides [station] permanently: persists the ignore, removes it from all
  /// in-memory lists, and strips it from [_permanentIds].
  Future<void> ignoreStation(RadioStation station) async {
    await _ignoreStationUseCase(station.id, station.name);
    _allStations = _allStations.where((s) => s.id != station.id).toList();
    _pinnedStations = _pinnedStations.where((s) => s.id != station.id).toList();
    _baseStations = _baseStations.where((s) => s.id != station.id).toList();
    _permanentIds.remove(station.id);
    _emitLoaded();
  }

  /// Saves [station] to local storage and adds it to [_permanentIds] immediately
  /// so the Save button disappears without waiting for a reload.
  Future<void> pinStation(RadioStation station) async {
    if (_permanentIds.contains(station.id)) return;
    await _pinStationUseCase(station);
    _pinnedStations = [station, ..._pinnedStations];
    _permanentIds.add(station.id);
    if (!_isSearching) {
      _allStations = [
        station,
        ..._allStations.where((s) => s.id != station.id),
      ];
    }
    _emitLoaded();
  }

  /// Prepends pinned stations that are not already in [base], avoiding duplicates.
  List<RadioStation> _mergeWithPinned(List<RadioStation> base) {
    final baseIds = base.map((s) => s.id).toSet();
    final extra =
        _pinnedStations.where((s) => !baseIds.contains(s.id)).toList();
    return [...extra, ...base];
  }

  void _emitLoaded() {
    final favorites = _allStations.where((s) => s.isFavorite).toList();
    emit(StationsLoaded(
      stations: List.from(_allStations),
      favorites: favorites,
      isSearching: _isSearching,
      permanentIds: Set.from(_permanentIds),
    ));
  }
}
