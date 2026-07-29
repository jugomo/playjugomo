# PlayJugomo

![PlayJugomo](PlayJugomoEN.png)

Another Stream Radio player by jugomo — a Flutter app for discovering and listening to radio stations around the world.

## Demo

The following short video walks through the main features of the app — browsing stations, searching, toggling favorites, swiping to ignore, and the persistent player bar:

[![PlayJugomo demo](https://img.youtube.com/vi/NDe_tstHwco/0.jpg)](https://youtube.com/shorts/NDe_tstHwco)

## Ownership & contributing

This project was created by [@jugomo](https://github.com/jugomo) and is
licensed under the [MIT License](LICENSE). Anyone is welcome to use this
software at their own risk, copy or fork it as long as the original
author is credited, and contribute back, whether that's opening a pull
request or simply suggesting improvements via an issue. No warranty is
provided.

## Features

### Playback
- Browse live radio stations fetched from the [radio-browser.info](https://www.radio-browser.info) free API
- Tap any station to start streaming instantly
- Persistent bottom player bar with play/pause controls and collapsible volume slider
- Animated entry of the player bar when a station is selected for the first time
- Animated equalizer bars on the station avatar while playing

### Discovery & Search
- Real-time search with 400 ms debounce — results update as you type
- Station count shown in the app bar after loading
- Save any search result permanently to the top of your All Stations list with one tap
- Pull-to-refresh to reload the station list at any time

### Organisation
- Mark stations as favorites with the heart icon — persisted across sessions
- Favorites tab for quick access
- Row numbers in retro VT323 font for a classic radio-dial feel
- Country and genre tags displayed as compact chips on each row
- Swipe left on any station to ignore it — it will never appear again
- Settings page listing all ignored stations with the option to restore any of them

### UI
- Material 3 design with a purple seed color
- Light / dark theme toggle in the app bar
- Tags rendered as compact pill chips instead of plain text

## Architecture

Clean Architecture in three layers, with dependency flow `presentation → domain ← data`.

```
lib/
├── core/
│   ├── constants/          # API base URL
│   └── di/                 # Dependency injection (GetIt) — service_locator.dart
├── domain/
│   ├── entities/           # RadioStation, IgnoredStation
│   ├── repositories/       # Abstract RadioRepository interface
│   └── usecases/           # GetStations, ToggleFavorite, Ignore/Unignore,
│                           #   Pin/GetPinned, GetIgnored
├── data/
│   ├── models/             # RadioStationModel (JSON → entity)
│   ├── datasources/        # RadioRemoteDataSource (Dio), RadioLocalDataSource (SharedPreferences)
│   └── repositories/       # RadioRepositoryImpl
└── presentation/
    ├── cubits/             # StationsCubit, PlayerCubit, ThemeCubit, SettingsCubit
    ├── pages/              # HomePage (All Stations / Favorites tabs), SettingsPage
    └── widgets/            # StationTile, PlayerBar
```

## Tech Stack

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management (Cubits) |
| `get_it` | Dependency injection |
| `audioplayers` | Audio streaming |
| `dio` | HTTP client |
| `shared_preferences` | Local persistence (favorites, ignored, pinned stations) |
| `equatable` | Value equality for entities and states |
| `google_fonts` | VT323 retro font for station row numbers |

## Local Persistence

Three independent lists are stored in `SharedPreferences`:

| Key | Content | Purpose |
|---|---|---|
| `favorite_station_ids` | List of station IDs | Favorite stations |
| `ignored_stations` | List of `{id, name}` JSON objects | Stations permanently hidden from the list |
| `pinned_stations` | List of full station JSON objects | Stations manually saved from search results |

Pinned stations are prepended to the All Stations list on every load. If the same station is returned by the API, the API version takes precedence and no duplicate appears.

## API

Stations are fetched from [radio-browser.info](https://de1.api.radio-browser.info) — a free, community-driven radio station database with no authentication required. The endpoint is hardcoded to the `de1` mirror.

## Development Time

Built across two sessions over two days, estimated from commit history:

| Session | Date | Duration | Work done |
|---|---|---|---|
| 1 | 21 May 2026 · evening | ~2.5 h | Project setup, full clean architecture, audio handler, base UI |
| 2 | 22 May 2026 · morning | ~2.5 h | App icon, UI polish, pin/ignore feature, Settings page, About page, release |

**Total: ~5–6 hours of active coding** across ~1,500 net lines of business logic (excluding generated code and assets).

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

### Useful commands

```bash
flutter analyze          # Static analysis (flutter_lints)
flutter test             # Run all tests
```
