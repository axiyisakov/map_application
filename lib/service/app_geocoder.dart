/*
*================================Copyright©=====================================
?Name        : app_geocoder
*Author      : Axmadjon Isaqov
^Version     : CURRENT_VERSION
&Copyright   : Created by Axmadjon Isaqov on  16:53:52 25.04.2024*© 2024 @axiydev
!Description : map_application in Dart
*===============================================================================
*/
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:map_application/util/failure.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';

const _apiGeocoderKey = 'YOUR_YANDEX_GEOCODER_API_KEY';

abstract interface class GeoCoderService {
  YandexGeocoder get geocoder;

  Future<Either<Failures, GeocodeResponse>> getGeocoderFromPoint(
    ({double lat, double lon}) point,
  );

  void dispose();
}

class GeoCoderServiceImpl implements GeoCoderService {
  final YandexGeocoder _geocoder;
  GeoCoderServiceImpl({
    YandexGeocoder? geocoder,
  }) : _geocoder = geocoder ??
            YandexGeocoder(
              apiKey: _apiGeocoderKey,
            );

  @override
  YandexGeocoder get geocoder => _geocoder;

  @override
  Future<Either<Failures, GeocodeResponse>> getGeocoderFromPoint(
    ({double lat, double lon}) point,
  ) async {
    try {
      final response = await _geocoder
          .getGeocode(
        ReverseGeocodeRequest(
          pointGeocode: point,
          lang: Lang.enEn,
        ),
      )
          .then((value) {
        debugPrint("DAta::::$value");
        return value;
      });

      return Right(response);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return Left(GeocoderFailure());
    }
  }

  @override
  void dispose() {}
}
