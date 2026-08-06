import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/demo_seed.dart';
import '../../../core/network/dio_client.dart';

/// A place found by geocoding a free-text query.
class GeocodedPlace {
  const GeocodedPlace({
    required this.label,
    required this.lat,
    required this.lng,
  });

  final String label;
  final double lat;
  final double lng;
}

/// City / postal-code / address search via OSM Nominatim — real,
/// key-free, and biased to the selected country so "Toledo" resolves in
/// Spain for a Spanish user, not Ohio. Usage policy compliance: one
/// request per explicit user submit (never per keystroke), identifying
/// User-Agent, and failures degrade to "not found" without retries.
class GeocodingClient {
  GeocodingClient(this._dio);

  final Dio _dio;

  Future<GeocodedPlace?> search(String query) async {
    final q = query.trim();
    if (q.length < 2) return null;
    try {
      final res = await _dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': q,
          'format': 'jsonv2',
          'limit': 1,
          'countrycodes': DemoSeed.country.code.toLowerCase(),
        },
        options: Options(
          headers: {
            'User-Agent':
                'GroceryShoppingAssistant/1.0 (support@grocery-assistant.app)',
          },
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final first = res.data?.firstOrNull;
      if (first is! Map) return null;
      final lat = double.tryParse('${first['lat']}');
      final lng = double.tryParse('${first['lon']}');
      if (lat == null || lng == null) return null;
      final label = (first['display_name'] as String?)?.split(',').first ?? q;
      return GeocodedPlace(label: label, lat: lat, lng: lng);
    } catch (_) {
      return null;
    }
  }
}

final geocodingClientProvider = Provider<GeocodingClient>(
  (ref) => GeocodingClient(ref.watch(dioProvider)),
);
