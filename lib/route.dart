import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'sharpSpeed.dart';
import 'menu.dart';
import 'review.dart';

class RoutePage extends StatefulWidget {
  final String mode;
  final List<dynamic> trip;
  RoutePage(this.mode,this.trip);
  @override
  RouteState createState() => RouteState();
}

class RouteState extends State<RoutePage> {

  Completer<GoogleMapController> _controller = Completer();
  List<dynamic> list = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    polylineSet(list);
    setSpeedMarker(list);
    //LatLngBounds bound = LatLngBounds(southwest: list[0][2], northeast: list[list.length-1][2]);
  }

  @override
  Widget build(BuildContext context) {

    list = widget.trip;
    //polylineSet(list);

    return WillPopScope(
        onWillPop: () async {
          return Future.value(false);
        },
        child: MaterialApp(
          home: Scaffold(
              appBar: PreferredSize(
                  preferredSize: Size(double.infinity, 60),
                  child: AppBar(
                    title: Text('Journey Route 3'),
                    centerTitle: true,
                    backgroundColor: Colors.black,
                    //leading: Icon(Icons.account_circle_rounded),
                    leading: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(
                            builder: (context) => Menu()
                        ));
                      },
                      icon: Icon(Icons.home_outlined),
                    ),
                    elevation: 0, //remove shadow effect
                  )
              ),
              body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        color: Colors.black,
                        height: 600,
                        padding: EdgeInsets.only(
                          bottom:0,
                        ),
                        child: GoogleMap (
                          myLocationEnabled: false,
                          compassEnabled: true,
                          tiltGesturesEnabled: false,
                          mapType: MapType.normal,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: true,
                          zoomGesturesEnabled: true,
                          scrollGesturesEnabled: true,
                          rotateGesturesEnabled: true,
                          polylines: _polylines,
                          markers: _markers,

                          initialCameraPosition: CameraPosition(
                            target: LatLng(list[0][2].latitude, list[0][2].longitude),
                            zoom: 14.5, //14.4746
                          ),

                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton.icon(
                            icon: Icon(Icons.menu),
                              label: Text('Quit'),
                              textColor: Colors.grey,
                              onPressed:() {
                                if (widget.mode == "monitor") {
                                  Navigator.push(
                                      context, MaterialPageRoute(
                                      builder: (context) => Menu()
                                  ));
                                }
                                else if (widget.mode == "review") {
                                  Navigator.push(
                                      context, MaterialPageRoute(
                                      builder: (context) => Review()
                                  ));
                                }
                              }
                          ),
                          SizedBox(width:50),
                          RaisedButton.icon(
                              icon: Icon(Icons.refresh),
                              label: Text("Refresh"),
                              textColor: Colors.grey,
                              onPressed:() {
                                setState(() {
                                  polylineSet(list);
                                  setSpeedMarker(list);
                                });
                              }
                          ),
                        ],
                      ),
                    ]
                ),
              ),
          ),
        ));
  }
  @override
  void dispose() {
    super.dispose();
  }

  polylineSet(List<dynamic> list) async{

    _polylines = {};

    Color polyColor = Color.fromARGB(255, 153, 204, 255);
    List<LatLng> polylineCoordinates = [];

    for (var i = 1; i < list.length; i++) {
      Duration(milliseconds: 200);
      setState(() async{
        var currentGeoPoint = list[i][2];
        polylineCoordinates.add(LatLng(currentGeoPoint.latitude, currentGeoPoint.longitude));
        Polyline polyline = Polyline(
            polylineId: PolylineId('poly'),
            color: polyColor,
            width: 6,
            points: polylineCoordinates
        );
        _polylines.add(polyline);
      });
    }
  }

  setSpeedMarker(List<dynamic> list) async {
    _markers = {};

    BitmapDescriptor a1_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpAcceleration1.png",
    );

    BitmapDescriptor a2_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpAcceleration2.png",
    );

    BitmapDescriptor a3_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpAcceleration3.png",
    );

    BitmapDescriptor a4_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpAcceleration4.png",
    );

    BitmapDescriptor a5_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpAcceleration5.png",
    );

    BitmapDescriptor d1_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpDeceleration1.png",
    );

    BitmapDescriptor d2_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpDeceleration2.png",
    );

    BitmapDescriptor d3_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpDeceleration3.png",
    );

    BitmapDescriptor d4_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpDeceleration4.png",
    );

    BitmapDescriptor d5_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpDeceleration5.png",
    );

    _markers.add(Marker(
      markerId: MarkerId("Departure"),
      draggable: false,
      position: LatLng(list[0][2].latitude,list[0][2].longitude),
      infoWindow: InfoWindow(
        title: "Start point",
        snippet: "${list[0][0]}",
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));
    _markers.add(Marker(
      markerId: MarkerId("Destination"),
      draggable: false,
      position: LatLng(list[list.length-1][2].latitude,list[list.length-1][2].longitude),
      infoWindow: InfoWindow(
          title: "end point",
          snippet: "${list[list.length-1][0]}"
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(60.0),
    ));

    for (var i = 1; i < list.length; i++) {
      setState(() async{
        var currentGeoPoint = list[i][2];
        var currentSpeed = list[i][1];
        var lastSpeed = list[i-1][1];

        //acceleration
        if (currentSpeed - lastSpeed >= getSharpSpeedValue("a1")) {
          if (currentSpeed - lastSpeed >= getSharpSpeedValue("a5")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 5"),
              draggable: false,
              position: LatLng(currentGeoPoint.latitude,currentGeoPoint.longitude),
              infoWindow: InfoWindow(
                title: 'Accelerating: $lastSpeed -> $currentSpeed kph',
                snippet: '${list[i][0]}',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ));
          }
          else if (currentSpeed - lastSpeed >= getSharpSpeedValue("a4")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 4"),
              draggable: false,
              position: LatLng(currentGeoPoint.latitude,currentGeoPoint.longitude),
              infoWindow: InfoWindow(
                title: 'Accelerating: $lastSpeed -> $currentSpeed kph',
                snippet: '${list[i][0]}',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ));
          }
          else if (currentSpeed - lastSpeed >= getSharpSpeedValue("a3")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 3"),
              draggable: false,
              position: LatLng(currentGeoPoint.latitude,currentGeoPoint.longitude),
              infoWindow: InfoWindow(
                title: ' Accelerating: $lastSpeed -> $currentSpeed kph',
                snippet: '${list[i][0]}',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ));
          }
          else if (currentSpeed - lastSpeed >= getSharpSpeedValue("a2")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 2"),
              draggable: false,
              position: LatLng(currentGeoPoint.latitude,currentGeoPoint.longitude),
              infoWindow: InfoWindow(
                title: 'Accelerating: $lastSpeed -> $currentSpeed kph',
                snippet: '${list[i][0]}',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ));
          }
          else {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 1"),
              draggable: false,
              position: LatLng(currentGeoPoint.latitude,currentGeoPoint.longitude),
              infoWindow: InfoWindow(
                title: 'Accelerating: $lastSpeed -> $currentSpeed kph',
                snippet: '${list[i][0]}',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ));
          }
        }
        else if (lastSpeed - currentSpeed >= getSharpSpeedValue("d1")) {
          if (lastSpeed - currentSpeed >= getSharpSpeedValue("d5")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 5"),
              draggable: false,
              position: LatLng(currentGeoPoint.latitude,currentGeoPoint.longitude),
              infoWindow: InfoWindow(
                title: 'Braking: $lastSpeed -> $currentSpeed kph',
                snippet: '${list[i][0]}',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ));
          }
          else if (lastSpeed - currentSpeed >= getSharpSpeedValue("d4")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 4"),
              draggable: false,
              position: LatLng(currentGeoPoint.latitude,currentGeoPoint.longitude),
              infoWindow: InfoWindow(
                title: 'Braking: $lastSpeed -> $currentSpeed kph',
                snippet: '${list[i][0]}',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ));
          }
          else if (lastSpeed - currentSpeed >= getSharpSpeedValue("d3")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 3"),
              draggable: false,
              position: LatLng(currentGeoPoint.latitude,currentGeoPoint.longitude),
              infoWindow: InfoWindow(
                title: 'Braking: $lastSpeed -> $currentSpeed kph',
                snippet: '${list[i][0]}',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ));
          }
          else if (lastSpeed - currentSpeed >= getSharpSpeedValue("d2")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 2"),
              draggable: false,
              position: LatLng(currentGeoPoint.latitude,currentGeoPoint.longitude),
              infoWindow: InfoWindow(
                title: 'Braking: $lastSpeed -> $currentSpeed kph',
                snippet: '${list[i][0]}',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ));
          }
          else {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 1"),
              draggable: false,
              position: LatLng(currentGeoPoint.latitude,currentGeoPoint.longitude),
              infoWindow: InfoWindow(
                title: 'Braking: $lastSpeed -> $currentSpeed kph',
                snippet: '${list[i][0]}',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ));
          }
        }
      });
    }
  }
}
