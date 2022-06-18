import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsInfo {
  final String htmlInstr;
  final String dist;
  final String duration;
  final int durationMs;
  final String travelMode;
  final List<double> latlong;
  final String poly;

  DirectionsInfo({
    @required this.duration,
    @required this.dist,
    @required this.htmlInstr,
    @required this.latlong,
    @required this.poly,
    @required this.travelMode,
    @required this.durationMs,
  });
}

class OverallInfo {
  final String totalDistance;
  final String totalDuration;
  final String endAddress;
  final String startAddress;
  final LatLng startLoc;
  final LatLng endLoc;
  final LatLng swBound;
  final LatLng neBound;
  final String overviewPolyline;

  OverallInfo({
    @required this.endAddress,
    @required this.endLoc,
    @required this.neBound,
    @required this.overviewPolyline,
    @required this.startAddress,
    @required this.startLoc,
    @required this.swBound,
    @required this.totalDistance,
    @required this.totalDuration,
  });
}
