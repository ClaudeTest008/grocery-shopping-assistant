import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
abstract class Store with _$Store {
  const Store._();

  const factory Store({
    required String id,
    required String name,

    /// Chain identifier: mercadona, lidl, kroger... — meaningful only
    /// within a country (Carrefour ES and Carrefour FR are separate
    /// datasets that happen to share an id).
    required String chain,
    required String address,
    required double lat,
    required double lng,

    /// ISO 3166-1 alpha-2; null on rows created before countries existed
    /// (treated as the legacy US dataset).
    String? country,
    String? city,
    String? logoUrl,
    String? phone,

    /// Weekday (1=Mon..7=Sun, as strings) -> "08:00-21:00" or "closed".
    Map<String, String>? openingHours,

    /// Customer parking on site.
    bool? hasParking,

    /// Step-free access; null = unknown, shown as such.
    bool? wheelchairAccessible,

    /// In-store services: bakery, pharmacy, click_collect, fuel,
    /// butcher, fish_counter... free-form data, rendered title-cased.
    List<String>? services,

    /// Filled in client-side from user location; not persisted.
    double? distanceKm,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  bool get isOpenNow {
    final closing = _closingMinuteToday;
    if (closing == null) return false;
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    return nowMin >= _openingMinuteToday! && nowMin < closing;
  }

  /// Open now but shutting within the hour — the "go now or skip it"
  /// signal a shopper planning tonight's trip actually needs.
  bool get isClosingSoon {
    if (!isOpenNow) return false;
    final now = DateTime.now();
    return _closingMinuteToday! - (now.hour * 60 + now.minute) <= 60;
  }

  int? get _openingMinuteToday => _minutes(0);
  int? get _closingMinuteToday => _minutes(1);

  int? _minutes(int part) {
    final hours = openingHours?['${DateTime.now().weekday}'];
    if (hours == null || hours == 'closed') return null;
    final parts = hours.split('-');
    if (parts.length != 2) return null;
    final p = parts[part].split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  /// Rough drive time from distance assuming 35 km/h urban average.
  Duration get driveTime => distanceKm == null
      ? Duration.zero
      : Duration(minutes: (distanceKm! / 35 * 60).round());
}
