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

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:map_application/data/app_lat_lang.dart';
import 'package:map_application/service/app_geocoder.dart';
import 'package:map_application/service/app_geolocator.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart' hide Point;
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';

abstract interface class IMapService {
  void dispose();
  void onMapCreated(YandexMapController controller);

  Future<void> moveToCurrentPosition();

  void onCameraPositionChanged(
    CameraPosition position,
    CameraUpdateReason reason,
    bool finished,
    VisibleRegion visibleRegion,
  );

  GeolocatorService get geolocator;
  Stream<List<PlacemarkMapObject>> get streamPlacemark;

  Sink<List<PlacemarkMapObject>> get sinkPlacemark;

  Stream<GeocodeResponse> get streamGeocoder;

  Sink<GeocodeResponse> get sinkGeocoder;

  Stream<bool> get streamAnimation;

  Sink<bool> get sinkAnimation;
}

class MapServiceImpl extends IMapService {
  final GeolocatorService _iGeolocatorService;
  final Completer<YandexMapController> _completer;
  final StreamController<List<PlacemarkMapObject>> _streamController;
  final StreamController<GeocodeResponse> _geocodeResponseController;
  final StreamController<bool> _animationController;
  final GeoCoderService _geoCoderService;
  MapServiceImpl({
    GeolocatorService? geolocator,
    GeoCoderService? geoCoderService,
    required Completer<YandexMapController>? completer,
  })  : _geoCoderService = geoCoderService ?? GeoCoderServiceImpl(),
        _streamController = StreamController(),
        _animationController = StreamController(),
        _geocodeResponseController = StreamController(),
        _completer = completer ?? Completer<YandexMapController>(),
        _iGeolocatorService = geolocator ?? GeolocatorServiceImpl();

  @override
  GeolocatorService get geolocator => _iGeolocatorService;

  @override
  void dispose() async {
    final controller = await _completer.future;
    controller.dispose();
    _streamController.close();
    _geocodeResponseController.close();
    _animationController.close();
  }

  @override
  void onMapCreated(YandexMapController controller) async {
    _completer.complete(controller);
    sinkAnimation.add(true);
  }

  @override
  void onCameraPositionChanged(
    CameraPosition position,
    CameraUpdateReason reason,
    bool finished,
    VisibleRegion visibleRegion,
  ) async {
    sinkAnimation.add(false);
    if (finished) {
      debugPrint(
        'ON CAMERA POSITION CHANGED: $position, $reason, $finished, $visibleRegion',
      );
      final dataOrError = await _geoCoderService.getGeocoderFromPoint((
        lat: position.target.latitude,
        lon: position.target.longitude,
      ));

      debugPrint(dataOrError.toString());

      if (dataOrError.isRight()) {
        final geocoderResponse = dataOrError.fold(
          (error) => null,
          (data) => data,
        );
        EasyDebounce.debounce(
          'debounce',
          const Duration(
            milliseconds: 200,
          ),
          () {
            ///add geocoder data
            sinkGeocoder.add(geocoderResponse!);
            sinkAnimation.add(true);
          },
        );
      }

      // sinkPlacemark.add(
      //   List.from(
      //     [
      //       PlacemarkMapObject(
      //         mapId: const MapObjectId('marker1'),
      //         icon: PlacemarkIcon.single(
      //           PlacemarkIconStyle(
      //             scale: .3,
      //             image: BitmapDescriptor.fromAssetImage(
      //               'assets/icons/marker1.png',
      //             ),
      //           ),
      //         ),
      //         point: Point(
      //           latitude: position.target.latitude,
      //           longitude: position.target.longitude,
      //         ),
      //       ),
      //     ],
      //   ),
      // );
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
            zoom: 14,
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
  Stream<List<PlacemarkMapObject>> get streamPlacemark =>
      _streamController.stream;

  @override
  Sink<List<PlacemarkMapObject>> get sinkPlacemark => _streamController.sink;

  @override
  Sink<GeocodeResponse> get sinkGeocoder => _geocodeResponseController.sink;

  @override
  Stream<GeocodeResponse> get streamGeocoder =>
      _geocodeResponseController.stream;

  @override
  Sink<bool> get sinkAnimation => _animationController.sink;

  @override
  Stream<bool> get streamAnimation => _animationController.stream;
}
