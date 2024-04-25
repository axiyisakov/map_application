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
import 'package:map_application/service/app_geocoder.dart';
import 'package:map_application/service/app_geolocator.dart';
import 'package:map_application/service/app_map_service.dart';
import 'package:map_application/widget/animated_map_marker.dart';
import 'package:map_application/widget/geocode_info_widget.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';

const _apiGeocoderKey = 'YOUR_YANDEX_GEOCODER_API_KEY';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final IMapService _iMapService;
  late final GeoCoderService _geoCoderService;
  late final GeolocatorService _geolocatorService;
  final Completer<YandexMapController> _controllerCompleter =
      Completer<YandexMapController>();
  final tashkentLocation = TashkentLocation();

  @override
  void initState() {
    _geoCoderService = GeoCoderServiceImpl(
      geocoder: YandexGeocoder(
        apiKey: _apiGeocoderKey,
      ),
    );
    _geolocatorService = GeolocatorServiceImpl();
    _iMapService = MapServiceImpl(
      geolocator: _geolocatorService,
      completer: _controllerCompleter,
      geoCoderService: _geoCoderService,
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
        title: StreamBuilder<GeocodeResponse?>(
          stream: _iMapService.streamGeocoder,
          builder: (context, snapshotGeocode) {
            if (snapshotGeocode.hasData) {
              return GeocodeInfoWidget(
                response: snapshotGeocode.data!,
              );
            } else if (snapshotGeocode.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            return const Text('Yandex Maps');
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async => _iMapService.moveToCurrentPosition(),
        label: const Text('zoom'),
      ),
      body: StreamBuilder<List<PlacemarkMapObject>>(
        stream: _iMapService.streamPlacemark,
        initialData: List.empty(
          growable: true,
        ),
        builder: (context, snapshot) {
          return Stack(
            children: [
              YandexMap(
                mapObjects: [
                  ...?snapshot.data,
                ],
                onMapCreated: _iMapService.onMapCreated,
                onCameraPositionChanged: _iMapService.onCameraPositionChanged,
              ),
              Align(
                alignment: Alignment.center,
                child: StreamBuilder<bool>(
                  stream: _iMapService.streamAnimation,
                  initialData: true,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return AppAnimatedIcon(
                        isHovering: snapshot.data ?? true,
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else {
                      return const AppAnimatedIcon();
                    }
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
