import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
abstract class Store with _$Store {
  const Store._();

  const factory Store({
    required String id,
    required String name,

    /// Chain identifier: aldi, walmart, kroger...
    required String chain,
    required String address,
    required double lat,
    required double lng,
    String? logoUrl,
    String? phone,

    /// Weekday (1=Mon..7=Sun, as strings) -> "08:00-21:00" or "closed".
    Map<String, String>? openingHours,

    /// Filled in client-side from user location; not persisted.
    double? distanceKm,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  bool get isOpenNow {
    final hours = openingHours?['${DateTime.now().weekday}'];
    if (hours == null || hours == 'closed') return false;
    final parts = hours.split('-');
    if (parts.length != 2) return false;
    int minutes(String hhmm) {
      final p = hhmm.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    }

    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    return nowMin >= minutes(parts[0]) && nowMin < minutes(parts[1]);
  }

  /// Rough drive time from distance assuming 35 km/h urban average.
  Duration get driveTime => distanceKm == null
      ? Duration.zero
      : Duration(minutes: (distanceKm! / 35 * 60).round());
}
