import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';


class Monitor extends StatefulWidget {
  @override
  Journey createState() => Journey();
}

class Journey extends State<Monitor> {

  var position;
  var distance;
  var latitudeMessage = 0.0;
  var longitudeMessage = 0.0;
  var lastKnownPosition;
  var lastknownLatiudeMessage;
  var lastknownlongitudeMessage;
  var speedInMps = 0.0;
  var distanceInMeters = 0.0;

  var buttonText = "START";

  bool pressAttention = false;
  bool startStop = true; //for timer
  Stopwatch watch = Stopwatch();
  String elapsedTime = '00:00:00';
  late Timer timer;

  startOrStop() {
    if(startStop) {
      startStop = false;
      distanceInMeters = 0.0;
      setState(() async {
        buttonText = "STOP";
        pressAttention = !pressAttention;
        watch.start();
        timer = Timer.periodic(Duration(milliseconds: 100), updateTime);
        distanceInMeters += distance;
      });
    } else {
      startStop = true;
      setState(() {
        buttonText = "START";
        pressAttention = !pressAttention;
        watch.stop();
        setTime();
      });
    }
  }

  updateTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        print("startstop Inside=$startStop");
        elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
      });
    }
  }

  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
    });
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

  getGeoInfo() async {
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

    setState(() async {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      lastKnownPosition = await Geolocator.getLastKnownPosition();
      latitudeMessage = position.latitude;
      longitudeMessage = position.longitude;
      lastknownLatiudeMessage = lastKnownPosition.latitude;
      lastknownlongitudeMessage = lastKnownPosition.longitude;
      speedInMps = position.speed;
      distance = Geolocator.distanceBetween(
        lastknownLatiudeMessage,lastknownlongitudeMessage,
        latitudeMessage,longitudeMessage
      );
    });
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => getGeoInfo());
  }

  @override
  Widget build(BuildContext context) {
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
                "Speed: $speedInMps",
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
                "Distance: $distanceInMeters",
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