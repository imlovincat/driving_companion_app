import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


class Monitor extends StatefulWidget {
  @override
  Journey createState() => Journey();
}

class Journey extends State<Monitor> {
  var latitudeMessage;
  var longitudeMessage;
  var speedInMps;
  var buttonText = "START";
  bool pressAttention = false;

  void getCurrentLocation() async{
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    latitudeMessage = position.latitude;
    longitudeMessage = position.longitude;
    speedInMps = position.speed;
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
              Container(
                // set width equal to height to make a square
                  width: 150,
                  height: 150,
                  child: RaisedButton(
                    color: pressAttention ? Colors.green : Colors.red,
                    shape: RoundedRectangleBorder(
                      // set the value to a very big number like 100, 1000...
                        borderRadius: BorderRadius.circular(100)),
                    child: Text(
                            buttonText,
                            style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    onPressed: () {
                      setState(() {
                        pressAttention = !pressAttention;
                        buttonText = "START";
                        getCurrentLocation();
                      });
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