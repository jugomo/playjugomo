import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/ignored_station.dart';
import '../../domain/entities/radio_station.dart';

/// Reads and writes all locally persisted station data using [SharedPreferences].
/// Three independent lists are managed: favourites, ignored, and pinned stations.
class RadioLocalDataSource {
  final SharedPreferences prefs;
  static const _favoritesKey = 'favorite_station_ids';
  static const _ignoredKey = 'ignored_stations';
  static const _pinnedKey = 'pinned_stations';

  RadioLocalDataSource(this.prefs);

  // ── Favorites ─────────────────────────────────────────────────────────────

  /// Returns the list of station IDs the user has marked as favourite.
  List<String> getFavoriteIds() {
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  /// Persists the full list of favourite station IDs.
  Future<void> saveFavoriteIds(List<String> ids) {
    return prefs.setStringList(_favoritesKey, ids);
  }

  // ── Ignored ───────────────────────────────────────────────────────────────

  /// Returns stations the user has permanently hidden.
  List<IgnoredStation> getIgnoredStations() {
    final raw = prefs.getStringList(_ignoredKey) ?? [];
    return raw.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return IgnoredStation(
          id: map['id'] as String, name: map['name'] as String);
    }).toList();
  }

  /// Persists the full ignored-station list.
  Future<void> saveIgnoredStations(List<IgnoredStation> stations) {
    final raw = stations
        .map((s) => jsonEncode({'id': s.id, 'name': s.name}))
        .toList();
    return prefs.setStringList(_ignoredKey, raw);
  }

  // ── Pinned ────────────────────────────────────────────────────────────────

  /// Returns stations the user has manually saved from search results.
  /// [isFavorite] is NOT stored here — callers apply it from the favourites list.
  List<RadioStation> getPinnedStations() {
    final raw = prefs.getStringList(_pinnedKey) ?? [];
    return raw.map((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return RadioStation(
        id: m['id'] as String,
        name: m['name'] as String,
        streamUrl: m['streamUrl'] as String,
        country: m['country'] as String,
        tags: m['tags'] as String,
        favicon: m['favicon'] as String,
      );
    }).toList();
  }

  /// Persists the full pinned-station list. Does not store [isFavorite].
  Future<void> savePinnedStations(List<RadioStation> stations) {
    final raw = stations
        .map((s) => jsonEncode({
              'id': s.id,
              'name': s.name,
              'streamUrl': s.streamUrl,
              'country': s.country,
              'tags': s.tags,
              'favicon': s.favicon,
            }))
        .toList();
    return prefs.setStringList(_pinnedKey, raw);
  }
}
