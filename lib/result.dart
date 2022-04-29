/**
 * Institue of Technology Carlow
 * Software Development Final Year Project
 * Student Chi Ieong Ng C00223421
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'algorithmJson.dart';
import 'drivingScore.dart';
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
  late List<dynamic> list = [];
  String groupName = 'default';
  int drivingScore = 0;
  Color ring = Colors.black;

  getJson() async{
    AlgorithmJson json = AlgorithmJson.fromJson(await SessionManager().get('scoring'));
    return json;
  }

  @override
  void initState() {
    super.initState();
    list = widget.trip;
    if (widget.mode == "monitor") {
      addRecord(list);
    }
    getJson().then((json) => setState(() {
      getDrivingScore(json,list).then((val) => setState(() {
        drivingScore = val;
        if (drivingScore >= 90) {
          ring = Colors.blueAccent;
        }
        else if (drivingScore >= 80) {
          ring = Colors.green;
        }
        else if (drivingScore >= 70) {
          ring = Colors.lightGreen;
        }
        else if (drivingScore >= 60) {
          ring = Colors.yellow;
        }
        else if (drivingScore >= 50) {
          ring = Colors.orange;
        }
        else {
          ring = Colors.red;
        }


      }));
    }));
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
                    title: Text('Driving Score'),
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
              body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox (
                        height: 30,
                      ),
                      CircularPercentIndicator(
                        radius: 140.0,
                        lineWidth: 13.0,
                        animation: true,
                        //percent: 0.7,
                        percent: drivingScore / 100,
                        center: Text(
                          drivingScore.toString(),
                          style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 120.0),
                        ),
                        /*footer: Text(
                              "Sales this week",
                              style:
                              TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                            ),*/
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: ring,
                      ),
                      SizedBox(
                          height:30
                      ),
                      Text(
                        getEvaluate(drivingScore),
                        style: TextStyle(color: Colors.black, fontSize: 50),
                      ),
                      SizedBox(
                          height:30
                      ),
                      Text(
                        "Duration: ${list.last[0]}\n\nDistance: ${getTripDistance(list)} meters",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      SizedBox(
                          height: 60
                      ),
                      SizedBox(
                        width: 160,
                        height: 50,
                        child: RaisedButton.icon(
                            icon: Icon(Icons.map),
                            color: Colors.green,
                            label: Text(
                              'Details',
                              style: TextStyle(color: Colors.black, fontSize: 22),
                            ),
                            //textColor: Colors.grey,
                            onPressed:() {
                              Navigator.push(
                                  context, MaterialPageRoute(
                                  builder: (context) => RoutePage(widget.mode,list)
                              ));
                            }
                        ),
                      ),
                      SizedBox(
                          height: 60
                      ),
                    ]
                ),
              ),
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

  List<FlSpot> getLineChartValue(List<dynamic> list) {
    List<FlSpot> spot = [];
    double index;
    double value;
    for (var i = 0; i < list.length; i++) {
      index = i.toDouble();
      value = list[i][1].toDouble();
      spot.add(FlSpot(index,value));
    }
    return spot;
  }
}
