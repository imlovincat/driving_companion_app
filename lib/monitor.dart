import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'result.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/services.dart';
import 'menu.dart';


class Monitor extends StatefulWidget {
  @override
  Journey createState() => Journey();
}

class Journey extends State<Monitor> {

  var position;
  var latitudeMessage = 0.0;
  var longitudeMessage = 0.0;
  var speedPos;
  var speedInMps = 0.0;
  var speedInKps = 0.0;
  final speedFixing = 2.396714; // 2.2369356 showed 55 -> 60, 2.440293 showed 80 -> 82
  var speedToInt = 0;
  Color speedColor = Color.fromARGB(255, 0, 0, 0);
  //var totalDistance = 0;
  var buttonText = "Start";
  var mapZoom = 15.5; //14.4746
  var mapTilt = 0.0;
  var mapHeading = 0.0;
  var totalDistance = 0;

  Color polyColor = Color.fromARGB(255, 153, 204, 255);
  bool pressAttention = false;
  bool backgroundChange = false;
  bool startStop = true; //for timer
  Stopwatch watch = Stopwatch();
  String elapsedTime = "00:00:00";
  late Timer timer;
  late Timer init;
  late StreamSubscription<Position> positionStream;
  List<dynamic> trip = [];
  List<LatLng> polylineCoordinates = [];

  Completer<GoogleMapController> _controller = Completer();
  Set<Polyline> _polylines = {};
  Set<Marker> markers = new Set();

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
  );

  startOrStop() {
    if(startStop) {
      watch.start();
      startStop = false;

      setState(() async {
        buttonText = "STOP";
        pressAttention = !pressAttention;
        backgroundChange = !backgroundChange;
        timer = Timer.periodic(Duration(milliseconds: 1000), (Timer t) {
          updateTime(timer);
          trip.add([elapsedTime,speedToInt,position]);

          setSpeedMarker();
          //getDistance();

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

      });
    } else {
      startStop = true;
      watch.stop();
      timer.cancel();
      watch.reset();
      Navigator.push(
          context, MaterialPageRoute(
          builder: (context) => Result('monitor',trip))
      );
    }
  }

  updateTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
      });
    }
  }

  /*
  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
    });
  }*/

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

  /*
  getGeoInfo() async {
    setState(() async {
      lastKnownPosition = await Geolocator.getLastKnownPosition();
      lastknownLatiudeMessage = lastKnownPosition.latitude;
      lastknownlongitudeMessage = lastKnownPosition.longitude;
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      latitudeMessage = position.latitude;
      longitudeMessage = position.longitude;
      speedInMps = position.speed * speedFixing;
      speedInKps = speedInMps * 1.60934;
      currentSpeed = speedInKps.toInt();
      distance = Geolocator.distanceBetween(
        lastknownLatiudeMessage,lastknownlongitudeMessage,
        latitudeMessage,longitudeMessage
      );
      distanceInMeters += distance;
    });
  }
   */

  getGeoSpeed() {
    setState(() async{
      speedPos= await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      speedInMps = speedPos.speed * speedFixing;
      speedInKps = speedInMps * 1.60934;
      speedToInt = speedInKps.toInt();
    });
  }

  getGeoLocation() {
    setState(() {
      positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
              (Position pos) {
            latitudeMessage = pos.latitude;
            longitudeMessage = pos.longitude;
            position = pos;
          });
    });
  }

  /*
  getDistance() {
    if (trip.length > 1) {
      var currentlatitude = trip.elementAt(trip.length - 1)[2].latitude;
      var currentlongitude = trip.elementAt(trip.length - 1)[2].longitude;
      var lastlatitude = trip.elementAt(trip.length - 2)[2].latitude;
      var lastlongitude = trip.elementAt(trip.length - 2)[2].longitude;
      var distance = Geolocator.distanceBetween(
          lastlatitude,lastlongitude,
          currentlatitude,currentlongitude
      );

      if (distance >= 1.0) {
        totalDistance += distance.toInt();
      }
    }
  }*/


  Future<void> googleMapUpdated() async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera (CameraUpdate.newCameraPosition(
        CameraPosition(

            target: LatLng(position.latitude, position.longitude),
            //target: LatLng(latitudeMessage, longitudeMessage),
            zoom: mapZoom,
            tilt: mapTilt,
            bearing: position.heading
        )
    ));
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

  @override
  void initState() async{
    super.initState();
    //checkGPSPermission();
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await getGeoLocation();
    init = Timer.periodic(Duration(milliseconds: 1000), (Timer t) {
      getGeoLocation();
      getGeoSpeed();
      //mapZoom = position.zoom;
      //mapTilt = position.tilt;
      //mapHeading = position.heading;
      googleMapUpdated();
    });
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
                child:
                GoogleMap (
                  myLocationEnabled: true,
                  compassEnabled: false,
                  tiltGesturesEnabled: false,
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  polylines: _polylines,
                  markers: markers,

                  initialCameraPosition: CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: mapZoom, //14.4746
                    tilt: mapTilt,
                    bearing: position.heading,
                  ),

                  /*
                    onCameraMove:(CameraPosition cameraPosition){
                    //print(cameraPosition.zoom);
                  },*/

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
                "",
                style: TextStyle(color: Colors.black, fontSize: 24),
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
              Text(
                "",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    ));
  }
  @override
  void dispose() {
    super.dispose();
  }
}