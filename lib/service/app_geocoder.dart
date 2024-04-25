import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:map_application/util/failure.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';

const _apiGeocoderKey = 'b66479ba-0171-4dc0-b68d-cfacfe0721e2';

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
