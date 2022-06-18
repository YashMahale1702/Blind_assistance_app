import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:text_to_speech/text_to_speech.dart';

import '../models/helpers.dart';
import '../provider/data_provider.dart';
import '../models/data_models.dart';

class MapsScreen extends StatefulWidget {
  static const routeName = '/maps_screen';

  const MapsScreen({Key key}) : super(key: key);
  @override
  State<MapsScreen> createState() => MapsScreenState();
}

class MapsScreenState extends State<MapsScreen> {
  bool _isloadingDirections = true;
  bool iserrorFound = false;
  TextToSpeech tts;
  List<DirectionsInfo> _data = [];
  OverallInfo _overallInfo;
  int polylineIDCounter = 0;

  final Set<Marker> _markers = <Marker>{};
  final Set<Polyline> _polylines = <Polyline>{};

  final Completer<GoogleMapController> _controller = Completer();
  final PanelController _panelController = PanelController();

  static const CameraPosition _initial = CameraPosition(
    target: LatLng(15.36, 75.12),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  Future<void> _changeCameraPos(CameraPosition newPos) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(newPos),
    );
  }

  @override
  void initState() {
    super.initState();
    tts = TextToSpeech();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    setState(() {
      _isloadingDirections = true;
    });

    //
    final data = Provider.of<Data>(context, listen: false);
    LatLng originLatlng = data.getOrigin;

    _changeCameraPos(
      CameraPosition(
        target: originLatlng,
        zoom: 16,
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        infoWindow: const InfoWindow(title: 'Current Location'),
        icon: BitmapDescriptor.defaultMarker,
        position: originLatlng,
      ),
    );

    //

    data.directionsFromApi().then((value) {
      _data = data.directionsInfo;
      _overallInfo = data.overall;
      _markers.add(
        Marker(
          markerId: const MarkerId('Destination'),
          infoWindow: const InfoWindow(title: 'Destination Location'),
          icon: BitmapDescriptor.defaultMarker,
          position: _overallInfo.endLoc,
        ),
      );
      PolylinePoints polylinePoints = PolylinePoints();
      _setPolyline(
        polylinePoints.decodePolyline(_overallInfo.overviewPolyline),
      );

      setState(() {
        _isloadingDirections = false;
      });
      tts.speak(Helpers.removeAllHtmlTags(_data[0].htmlInstr));
      int cumulative = 0;
      for (int i = 1; i < _data.length; i++) {
        cumulative += _data[i].durationMs;
        Future.delayed(Duration(seconds: cumulative)).then((value) {
          tts.speak(Helpers.removeAllHtmlTags(_data[i].htmlInstr));
        });
      }
    }).catchError((err) {
      setState(() {
        iserrorFound = true;
        _isloadingDirections = false;
      });
    });
  }

  void _setPolyline(List<PointLatLng> points) {
    int polylineIDCounter = 0;
    final String polyId = 'polyline_$polylineIDCounter';
    polylineIDCounter++;

    _polylines.add(
      Polyline(
        polylineId: PolylineId(polyId),
        width: 2,
        color: Colors.blue,
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maps and Directions"),
        leading: IconButton(
          onPressed: () {
            tts.stop();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.keyboard_arrow_left_rounded),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _changeCameraPos(_kLake),
      //   child: const Icon(Icons.location_on),
      // ),
      body: SlidingUpPanel(
        minHeight: 150.0,
        backdropEnabled: true,
        borderRadius: BorderRadius.circular(15.0),
        margin: const EdgeInsets.all(10.0),
        parallaxEnabled: true,
        controller: _panelController,
        body: Container(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 50.0),
          child: GoogleMap(
            padding: const EdgeInsets.all(20.0),
            mapType: MapType.normal,
            initialCameraPosition: _initial,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            myLocationButtonEnabled: true,
            onTap: (_) {},
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
        panel: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 5,
              width: 50,
              margin: const EdgeInsets.only(top: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _panelController.animatePanelToPosition(1);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Steps for Destination',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ],
            ),
            if (_isloadingDirections == true)
              const CircularProgressIndicator.adaptive(),
            if (iserrorFound) const Text('Something went wrong'),
            if (_isloadingDirections == false)
              Expanded(
                child: ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(15.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enableFeedback: true,
                        leading: CircleAvatar(
                          child: Text(
                            _data[index].dist,
                            style: const TextStyle(fontSize: 10.0),
                          ),
                        ),
                        // trailing: Text(_data[index].duration),
                        tileColor: Colors.white,
                        title: html.Html(data: _data[index].htmlInstr),
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}

// *FAB TO get user location
// floatingActionButton: GestureDetector(
      //   onTap: () => _getUserCurrentLocation(),
      //   child: Container(
      //     // margin: const EdgeInsets.symmetric(horizontal: 69),
      //     padding: const EdgeInsets.symmetric(
      //       horizontal: 90.0,
      //       vertical: 15.0,
      //     ),
      //     decoration: BoxDecoration(
      //       borderRadius: BorderRadius.circular(40.0),
      //       gradient: LinearGradient(
      //         colors: [
      //           Theme.of(context).primaryColor,
      //           Theme.of(context).accentColor,
      //         ],
      //       ),
      //     ),
      //     child: Text(
      //       'Get Location',
      //       style: TextStyle(
      //         color: Colors.white.withOpacity(.8),
      //         fontWeight: FontWeight.w600,
      //         fontSize: 18,
      //       ),
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,



      //* 

         // // final GoogleMapController controller = await _controller.future;
    // _controller.future
    //     .then((controller) => {
    //           setState(() {
    //             _loadingMap = false;
    //           }),
    //           controller.animateCamera(
    //             CameraUpdate.newCameraPosition(
    //               CameraPosition(
    //                 // bearing: 192.8334901395799,
    //                 target: LatLng(_lattitude!, _longitude!),
    //                 zoom: 17,
    //                 tilt: 30.0,
    //               ),
    //             ),
    //           )
    //         })
    //     .catchError((err) {
    //   setState(() {
    //     _loadingMap = false;
    //   });
    // });

