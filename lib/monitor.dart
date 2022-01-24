import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'result.dart';

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
  var buttonText = "Start";

  bool pressAttention = false;
  bool startStop = true; //for timer
  Stopwatch watch = Stopwatch();
  String elapsedTime = "00:00:00";
  late Timer timer;
  late StreamSubscription<Position> positionStream;
  List<dynamic> trip = [];

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
  );

  startOrStop() {
    if(startStop) {
      watch.start();
      startStop = false;
      timer = Timer.periodic(Duration(milliseconds: 1000), (Timer t) {
        updateTime(timer);
        getGeoLocation();
        getGeoSpeed();
        trip.add([elapsedTime,speedToInt,position]);

      });
      setState(() async {
        buttonText = "STOP";
        pressAttention = !pressAttention;
      });
    } else {
      startStop = true;
      watch.stop();
      timer.cancel();
      watch.reset();
      Navigator.push(
          context, MaterialPageRoute(
          builder: (context) => Result(trip))
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
    setState(() async {
      speedPos= await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      speedInMps = speedPos.speed * speedFixing;
      speedInKps = speedInMps * 1.60934;
      speedToInt = speedInKps.toInt();
    });
  }

  getGeoLocation() {
    setState(() async {
      positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
              (Position pos) {
            latitudeMessage = pos.latitude;
            longitudeMessage = pos.longitude;
            position = pos;
          });
    });
  }

  /*
  @override
  void initState() {
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    checkGPSPermission();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: null,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Speed: $speedToInt km/h",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              Text(
                  "Latitude: $latitudeMessage",
                  style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              Text(
                "Longitude: $longitudeMessage",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              Text(
                elapsedTime,
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              Container(
                // set width equal to height to make a square
                  width: 150,
                  height: 150,
                  child: RaisedButton(
                    color: pressAttention ? Colors.red : Colors.green,
                    shape: RoundedRectangleBorder(
                      // set the value to a very big number like 100, 1000...
                        borderRadius: BorderRadius.circular(100)),
                    child: Text(
                            buttonText,
                            style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    onPressed: () {
                        startOrStop();
                    },
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}