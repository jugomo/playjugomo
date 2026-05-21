import 'package:shared_preferences/shared_preferences.dart';

/// Persists favourite station IDs using SharedPreferences.
class RadioLocalDataSource {
  final SharedPreferences prefs;
  static const _favoritesKey = 'favorite_station_ids';

  RadioLocalDataSource(this.prefs);

  /// Returns the locally stored list of favourite station IDs.
  List<String> getFavoriteIds() {
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  /// Persists the full list of favourite station IDs.
  Future<void> saveFavoriteIds(List<String> ids) {
    return prefs.setStringList(_favoritesKey, ids);
  }
}
