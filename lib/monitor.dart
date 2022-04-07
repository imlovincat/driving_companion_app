import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:async';
import 'result.dart';
import 'drivingScore.dart';
import 'invalid.dart';

class Monitor extends StatefulWidget {
  @override
  Journey createState() => Journey();
}

class Journey extends State<Monitor> {

  var position;
  late StreamSubscription _positionSubscription;
  var speedToInt = 0;
  Color speedColor = Color.fromARGB(255, 0, 0, 0);
  //var totalDistance = 0;
  var buttonText = "Start";
  var mapZoom = 15.5; //14.4746
  var mapTilt = 0.0;
  var mapHeading = 0.0;
  Color polyColor = Color.fromARGB(255, 153, 204, 255);
  bool pressAttention = false;
  bool backgroundChange = false;
  bool startStop = true; //for timer
  Stopwatch watch = Stopwatch();
  String elapsedTime = "00:00:00";
  late Timer timer;
  List<dynamic> trip = [];
  List<LatLng> polylineCoordinates = [];
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Polyline> _polylines = {};
  final Set<Marker> markers = Set();

  Journey() {
    getCurrentLocation().then((val) => setState(() {
      position = val;
    }));
  }

  Future<Position> getCurrentLocation() async{
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);;
  }

  startOrStop() {
    if(startStop) {
      watch.start();
      Wakelock.enable();
      setState(() {
        startStop = false;
        buttonText = "STOP";
        pressAttention = !pressAttention;
        backgroundChange = !backgroundChange;
      });
      timer = Timer.periodic(Duration(milliseconds: 1000), (Timer t) {
        googleMapUpdated();
        updateTime(timer);
        trip.add([elapsedTime,speedToInt,position]);
        setSpeedMarker();
        polylineCoordinates.add(
            LatLng(position.latitude, position.longitude)
        );
        Polyline polyline = Polyline(
            polylineId: PolylineId('poly'),
            color: polyColor,
            width: 6,
            points: polylineCoordinates
        );
        _polylines.add(polyline);
      });
    } else {
      startStop = true;
      watch.stop();
      timer.cancel();
      watch.reset();
      Wakelock.disable();
      if (trip.length > 180 && getTripDistance(trip) > 500 ) {
        Navigator.push(
            context, MaterialPageRoute(
            builder: (context) => Result('monitor',trip))
        );
      }
      else {
        Navigator.push(
            context, MaterialPageRoute(
            builder: (context) => Invalid())
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkGPSPermission();
    getGeoLocation();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope (
        onWillPop: () async {
          return Future.value(false);
        },

        child:MaterialApp(
          home: Scaffold(
            backgroundColor: backgroundChange ? Color.fromARGB(255, 255, 180, 180) : Color.fromARGB(
                255, 180, 255, 180),
            appBar: PreferredSize(
                preferredSize: Size(double.infinity, 60),
                child: AppBar(
                  title: Text('Driving Monitor'),
                  centerTitle: true,
                  backgroundColor: Colors.black,
                  //leading: Icon(Icons.account_circle_rounded),
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                children: [
                  Container(
                    color: Colors.black,
                    //width: 300,
                    height: 400,
                    padding: EdgeInsets.only(
                      //top:18,
                      bottom:5,
                    ),
                    margin: EdgeInsets.only(
                      //top:18,
                      bottom:1,
                    ),
                    child:
                    GoogleMap (
                      myLocationEnabled: true,
                      compassEnabled: true,
                      tiltGesturesEnabled: false,
                      mapType: MapType.normal,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      polylines: _polylines,
                      markers: markers,

                      initialCameraPosition: CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: mapZoom,
                        tilt: mapTilt,
                        bearing: position.heading
                      ),

                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        speedToInt.toString(),
                        style: TextStyle(color: speedColor, fontSize: 100),
                      ),
                      Text(
                        " km/h",
                        style: TextStyle(color: speedColor, fontSize: 24),
                      ),
                    ],
                  ),
                  Text(
                    elapsedTime,
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                  Text(
                    "${position.latitude.toString()},${position.longitude.toString()}",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  SizedBox(
                      height:20
                  ),
                  Container(
                    // set width equal to height to make a square
                      width: 100,
                      height: 100,
                      child: RaisedButton(
                        color: pressAttention ? Colors.red : Colors.green,
                        shape: RoundedRectangleBorder(
                          // set the value to a very big number like 100, 1000...
                            borderRadius: BorderRadius.circular(100)),
                        child: Text(
                          buttonText,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          startOrStop();
                        },
                      )
                  ),
                  SizedBox(
                      height:20
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    timer.cancel();
    watch.reset();
    super.dispose();
  }
  checkGPSPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
  }

  Future<void> googleMapUpdated() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera (CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: mapZoom,
            tilt: mapTilt,
            bearing: position.heading
        )
    ));
  }

  getGeoLocation() async{
    _positionSubscription = await Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((pos) {
      setState(() {
        position = pos;
        speedToInt = (position.speed * 3.85).toInt();
      });
    });
  }

  final LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 1,
    forceLocationManager: true,
    intervalDuration: Duration(milliseconds: 200),
  );

  updateTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
      });
    }
  }

  transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();
    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return "$hoursStr:$minutesStr:$secondsStr";
  }

  setSpeedMarker() async {

    speedColor = Color.fromARGB(255, 0, 0, 0);

    BitmapDescriptor sharpAccelerationLevel1_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpAcceleration1.png",
    );

    BitmapDescriptor sharpAccelerationLevel2_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpAcceleration2.png",
    );

    BitmapDescriptor sharpAccelerationLevel3_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpAcceleration3.png",
    );

    BitmapDescriptor sharpAccelerationLevel4_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpAcceleration4.png",
    );

    BitmapDescriptor sharpAccelerationLevel5_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpAcceleration5.png",
    );

    BitmapDescriptor sharpDecelerationLevel1_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpDeceleration1.png",
    );

    BitmapDescriptor sharpDecelerationLevel2_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpDeceleration2.png",
    );

    BitmapDescriptor sharpDecelerationLevel3_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpDeceleration3.png",
    );

    BitmapDescriptor sharpDecelerationLevel4_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpDeceleration4.png",
    );

    BitmapDescriptor sharpDecelerationLevel5_Icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/sharpDeceleration5.png",
    );

    if (trip.length > 1) {
      var currentSpeed = trip.elementAt(trip.length - 1)[1];
      var lastSpeed = trip.elementAt(trip.length - 2)[1];

      //Sharp Accelerate detection
      if (currentSpeed - lastSpeed >= 7) {
        if (currentSpeed - lastSpeed >= 13) {
          markers.add(Marker( //add first marker
            markerId: MarkerId(position.toString()),
            draggable: false,
            position: LatLng(position.latitude,position.longitude), //position of marker
            infoWindow: InfoWindow( //popup info
              title: 'Accelerate L5 ',
              snippet: 'over >= 13',
            ),
            icon: sharpAccelerationLevel5_Icon, //Icon for Marker
          ));

          speedColor = Color.fromARGB(255, 255, 153, 0);
        }
        else if (currentSpeed - lastSpeed >= 12) {

          markers.add(Marker( //add first marker
            markerId: MarkerId(position.toString()),
            draggable: false,
            position: LatLng(position.latitude,position.longitude), //position of marker
            infoWindow: InfoWindow( //popup info
              title: 'Accelerate L4 ',
              snippet: 'over >= 12',
            ),
            icon: sharpAccelerationLevel4_Icon, //Icon for Marker
          ));

          speedColor = Color.fromARGB(255, 139, 101, 6);
        }
        else if (currentSpeed - lastSpeed >= 10) {

          markers.add(Marker( //add first marker
            markerId: MarkerId(position.toString()),
            draggable: false,
            position: LatLng(position.latitude,position.longitude), //position of marker
            infoWindow: InfoWindow( //popup info
              title: 'Accelerate L3 ',
              snippet: 'over >= 10',
            ),
            icon: sharpAccelerationLevel3_Icon, //Icon for Marker
          ));

          speedColor = Color.fromARGB(255, 113, 63, 0);
        }
        else if (currentSpeed - lastSpeed >= 8) {

          markers.add(Marker( //add first marker
            markerId: MarkerId(position.toString()),
            draggable: false,
            position: LatLng(position.latitude,position.longitude), //position of marker
            infoWindow: InfoWindow( //popup info
              title: 'Accelerate L2 ',
              snippet: 'over >= 8',
            ),
            icon: sharpAccelerationLevel2_Icon,
            //icon: BitmapDescriptor.defaultMarker, //Icon for Marker
          ));

          speedColor = Color.fromARGB(255, 83, 47, 0);
        }
        else {

          markers.add(Marker( //add first marker
            markerId: MarkerId(position.toString()),
            draggable: false,
            position: LatLng(position.latitude,position.longitude), //position of marker
            infoWindow: InfoWindow( //popup info
              title: 'Accelerate L1 ',
              snippet: 'over >= 7',
            ),
            icon: sharpAccelerationLevel1_Icon, //Icon for Marker
          ));

          speedColor = Color.fromARGB(255, 56, 34, 0);
        }
      }
      //Sharp Decelerate detection
      else if (lastSpeed - currentSpeed >= 7) {
        if (lastSpeed - currentSpeed >= 21) {

          markers.add(Marker( //add first marker
            markerId: MarkerId(position.toString()),
            draggable: false,
            position: LatLng(position.latitude,position.longitude), //position of marker
            infoWindow: InfoWindow( //popup info
              title: 'Decelerate L5 ',
              snippet: 'over >= 21',
            ),
            icon: sharpDecelerationLevel5_Icon, //Icon for Marker
          ));

          speedColor = Color.fromARGB(255, 204, 0, 0);
        }
        else if (lastSpeed - currentSpeed >= 18) {

          markers.add(Marker( //add first marker
            markerId: MarkerId(position.toString()),
            draggable: false,
            position: LatLng(position.latitude,position.longitude), //position of marker
            infoWindow: InfoWindow( //popup info
              title: 'Decelerate L4 ',
              snippet: 'over >= 18',
            ),
            icon: sharpDecelerationLevel4_Icon, //Icon for Marker
          ));

          speedColor = Color.fromARGB(255, 200, 0, 0);
        }
        else if (lastSpeed - currentSpeed >= 14) {

          markers.add(Marker( //add first marker
            markerId: MarkerId(position.toString()),
            draggable: false,
            position: LatLng(position.latitude,position.longitude), //position of marker
            infoWindow: InfoWindow( //popup info
              title: 'Decelerate L3 ',
              snippet: 'over >= 14',
            ),
            icon: sharpDecelerationLevel3_Icon, //Icon for Marker
          ));

          speedColor = Color.fromARGB(255, 150, 0, 0);
        }
        else if (lastSpeed - currentSpeed >= 9) {

          markers.add(Marker( //add first marker
            markerId: MarkerId(position.toString()),
            draggable: false,
            position: LatLng(position.latitude,position.longitude), //position of marker
            infoWindow: InfoWindow( //popup info
              title: 'Decelerate L2 ',
              snippet: 'over >= 9',
            ),
            icon: sharpDecelerationLevel2_Icon, //Icon for Marker
          ));

          speedColor = Color.fromARGB(255, 100, 0, 0);
        }
        else {

          markers.add(Marker( //add first marker
            markerId: MarkerId(position.toString()),
            draggable: false,
            position: LatLng(position.latitude,position.longitude), //position of marker
            infoWindow: InfoWindow( //popup info
              title: 'Decelerate L1 ',
              snippet: 'over >= 7',
            ),
            icon: sharpDecelerationLevel1_Icon, //Icon for Marker
          ));

          speedColor = Color.fromARGB(255, 50, 0, 0);
        }
      }
    }
  }
}