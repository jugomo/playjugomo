import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'domain/usecases/get_pinned_stations_usecase.dart';
import 'domain/usecases/get_stations_usecase.dart';
import 'domain/usecases/ignore_station_usecase.dart';
import 'domain/usecases/pin_station_usecase.dart';
import 'domain/usecases/toggle_favorite_usecase.dart';
import 'presentation/cubits/player_cubit.dart';
import 'presentation/cubits/stations_cubit.dart';
import 'presentation/cubits/theme_cubit.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const RadioApp());
}

/// Root widget. Provides global Cubits and configures Material 3 themes.
/// [ThemeCubit] drives the [MaterialApp.themeMode] so theme changes are instant.
class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  static final _lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static final _darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<PlayerCubit>(
          create: (_) => PlayerCubit(sl<AudioPlayer>()),
        ),
        BlocProvider<StationsCubit>(
          create: (_) => StationsCubit(
            getStationsUseCase: sl<GetStationsUseCase>(),
            toggleFavoriteUseCase: sl<ToggleFavoriteUseCase>(),
            ignoreStationUseCase: sl<IgnoreStationUseCase>(),
            pinStationUseCase: sl<PinStationUseCase>(),
            getPinnedStationsUseCase: sl<GetPinnedStationsUseCase>(),
          ),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp(
          title: 'Radio Player',
          debugShowCheckedModeBanner: false,
          theme: _lightTheme,
          darkTheme: _darkTheme,
          themeMode: themeMode,
          home: const HomePage(),
        ),
      ),
    );
  }
}
