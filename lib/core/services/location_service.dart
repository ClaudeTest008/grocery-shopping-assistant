import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';
import '../demo/demo_seed.dart';
import '../errors/failures.dart';
import '../platform/platform_support.dart';

/// Simple lat/lng pair so domain code never imports geolocator.
/// Distance is pure-Dart haversine — usable in unit tests and isolates.
class GeoPoint {
  const GeoPoint(this.lat, this.lng);
  final double lat;
  final double lng;

  double distanceKmTo(GeoPoint other) {
    const r = 6371.0;
    final dLat = _rad(other.lat - lat);
    final dLng = _rad(other.lng - lng);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(lat)) *
            math.cos(_rad(other.lat)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * r * math.asin(math.sqrt(a.toDouble()));
  }

  static double _rad(double deg) => deg * math.pi / 180;
}

/// Demo-mode home location — the selected country's demo city centre,
/// so distance features work without a real GPS fix anywhere.
GeoPoint get demoLocation =>
    GeoPoint(DemoSeed.country.lat, DemoSeed.country.lng);

class LocationService {
  Future<GeoPoint> currentPosition() async {
    if (AppConfig.isDemoMode) return demoLocation;

    // Desktop has no per-app permission prompt — location is a global
    // Windows setting the app cannot deep-link to (geolocator's
    // openLocationSettings is unimplemented there). Falling back keeps
    // stores, distances and the optimizer usable instead of dead-ending
    // the whole screen on an error the user cannot act on from here.
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (PlatformSupport.isDesktop) return demoLocation;
      throw const PermissionFailure('Location services disabled');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (PlatformSupport.isDesktop) return demoLocation;
      throw const PermissionFailure('Location permission denied');
    }
    final pos = await Geolocator.getCurrentPosition();
    return GeoPoint(pos.latitude, pos.longitude);
  }
}

final locationServiceProvider = Provider((_) => LocationService());

final currentLocationProvider = FutureProvider<GeoPoint>(
  (ref) => ref.watch(locationServiceProvider).currentPosition(),
);
