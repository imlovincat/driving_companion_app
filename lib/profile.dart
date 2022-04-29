/**
 * Institue of Technology Carlow
 * Software Development Final Year Project
 * Student Chi Ieong Ng C00223421
 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'menu.dart';
import 'drivingScore.dart';
import 'setting.dart';
import 'algorithmJson.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;

class Profile extends StatefulWidget {
  @override
  _Profile createState() => _Profile();

}

class _Profile extends State<Profile> {

  List<int> _score = [];
  int _avgScore = 0;
  var _email ="";
  int _numberOfDriving = 0;
  late int _totalTime = 0;
  double _totalDistance = 0;
  String groupName = '';
  String nickname = "Anonymous";

  _Profile() {
    getData().then((val) => setState(() {
      _score = val;
      _avgScore = getAvgScore(_score);
      _email = userEmail();
      _numberOfDriving = _score.length;
      _totalDistance = (_totalDistance / 1000);
    }));
    getNickName(userUID()).then((val) => setState(() {
      nickname = val;
    }));
  }

  @override
  void initState() {
    /*getAlgorithm().then((val) => setState(() {
      groupName = val;
    }));*/
    super.initState();
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
                title: Text("${nickname}'s Profile"),
                centerTitle: true,
                backgroundColor: Colors.black,
                leading: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => Menu()
                    ));
                  },
                  icon: Icon(Icons.home_outlined),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Setting',
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(
                          builder: (context) => Setting()
                      ));
                    },
                  ),
                  ],
                elevation: 0, //remove shadow effect
              )
          ),
        body: Center(
          child: Container(
          alignment:Alignment.center,
              padding: EdgeInsets.only(
                  left: 10,
                  top:10,
                  right: 10,
                  bottom: 10
              ),
              child: Column (
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Last 10 driving records",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: 380,
                      height: 200,
                      child: LineChart(LineChartData(
                        minX: 0,
                        minY: 0,
                        maxX: 10,
                        maxY: 100,
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: SideTitles(
                              showTitles: false,
                            ),
                            rightTitles: SideTitles(
                              showTitles: false,
                            ),
                            leftTitles: SideTitles(
                              showTitles: true,
                              getTextStyles: (context, value) => const TextStyle(fontSize: 12),
                              interval: 20,
                            ),
                            bottomTitles: SideTitles(
                              showTitles: true,
                              getTextStyles: (context, value) => const TextStyle(fontSize: 12),
                                getTitles: (value) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return '1';
                                    case 1:
                                      return '2';
                                    case 2:
                                      return '3';
                                    case 3:
                                      return '4';
                                    case 4:
                                      return '5';
                                    case 5:
                                      return '6';
                                    case 6:
                                      return '7';
                                    case 7:
                                      return '8';
                                    case 8:
                                      return '9';
                                    case 9:
                                      return '10';
                                    default:
                                      return '';
                                  }
                                }
                              //interval: 1,
                            ),
                          ),

                          axisTitleData: FlAxisTitleData(
                              leftTitle: AxisTitle(
                                  showTitle: true,
                                  titleText: 'Driving Score',
                                  margin: 0
                              ),
                          ),

                          gridData: FlGridData(
                            show: true,
                          ),

                          lineBarsData: [
                            LineChartBarData(
                                isCurved: false,
                                dotData: FlDotData(
                                  show: true,
                                ),
                                spots: getLineChartValue(_score)
                            )
                          ]
                      ),
                      ),
                    ),
                    SizedBox(
                        height:20
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "avg ",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "Score",
                          style: TextStyle(fontSize: 40),
                        ),
                      ],
                    ),
                    Text(
                      "${_avgScore.toString()}",
                      style: TextStyle(color: Colors.black, fontSize: 100),
                    ),
                    SizedBox(
                        height:20
                    ),
                    Text(
                      "Total driving : ${_numberOfDriving.toString()} times\n\nTotal Time : ${transformSeconds(_totalTime)}\n\nTotal distance : ${_totalDistance.toStringAsPrecision(3)} km",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),


                    SizedBox(
                        height:30
                    ),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: RaisedButton.icon(
                          icon: Icon(Icons.home),
                          color: Colors.green,
                          label: Text(
                            'Home',
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),
                          //textColor: Colors.grey,
                          onPressed:() {
                            Navigator.push(
                                context, MaterialPageRoute(
                                builder: (context) => Menu()
                            )
                            );
                          }
                      ),
                    ),
                    SizedBox(
                        height:20
                    ),
                  ]
              )
          )
    )
      )
    )
    );
  }

  Future<String> getAlgorithm() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('algorithm').toString();
  }

  int getAvgScore(List<int> drivingScore) {
    var sum = 0;
    for (var i = 0; i < drivingScore.length; i++) {
      sum += drivingScore[i];
    }
    return sum ~/ drivingScore.length;
  }

  Future<List<int>> getData() async{
    late List<int> score = [];
    AlgorithmJson json = AlgorithmJson.fromJson(await SessionManager().get('scoring'));
    await FirebaseFirestore.instance
        .collection('journeys')
        .limit(10)
        .where('userUID', isEqualTo: userUID())
        .orderBy('createdAt', descending: false)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        List<dynamic> list = [];
        for (var i = 0; i < doc["speed"].length; i++) {
          list.add([doc["time"][i],doc["speed"][i],doc["geoPoint"][i]]);
          _totalTime ++;
        }
        await getDrivingScore(json,list).then((drivingScore) {
          setState(() {
            score.add(drivingScore);
            _totalDistance += getTripDistance(list).toDouble();
          });
        } );
      });
    });
    return Future.delayed(Duration(seconds: 1), () =>score);
  }

  transformSeconds(int seconds) {
    //int hundreds = (milliseconds / 10).truncate();
    //int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();
    String hoursStr = (hours % 60).toString();
    String minutesStr = (minutes % 60).toString();
    //String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return "$hoursStr hrs $minutesStr mins";
  }

  List<FlSpot> getLineChartValue(List<int> list) {
    List<FlSpot> spot = [];
    double index;
    double value;
    for (var i = 0; i < list.length; i++) {
      index = i.toDouble();
      value = list[i].toDouble();
      spot.add(FlSpot(index,value));
    }
    return spot;
  }

  String userUID() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return user.uid.toString();
    }
    return "";
  }

  String userEmail() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return user.email.toString();
    }
    return "";
  }

  Future <String> getNickName(String userUID) async {

    String nickname = "Anonymous";

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userUID)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            nickname = documentSnapshot['nickname'];
          }
    });

    return nickname;
  }

}