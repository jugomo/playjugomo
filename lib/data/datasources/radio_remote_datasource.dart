import 'package:dio/dio.dart';
import '../models/radio_station_model.dart';

/// Fetches stations from the remote radio-browser.info API.
class RadioRemoteDataSource {
  final Dio dio;

  RadioRemoteDataSource(this.dio);

  /// Returns up to 100 active stations ordered by popularity.
  /// Filters by name when [query] is provided.
  Future<List<RadioStationModel>> getStations({String? query}) async {
    final params = <String, dynamic>{
      'limit': 100,
      'hidebroken': 'true',
      'order': 'clickcount',
      'reverse': 'true',
    };
    if (query != null && query.isNotEmpty) {
      params['name'] = query;
    }

    final response = await dio.get(
      '/json/stations/search',
      queryParameters: params,
    );

    final data = response.data as List<dynamic>;
    return data
        .map((e) => RadioStationModel.fromJson(e as Map<String, dynamic>))
        .where((s) => s.streamUrl.isNotEmpty)
        .toList();
  }
}
