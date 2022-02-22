import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'drivingScore.dart';
import 'sharpSpeed.dart';
import 'route.dart';
import 'review.dart';
import 'menu.dart';

class Result extends StatefulWidget {
  final List<dynamic> trip;
  final String mode;
  Result(this.mode,this.trip);
  @override
  ResultState createState() => ResultState();
}

class ResultState extends State<Result> {

  final PageController _pageController = PageController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference journeys = FirebaseFirestore.instance.collection('journeys');
  List<dynamic> list = [];
  var drivingScore = 0;
  var tripDistance = "0";
  int maxSpeed = 0;
  int avgSpeed = 0;
  String totalTime ="00:00:00";

  @override
  void initState() {
    super.initState();
    list = widget.trip;
    setState(() {
      drivingScore = getDrivingScore(list);
      totalTime = list.last[0];
    });

    if (widget.mode == "monitor") {
      addRecord(list);
    }

    //tripDistance = getTripDistance(list).toString();
    //maxSpeed = getMaxSpeed(list);
    //avgSpeed = getAvgSpeed(list);




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
                    title: Text('Journey Report'),
                    centerTitle: true,
                    backgroundColor: Colors.black,
                    //leading: Icon(Icons.account_circle_rounded),
                    leading: IconButton(
                      onPressed: () {
                        if (widget.mode == "review") {
                          Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => Review()
                          ));
                        }
                        else if (widget.mode == "monitor") {
                          Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => Menu()
                          ));
                        }

                      },
                      icon: Icon(Icons.home_outlined),
                    ),
                    elevation: 0, //remove shadow effect
                  )
              ),
              body: PageView(
                controller: _pageController,
                children: <Widget>[
                  //page1: Driving Score
                  Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Driving Score",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          Text(
                            drivingScore.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 80),
                          ),
                          Text(
                            "Total Time: $totalTime",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          RaisedButton.icon(
                            icon: Icon(Icons.play_arrow),
                            label: Text('Next'),
                            textColor: Colors.grey,
                            onPressed:() {
                              if (_pageController.hasClients) {
                                _pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              }

                            }
                          ),
                        ]
                    ),
                  ),
                  //Page2: Details
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Sharp Acceleration",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        Text(
                          "",
                          style: TextStyle(color: Colors.black, fontSize: 12),
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
                                icon: Icon(Icons.map),
                                label: Text("Map"),
                                textColor: Colors.grey,
                                onPressed:() {
                                  Navigator.push(
                                      context, MaterialPageRoute(
                                      builder: (context) => RoutePage(widget.mode,list)
                                  ));
                                }
                            ),
                          ],
                        ),
                      ]
                    )
                  ),
                ],
              )
          ),
        ));
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> addRecord(List<dynamic> list) {

    DateTime now = DateTime.now();
    now = now.subtract(Duration(seconds: list.length));
    String timeInFormat = "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}";
    DateTime savedTime = DateTime.parse(timeInFormat);

    String uid = "Anonymous";
    final User? user = _auth.currentUser;
    if (user != null) {
      uid = user.uid;
    }

    List<String> time = [];
    List<int> speed = [];
    List<GeoPoint> geoPoint = [];
    for (var i = 0; i < list.length; i++) {
      time.add(list[i][0]);
      speed.add(list[i][1]);
      geoPoint.add(GeoPoint(list[i][2].latitude,list[i][2].longitude));
    }
    return journeys
        .add(
        {
          'createdAt' : savedTime,
          'userUID': uid,
          'time' : time,
          'speed' : speed,
          'geoPoint' : geoPoint
        }
    )
        .then((value) => print("record saved"))
        .catchError((error) => print(error));
  }
}
