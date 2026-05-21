import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'domain/usecases/get_stations_usecase.dart';
import 'domain/usecases/toggle_favorite_usecase.dart';
import 'presentation/cubits/player_cubit.dart';
import 'presentation/cubits/stations_cubit.dart';
import 'presentation/pages/home_page.dart';

/// Entry point. Initialises dependency injection before mounting the UI.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const RadioApp());
}

/// Widget raíz. Provee los cubits globales y configura el tema Material 3.
class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayerCubit>(
          create: (_) => PlayerCubit(sl<AudioPlayer>()),
        ),
        BlocProvider<StationsCubit>(
          create: (_) => StationsCubit(
            getStationsUseCase: sl<GetStationsUseCase>(),
            toggleFavoriteUseCase: sl<ToggleFavoriteUseCase>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Radio Player',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
