class AppLatLong {
  final double lat;
  final double long;

  AppLatLong({
    required this.long,
    required this.lat,
  });
}

class TashkentLocation extends AppLatLong {
  TashkentLocation({
    super.lat = 41.311081,
    super.long = 69.240562,
  });
}
