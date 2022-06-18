import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import '../models/data_models.dart';
import './variables.dart';

class Data with ChangeNotifier {
  //
  List<DirectionsInfo> _directionsInfo = [];
  List<DirectionsInfo> get directionsInfo {
    return [..._directionsInfo];
  }

  //

  OverallInfo _overall;
  OverallInfo get overall {
    return _overall;
  }

  //
  LatLng _origin = const LatLng(15.3449591, 75.1015031);
  LatLng get getOrigin {
    return _origin;
  }

  String _destination = 'Delhi';
  String get getDestination {
    return _destination;
  }

  set setDestination(String destination) {
    _destination = destination;
    notifyListeners();
  }

  // * Methods

  //THis function sets the _directiosn Info from the api
  Future<void> directionsFromApi() async {
    String url;
    try {
      url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_origin.latitude},${_origin.longitude}&destination=$_destination&mode=walking&key=${Variables.apiKey}';

      final response = await http.get(Uri.parse(url));
      final jsondata = json.decode(response.body) as Map<String, dynamic>;
      final extractedData = jsondata['routes'][0]['legs'][0];
      final overallData = jsondata['routes'];
      final steps = extractedData['steps'];
      final List<DirectionsInfo> directionsInfo = [];

      steps.forEach((cur) {
        directionsInfo.add(
          DirectionsInfo(
            duration: cur['duration']['text'],
            durationMs: cur['duration']['value'],
            dist: cur['distance']['text'],
            htmlInstr: cur['html_instructions'],
            latlong: [cur['end_location']['lat'], cur['end_location']['lng']],
            poly: cur['polyline']['points'],
            travelMode: cur['travel_mode'],
          ),
        );
      });

      _directionsInfo = directionsInfo;
      debugPrint('Done with Directions Info');

      _overall = OverallInfo(
        endAddress: overallData[0]['legs'][0]['end_address'],
        endLoc: LatLng(overallData[0]['legs'][0]['end_location']['lat'],
            overallData[0]['legs'][0]['end_location']['lng']),
        neBound: LatLng(overallData[0]['bounds']['northeast']['lat'],
            overallData[0]['bounds']['northeast']['lng']),
        overviewPolyline: overallData[0]['overview_polyline']['points'],
        startAddress: overallData[0]['legs'][0]['start_address'],
        startLoc: LatLng(overallData[0]['legs'][0]['start_location']['lat'],
            overallData[0]['legs'][0]['end_location']['lng']),
        swBound: LatLng(overallData[0]['bounds']['northeast']['lat'],
            overallData[0]['bounds']['northeast']['lng']),
        totalDistance: overallData[0]['legs'][0]['distance']['text'],
        totalDuration: overallData[0]['legs'][0]['duration']['text'],
      );

      debugPrint('Done with Overall Info');

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  //This function locates to the current user location
  Future<void> getUserCurrentLocation() async {
    try {
      Location location = Location();
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _locationData = await location.getLocation();
      _origin = LatLng(_locationData.latitude, _locationData.longitude);
    } catch (err) {
      rethrow;
    }

    // try {
    //   final GoogleMapController controller = await _controller.future;
    //   controller.animateCamera(
    //     CameraUpdate.newCameraPosition(
    //       CameraPosition(
    //         // bearing: 192.8334901395799,
    //         target: LatLng(_lattitude!, _longitude!),
    //         zoom: 17,
    //         tilt: 30.0,
    //       ),
    //     ),
    //   );
    //   notifyListeners();
    // } catch (err) {
    //   rethrow;
    // }
  }

  makePostRequest() async {
    final uri = Uri.parse('http://httpbin.org/post');
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {'id': 21, 'name': 'yash', 'status': 200};
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    await http.post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    // int statusCode = response.statusCode;
    // String responseBody = response.body;
  }
}
