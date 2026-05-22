import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ignored_station.dart';
import '../../domain/usecases/get_ignored_stations_usecase.dart';
import '../../domain/usecases/unignore_station_usecase.dart';

/// Manages the ignored-station list shown on the Settings page.
/// State is a plain list of [IgnoredStation] — no wrapper class needed.
class SettingsCubit extends Cubit<List<IgnoredStation>> {
  final GetIgnoredStationsUseCase _getIgnored;
  final UnignoreStationUseCase _unignore;

  SettingsCubit({
    required GetIgnoredStationsUseCase getIgnoredStationsUseCase,
    required UnignoreStationUseCase unignoreStationUseCase,
  })  : _getIgnored = getIgnoredStationsUseCase,
        _unignore = unignoreStationUseCase,
        super([]) {
    _load();
  }

  void _load() => emit(_getIgnored());

  /// Removes [stationId] from the ignored list so the station can reappear
  /// on the next [StationsCubit.loadStations] call.
  Future<void> unignore(String stationId) async {
    await _unignore(stationId);
    _load();
  }
}
