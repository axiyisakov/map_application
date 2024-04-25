import 'package:equatable/equatable.dart';

sealed class Failures extends Equatable {
  final List<dynamic> properties;
  const Failures([this.properties = const <dynamic>[]]);

  @override
  List<Object?> get props => [properties];
}

class GeocoderFailure extends Failures {
  @override
  List<Object?> get props => [];
}
