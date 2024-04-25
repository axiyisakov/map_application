import 'package:flutter/material.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';

class GeocodeInfoWidget extends StatelessWidget {
  final GeocodeResponse response;
  const GeocodeInfoWidget({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(response.firstAddress!.formatted ?? ''),
      ),
    );
  }
}
