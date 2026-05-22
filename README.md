# playjugomo

![PlayJugomo](PlayJugomoEN.png)

Another Stream Radio player by jugomo — a Flutter app for discovering and listening to radio stations around the world.

## Features

- Browse 100+ live radio stations fetched from the [radio-browser.info](https://www.radio-browser.info) free API
- Tap any station to start streaming instantly
- Play/pause and volume controls in a persistent bottom player bar
- Search stations by name
- Mark stations as favorites with a heart icon
- Favorites tab for quick access — persisted across sessions

## Architecture

This project follows **Clean Architecture** principles, separated into three layers:

```
lib/
├── core/
│   ├── constants/          # API base URL
│   └── di/                 # Dependency injection (GetIt)
├── domain/
│   ├── entities/           # RadioStation entity
│   ├── repositories/       # Abstract repository interface
│   └── usecases/           # GetStationsUseCase, ToggleFavoriteUseCase
├── data/
│   ├── models/             # JSON deserialization (RadioStationModel)
│   ├── datasources/        # Remote (Dio) + Local (SharedPreferences)
│   └── repositories/       # RadioRepositoryImpl
└── presentation/
    ├── cubits/             # StationsCubit, PlayerCubit (flutter_bloc)
    ├── pages/              # HomePage (tabs: All Stations / Favorites)
    └── widgets/            # StationTile, PlayerBar
```

## Tech Stack

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management (Cubits) |
| `get_it` | Dependency injection |
| `audioplayers` | Audio streaming |
| `dio` | HTTP client |
| `shared_preferences` | Local favorites persistence |
| `equatable` | Value equality for entities/states |

## API

Stations are fetched from [radio-browser.info](https://de1.api.radio-browser.info) — a free, community-driven radio station database with no authentication required.

## Getting Started

> **Tested on:** Android (emulator and physical device). iOS and other platforms have not been verified.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and on your `PATH`
- Android emulator running or a physical Android device connected via USB with USB debugging enabled
- Verify your setup with `flutter doctor`

### Run

```bash
flutter pub get
flutter run
```

To target a specific device when multiple are connected:

```bash
flutter devices          # list available devices
flutter run -d <device-id>
```

### Build APK

```bash
flutter build apk
# Output: build/app/outputs/flutter-apk/app-release.apk
```
