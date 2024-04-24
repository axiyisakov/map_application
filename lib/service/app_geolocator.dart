/*
*================================Copyright©=====================================
?Name        : app_geolocator
*Author      : Axmadjon Isaqov
^Version     : CURRENT_VERSION
&Copyright   : Created by Axmadjon Isaqov on  19:04:04 24.04.2024*© 2024 @axiydev
!Description : map_application in Dart
*===============================================================================
*/
import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart' as yandex;

abstract interface class GeolocatorService {
  Future<Position> getCurrentPosition();
}

class GeolocatorServiceImpl extends GeolocatorService {
  @override
  Future<Position> getCurrentPosition() async {
    final Completer<Position> completer = Completer<Position>();
    final Completer<bool> permissionCompleter = Completer<bool>();
    try {
      permissionCompleter.complete(_checkPermission());

      final hasPermission = await permissionCompleter.future;

      if (hasPermission) {
        completer.complete(Geolocator.getCurrentPosition());
      } else {
        completer.completeError(
          Future.error('Location permissions are denied'),
        );
      }
    } catch (error) {
      completer.completeError(error);
      permissionCompleter.completeError(error);
    }
    return completer.future;
  }

  Future<bool> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return serviceEnabled;
  }
}

extension PositionToPoint on Position {
  yandex.Point get toPoint => yandex.Point(
        latitude: latitude,
        longitude: longitude,
      );
}
