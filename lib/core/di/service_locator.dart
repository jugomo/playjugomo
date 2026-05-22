import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/radio_local_datasource.dart';
import '../../data/datasources/radio_remote_datasource.dart';
import '../../data/repositories/radio_repository_impl.dart';
import '../../domain/repositories/radio_repository.dart';
import '../../domain/usecases/get_ignored_stations_usecase.dart';
import '../../domain/usecases/get_pinned_stations_usecase.dart';
import '../../domain/usecases/get_stations_usecase.dart';
import '../../domain/usecases/ignore_station_usecase.dart';
import '../../domain/usecases/pin_station_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import '../../domain/usecases/unignore_station_usecase.dart';
import '../constants/api_constants.dart';

/// Global GetIt instance — imported wherever a dependency is needed.
final sl = GetIt.instance;

/// Registers all app dependencies.
/// Must be called before [runApp] because [SharedPreferences] requires async init.
Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerLazySingleton<AudioPlayer>(() => AudioPlayer());

  sl.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    )),
  );

  sl.registerLazySingleton<RadioRemoteDataSource>(
    () => RadioRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<RadioLocalDataSource>(
    () => RadioLocalDataSource(sl()),
  );

  sl.registerLazySingleton<RadioRepository>(
    () => RadioRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetStationsUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => IgnoreStationUseCase(sl()));
  sl.registerLazySingleton(() => UnignoreStationUseCase(sl()));
  sl.registerLazySingleton(() => GetIgnoredStationsUseCase(sl()));
  sl.registerLazySingleton(() => PinStationUseCase(sl()));
  sl.registerLazySingleton(() => GetPinnedStationsUseCase(sl()));
}
