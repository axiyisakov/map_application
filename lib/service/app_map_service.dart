/*
*================================Copyright©=====================================
?Name        : app_map_service
*Author      : Axmadjon Isaqov
^Version     : CURRENT_VERSION
&Copyright   : Created by Axmadjon Isaqov on  19:03:52 24.04.2024*© 2024 @axiydev
!Description : map_application in Dart
*===============================================================================
*/
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_application/data/app_lat_lang.dart';
import 'package:map_application/service/app_geolocator.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';

abstract interface class IMapService {
  final GeolocatorService _iGeolocatorService;
  void dispose();
  IMapService(this._iGeolocatorService);
  void onMapCreated(YandexMapController controller);

  Future<void> moveToCurrentPosition();

  void onCameraPositionChanged(
    CameraPosition position,
    CameraUpdateReason reason,
    bool finished,
    VisibleRegion visibleRegion,
  );

  GeolocatorService get geolocator;
  Stream<List<PlacemarkMapObject>> get stream;

  Sink<List<PlacemarkMapObject>> get sink;
}

class MapServiceImpl extends IMapService {
  final Completer<YandexMapController> _completer;
  final StreamController<List<PlacemarkMapObject>> _streamController;
  MapServiceImpl({
    GeolocatorService? geolocator,
    required Completer<YandexMapController>? completer,
  })  : _streamController = StreamController(),
        _completer = completer ?? Completer<YandexMapController>(),
        super(geolocator ?? GeolocatorServiceImpl());

  @override
  GeolocatorService get geolocator => _iGeolocatorService;

  @override
  void dispose() async {
    final controller = await _completer.future;
    controller.dispose();
    _streamController.close();
  }

  @override
  void onMapCreated(YandexMapController controller) async {
    _completer.complete(controller);
  }

  @override
  void onCameraPositionChanged(
    CameraPosition position,
    CameraUpdateReason reason,
    bool finished,
    VisibleRegion visibleRegion,
  ) async {
    if (finished) {
      debugPrint(
        'ON CAMERA POSITION CHANGED: $position, $reason, $finished, $visibleRegion',
      );
      sink.add(
        List.from(
          [
            PlacemarkMapObject(
              mapId: const MapObjectId('marker1'),
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                  scale: .3,
                  image: BitmapDescriptor.fromAssetImage(
                    'assets/icons/marker1.png',
                  ),
                ),
              ),
              point: Point(
                latitude: position.target.latitude,
                longitude: position.target.longitude,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Future<void> moveToCurrentPosition() async {
    try {
      // final currentPosition = await _iGeolocatorService.getCurrentPosition();

      // final isolatedPosition = await Isolate.run(() {
      //   return currentPosition;
      // });
      final tashkentLocation = TashkentLocation();

      (await _completer.future).moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            // target: isolatedPosition.toPoint,
            target: Point(
              latitude: tashkentLocation.lat,
              longitude: tashkentLocation.long,
            ),
            zoom: 12,
          ),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 1,
        ),
      );
    } catch (error) {
      _completer.completeError(error);
    }
  }

  @override
  Stream<List<PlacemarkMapObject>> get stream => _streamController.stream;

  @override
  Sink<List<PlacemarkMapObject>> get sink => _streamController.sink;
}
