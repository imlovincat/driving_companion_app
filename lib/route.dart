import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_icon/marker_icon.dart';
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
  late List<dynamic> list = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  late Timer timer;


  @override
  void initState() {
    super.initState();
    list = widget.trip;
    timer = Timer.periodic(Duration(milliseconds: 1000), (Timer t) {
      polylineSet(list);
      setSpeedMarker(list);
    });

    //LatLngBounds bound = LatLngBounds(southwest: list[0][2], northeast: list[list.length-1][2]);
  }

  @override
  Widget build(BuildContext context) {

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
                            zoom: 16.5, //14.4746
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

  Future polylineSet(List<dynamic> list) async{
    _polylines = {};
    Color polyColor = Color.fromARGB(255, 153, 204, 255);
    List<LatLng> polylineCoordinates = [];

    for (var i = 1; i < list.length; i++) {
      Duration(milliseconds: 200);
      setState(() {
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

  Future setSpeedMarker(List<dynamic> list) async {

    BitmapDescriptor a1 = await MarkerIcon.circleCanvasWithText(
        size: Size(50, 50),
        text: '∧',
        circleColor:Color.fromARGB(255, 248, 213, 148),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor a2 = await MarkerIcon.circleCanvasWithText(
        size: Size(50, 50),
        text: '∧',
        circleColor:Color.fromARGB(255, 239, 190, 102),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor a3 = await MarkerIcon.circleCanvasWithText(
        size: Size(50, 50),
        text: '∧',
        circleColor:Color.fromARGB(255, 220, 176, 61),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor a4 = await MarkerIcon.circleCanvasWithText(
        size: Size(50, 50),
        text: '∧',
        circleColor:Color.fromARGB(255, 220, 148, 61),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor a5 = await MarkerIcon.circleCanvasWithText(
        size: Size(50, 50),
        text: '∧',
        circleColor:Color.fromARGB(255, 208, 108, 37),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor d1 = await MarkerIcon.circleCanvasWithText(
        size: Size(50, 50),
        text: '∨',
        circleColor:Color.fromARGB(255, 243, 157, 157),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor d2 = await MarkerIcon.circleCanvasWithText(
        size: Size(50, 50),
        text: '∨',
        circleColor:Color.fromARGB(255, 246, 123, 123),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor d3 = await MarkerIcon.circleCanvasWithText(
        size: Size(50, 50),
        text: '∨',
        circleColor:Color.fromARGB(255, 239, 103, 103),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor d4 = await MarkerIcon.circleCanvasWithText(
        size: Size(50, 50),
        text: '∨',
        circleColor:Color.fromARGB(255, 239, 73, 73),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor d5 = await MarkerIcon.circleCanvasWithText(
        size: Size(50, 50),
        text: '∨',
        circleColor:Color.fromARGB(255, 243, 19, 19),
        fontColor: Colors.white,fontSize: 35);

    //_markers = {};
    _markers.add(Marker(
      markerId: MarkerId("Departure"),
      draggable: false,
      position: LatLng(list[0][2].latitude,list[0][2].longitude),
      infoWindow: InfoWindow(
        title: "Start point",
        snippet: "${list[0][0]}",
      ),
      icon: BitmapDescriptor.defaultMarker,
      //icon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(),'assets/images/a1.png'),
      //icon: BitmapDescriptor.defaultMarkerWithHue(80.0),
    ));
    _markers.add(Marker(
      markerId: MarkerId("Destination"),
      draggable: false,
      position: LatLng(list[list.length-1][2].latitude,list[list.length-1][2].longitude),
      infoWindow: InfoWindow(
          title: "End point",
          snippet: "${list[list.length-1][0]}"
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(220.0),
    ));

    for (var i = 1; i < list.length; i++) {
      setState(() {
        //var currentGeoPoint = list[i][2];
        //var currentSpeed = list[i][1];
        //var lastSpeed = list[i-1][1];

        //acceleration
        if (list[i][1] - list[i-1][1] >= getSharpSpeedValue("a1")) {
          if (list[i][1] - list[i-1][1] >= getSharpSpeedValue("a5")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 5"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Accelerating: ${list[i-1][1]} -> ${list[i][1]} kph',
                snippet: '${list[i][0]}',
              ),
              icon: a5,
            ));
          }
          else if (list[i][1] - list[i-1][1] >= getSharpSpeedValue("a4")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 4"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Accelerating: ${list[i-1][1]} -> ${list[i][1]} kph',
                snippet: '${list[i][0]}',
              ),
              icon: a4,
            ));
          }
          else if (list[i][1] - list[i-1][1] >= getSharpSpeedValue("a3")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 3"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: ' Accelerating: ${list[i-1][1]} -> ${list[i][1]} kph',
                snippet: '${list[i][0]}',
              ),
              icon: a3,
            ));
          }
          else if (list[i][1] - list[i-1][1] >= getSharpSpeedValue("a2")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 2"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Accelerating: ${list[i-1][1]} -> ${list[i][1]} kph',
                snippet: '${list[i][0]}',
              ),
              icon: a2,
            ));
          }
          else {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 1"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Accelerating: ${list[i-1][1]} -> ${list[i][1]} kph',
                snippet: '${list[i][0]}',
              ),
              icon: a1,
            ));
          }
        }
        else if (list[i-1][1] - list[i][1] >= getSharpSpeedValue("d1")) {
          if (list[i-1][1] - list[i][1] >= getSharpSpeedValue("d5")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 5"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Braking: ${list[i-1][1]} -> ${list[i][1]} kph',
                snippet: '${list[i][0]}',
              ),
              icon: d5,
            ));
          }
          else if (list[i-1][1] - list[i][1] >= getSharpSpeedValue("d4")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 4"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Braking: ${list[i-1][1]} -> ${list[i][1]} kph',
                snippet: '${list[i][0]}',
              ),
              icon: d4,
            ));
          }
          else if (list[i-1][1] - list[i][1] >= getSharpSpeedValue("d3")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 3"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Braking: ${list[i-1][1]} -> ${list[i][1]} kph',
                snippet: '${list[i][0]}',
              ),
              icon: d3,
            ));
          }
          else if (list[i-1][1] - list[i][1] >= getSharpSpeedValue("d2")) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 2"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Braking: ${list[i-1][1]} -> ${list[i][1]} kph',
                snippet: '${list[i][0]}',
              ),
              icon: d2,
            ));
          }
          else {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 1"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Braking: ${list[i-1][1]} -> ${list[i][1]} kph',
                snippet: '${list[i][0]}',
              ),
              icon: d1,
            ));
          }
        }
      });
    }
  }
}
