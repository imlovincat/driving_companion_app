import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_icon/marker_icon.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'drivingScore.dart';
import 'algorithmJson.dart';
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
  late List<double> getPercentage = [0,0,0];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  late Timer timer;
  Color speedingColor = Colors.red;
  Color acceleratingColor = Colors.red;
  Color deceleratingColor = Colors.red;
  Map<String, dynamic> rule = {};


  @override
  void initState() {
    super.initState();
    list = widget.trip;


    getJson().then((json) => setState(() {
      rule = getRule(json);
      print("rule: $rule");
      getRating(json,list).then((val) => setState(() {
        getPercentage = val;
        getSpeedColor(getPercentage);
      }));
    }));

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
                    title: Text('Driving Details'),
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
                        height: 400,
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
                      SizedBox(
                          height: 20
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(30,10,30,10),
                        child: LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width - 65,
                          animation: true,
                          lineHeight: 30.0,
                          animationDuration: 2500,
                          percent: getPercentage[0],
                          center: Text("Speeding: ${(getPercentage[0]*100).toInt()}%"),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: speedingColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(30,10,30,10),
                        child: LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width - 65,
                          animation: true,
                          lineHeight: 30.0,
                          animationDuration: 2500,
                          percent: getPercentage[1],
                          center: Text("Accelerating: ${(getPercentage[1]*100).toInt()}%"),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: acceleratingColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(30,10,30,10),
                        child: LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width - 65,
                          animation: true,
                          lineHeight: 30.0,
                          animationDuration: 2500,
                          percent: getPercentage[2],
                          center: Text("Braking: ${(getPercentage[2]*100).toInt()}%"),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: deceleratingColor,
                        ),
                      ),

                      SizedBox(
                          height:20
                      ),
                      SizedBox(
                        width: 160,
                        height: 50,
                        child: RaisedButton.icon(
                            icon: Icon(Icons.home),
                            color: Colors.blueAccent,
                            label: Text(
                              'Home',
                              style: TextStyle(color: Colors.black, fontSize: 22),
                            ),
                            //textColor: Colors.grey,
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
                      ),
                      SizedBox(
                          height: 30
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

  getJson() async{
    AlgorithmJson json = AlgorithmJson.fromJson(await SessionManager().get('scoring'));
    return json;
  }

  Map<String, dynamic> getRule(AlgorithmJson json) {
    Map<String, dynamic> rule = {};
    List<int> speeding = [];
    List<int> braking = [];
    List<int> accelerating = [];
    for (var i = 0; i < json.speeding.length; i++) {
      speeding.add(json.speeding[i].toInt());
    }
    for (var i = 0; i < json.braking.length; i++) {
      braking.add(json.braking[i].toInt());
    }
    for (var i = 0; i < json.accelerating.length; i++) {
      accelerating.add(json.accelerating[i].toInt());
    }
    rule['speeding'] = speeding;
    rule['braking'] = braking;
    rule['accelerating'] = accelerating;
    return rule;
  }

  getSpeedColor(List<double> list) {

    if (list[0] >= 0.9) {
      speedingColor = Colors.green;
    }
    else if (list[0] >= 0.8) {
      speedingColor = Colors.lime;
    }
    else if (list[0] >= 0.7) {
      speedingColor = Colors.yellow;
    }
    else if (list[0] >= 0.6) {
      speedingColor = Colors.orange;
    }

    if (list[1] >= 0.9) {
      acceleratingColor = Colors.green;
    }
    else if (list[1] >= 0.8) {
      acceleratingColor = Colors.lime;
    }
    else if (list[1] >= 0.7) {
      acceleratingColor = Colors.yellow;
    }
    else if (list[1] >= 0.6) {
      acceleratingColor = Colors.orange;
    }

    if (list[2] >= 0.9) {
      deceleratingColor = Colors.green;
    }
    else if (list[2] >= 0.8) {
      deceleratingColor = Colors.lime;
    }
    else if (list[2] >= 0.7) {
      deceleratingColor = Colors.yellow;
    }
    else if (list[2] >= 0.6) {
      deceleratingColor = Colors.orange;
    }
  }

  Future polylineSet(List<dynamic> list) async{
    _polylines = {};
    Color polyColor = Color.fromARGB(255, 70, 141, 220);
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
        size: Size(80, 80),
        text: '∧',
        circleColor:Color.fromARGB(255, 248, 213, 148),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor a2 = await MarkerIcon.circleCanvasWithText(
        size: Size(80, 80),
        text: '∧',
        circleColor:Color.fromARGB(255, 239, 190, 102),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor a3 = await MarkerIcon.circleCanvasWithText(
        size: Size(80, 80),
        text: '∧',
        circleColor:Color.fromARGB(255, 220, 176, 61),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor a4 = await MarkerIcon.circleCanvasWithText(
        size: Size(80, 80),
        text: '∧',
        circleColor:Color.fromARGB(255, 220, 148, 61),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor a5 = await MarkerIcon.circleCanvasWithText(
        size: Size(80, 80),
        text: '∧',
        circleColor:Color.fromARGB(255, 208, 108, 37),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor d1 = await MarkerIcon.circleCanvasWithText(
        size: Size(80, 80),
        text: '∨',
        circleColor:Color.fromARGB(255, 243, 157, 157),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor d2 = await MarkerIcon.circleCanvasWithText(
        size: Size(80, 80),
        text: '∨',
        circleColor:Color.fromARGB(255, 246, 123, 123),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor d3 = await MarkerIcon.circleCanvasWithText(
        size: Size(80, 80),
        text: '∨',
        circleColor:Color.fromARGB(255, 239, 103, 103),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor d4 = await MarkerIcon.circleCanvasWithText(
        size: Size(80, 80),
        text: '∨',
        circleColor:Color.fromARGB(255, 239, 73, 73),
        fontColor: Colors.white,fontSize: 35);

    BitmapDescriptor d5 = await MarkerIcon.circleCanvasWithText(
        size: Size(80, 80),
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
        if (list[i][1] - list[i-1][1] >= rule['accelerating'][0]) {
          if (list[i][1] - list[i-1][1] >= rule['accelerating'][4]) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 5"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Sharp Acceleration Level 5',
                snippet: '${list[i][0]}, speed ${list[i-1][1]} -> ${list[i][1]} kph',
              ),
              icon: a5,
            ));
          }
          else if (list[i][1] - list[i-1][1] >=rule['accelerating'][3]) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 4"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Sharp Acceleration Level 4',
                snippet: 'At ${list[i][0]}, speed ${list[i-1][1]} -> ${list[i][1]} kph',
              ),
              icon: a4,
            ));
          }
          else if (list[i][1] - list[i-1][1] >= rule['accelerating'][2]) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 3"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Sharp Acceleration Level 3',
                snippet: '${list[i][0]}, speed ${list[i-1][1]} -> ${list[i][1]} kph',
              ),
              icon: a3,
            ));
          }
          else if (list[i][1] - list[i-1][1] >= rule['accelerating'][1]) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Acceleration Level 2"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Sharp Acceleration Level 2',
                snippet: '${list[i][0]}, ${list[i-1][1]} -> ${list[i][1]} kph',
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
                title: 'Sharp Acceleration Level 1',
                snippet: '${list[i][0]}, ${list[i-1][1]} -> ${list[i][1]} kph',
              ),
              icon: a1,
            ));
          }
        }
        else if (list[i-1][1] - list[i][1] >= rule['braking'][0]) {
          if (list[i-1][1] - list[i][1] >= rule['braking'][4]) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 5"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Sharp Braking Level 5',
                snippet: '${list[i][0]}, ${list[i-1][1]} -> ${list[i][1]} kph',
              ),
              icon: d5,
            ));
          }
          else if (list[i-1][1] - list[i][1] >= rule['braking'][3]) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 4"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Sharp Braking Level 4',
                snippet: '${list[i][0]}, ${list[i-1][1]} -> ${list[i][1]} kph',
              ),
              icon: d4,
            ));
          }
          else if (list[i-1][1] - list[i][1] >= rule['braking'][2]) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 3"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Sharp Braking Level 3',
                snippet: '${list[i][0]}, ${list[i-1][1]} -> ${list[i][1]} kph',
              ),
              icon: d3,
            ));
          }
          else if (list[i-1][1] - list[i][1] >= rule['braking'][1]) {
            _markers.add(Marker(
              markerId: MarkerId("Sharp Braking Level 2"),
              draggable: false,
              position: LatLng(list[i][2].latitude,list[i][2].longitude),
              infoWindow: InfoWindow(
                title: 'Sharp Braking Level 2',
                snippet: '${list[i][0]}, ${list[i-1][1]} -> ${list[i][1]} kph',
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
                title: 'Sharp Braking Level 1',
                snippet: '${list[i][0]}, ${list[i-1][1]} -> ${list[i][1]} kph',
              ),
              icon: d1,
            ));
          }
        }
      });
    }
  }
}
