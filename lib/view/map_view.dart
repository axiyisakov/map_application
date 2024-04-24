/*
*================================Copyright©=====================================
?Name        : map_view
*Author      : Axmadjon Isaqov
^Version     : CURRENT_VERSION
&Copyright   : Created by Axmadjon Isaqov on  19:05:33 24.04.2024*© 2024 @axiydev
!Description : map_application in Dart
*===============================================================================
*/
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_application/data/app_lat_lang.dart';
import 'package:map_application/service/app_geolocator.dart';
import 'package:map_application/service/app_map_service.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final IMapService _iMapService;
  late final GeolocatorService _geolocatorService;
  final Completer<YandexMapController> _controllerCompleter =
      Completer<YandexMapController>();
  final tashkentLocation = TashkentLocation();
  @override
  void initState() {
    _geolocatorService = GeolocatorServiceImpl();
    _iMapService = MapServiceImpl(
      geolocator: _geolocatorService,
      completer: _controllerCompleter,
    );
    super.initState();
  }

  @override
  void dispose() {
    _iMapService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yandex Maps'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async => _iMapService.moveToCurrentPosition(),
        label: const Text('zoom'),
      ),
      body: StreamBuilder<List<PlacemarkMapObject>>(
          stream: _iMapService.stream,
          initialData: List.empty(
            growable: true,
          ),
          builder: (context, snapshot) {
            return YandexMap(
              mapObjects: [
                ...?snapshot.data,
              ],
              onMapCreated: _iMapService.onMapCreated,
              onCameraPositionChanged: _iMapService.onCameraPositionChanged,
            );
          }),
    );
  }
}
