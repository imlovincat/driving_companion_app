import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
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
  List<dynamic> list = [];

  @override
  void initState() {
    super.initState();
    list = widget.trip;
    if (widget.mode == "monitor") {
      addRecord(list);
    }
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
                    title: Text('Driving Report'),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Driving Score",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          Text(
                            getDrivingScore(list).toString(),
                            style: TextStyle(color: Colors.black, fontSize: 100),
                          ),
                          Text(
                            getEvaluate(getDrivingScore(list)),
                            style: TextStyle(color: Colors.black, fontSize: 30),
                          ),
                          SizedBox(
                            height:30
                          ),
                          Text(
                            "Duration: ${list.last[0]}",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          Text(
                            "Distance: ${getTripDistance(list)} meters",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          SizedBox(
                            width: 10
                          ),
                          Text(
                            "Comment",
                              style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          Text(
                              "talk something ",
                              style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          SizedBox(
                              width: 30
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
                        Container(
                          padding: EdgeInsets.all(10),
                          width: 320,
                          height: 200,
                          color: Color.fromARGB(255, 151, 195, 220),
                          child: LineChart(LineChartData(

                            //minX: 0,
                            //minY: 0,
                            //maxX: x_axis,
                            //maxY: y_axis,

                              borderData: FlBorderData(show: false),

                              titlesData: FlTitlesData(
                                topTitles: SideTitles(
                                  showTitles: false,
                                ),
                                rightTitles: SideTitles(
                                  showTitles: false,
                                ),
                                leftTitles: SideTitles(
                                  showTitles: false,
                                  //interval: 5,
                                ),
                                bottomTitles: SideTitles(
                                  showTitles: false,
                                  //interval: 5,
                                ),

                              ),

                              axisTitleData: FlAxisTitleData(
                                  leftTitle: AxisTitle(
                                      showTitle: true,
                                      titleText: 'Speed (km/h)',
                                      margin: 10
                                  ),
                                  bottomTitle: AxisTitle(
                                    showTitle: true,
                                    margin: 10,
                                    titleText: 'Time (Seconds)',
                                  )
                              ),

                              gridData: FlGridData(
                                show: false,
                              ),

                              lineBarsData: [
                                LineChartBarData(
                                    isCurved: true,
                                    dotData: FlDotData(
                                      show: false,
                                    ),
                                    spots: getLineChartValue(list)
                                )
                              ]
                          ),
                          ),
                        ),
                        Text(
                          "Max Speed: ${getMaxSpeed(list)} kph",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        Text(
                          "Avg Speed: ${getAvgSpeed(list)} kph",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        Text(
                          "Acceleration: ",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        Text(
                          "Braking: ",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        Text(
                          "Over speed: ",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        SizedBox(
                          height:20
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
