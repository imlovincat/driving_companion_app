import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'menu.dart';
import 'drivingScore.dart';


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
  int _totalTime = 0;
  double _totalDistance = 0;

  _Profile() {
    getData().then((val) => setState(() {
      _score = val;
      _avgScore = getAvgScore(_score);
      _email = userEmail();
      _numberOfDriving = _score.length;
      _totalDistance = (_totalDistance / 1000);
    }));
  }

  @override
  void initState() {
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
                title: Text('Profile'),
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
                      //color: Color.fromARGB(255, 255, 255, 255),
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
                              /*getTitles: (value) {
                                switch (value.toInt()) {
                                  case 0:
                                    return '0';
                                  case 1:
                                    return '20';
                                  case 2:
                                    return '40';
                                  case 3:
                                    return '60';
                                  case 4:
                                    return '80';
                                  case 5:
                                    return '100';
                                  default:
                                    return '';
                                }
                              }*/
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
                              /*bottomTitle: AxisTitle(
                                  showTitle: true,
                                  titleText: 'last 10 driving records',
                                  margin: 0
                              ),*/
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
                    Text(
                      "User : ${_email}",
                      style: TextStyle(color: Colors.black, fontSize: 16),
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
                      "Number of driving : ${_numberOfDriving.toString()}",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    SizedBox(
                        height:10
                    ),
                    Text(
                      "Total Time : ${transformSeconds(_totalTime)}",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    SizedBox(
                        height:10
                    ),
                    Text(
                      "Total distance : ${_totalDistance.toStringAsPrecision(3)} km",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    SizedBox(
                        height:30
                    ),
                    RaisedButton.icon(
                        icon: Icon(Icons.arrow_back_ios),
                        label: Text('Back'),
                        textColor: Colors.grey,
                        onPressed:() {
                          Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => Menu()
                          )
                          );
                        }
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

  int getAvgScore(List<int> drivingScore) {
    var sum = 0;
    for (var i = 0; i < drivingScore.length; i++) {
      sum += drivingScore[i];
    }
    return sum ~/ drivingScore.length;
  }

  Future <List<int>> getData() async{
    List<int> score = [];
    await FirebaseFirestore.instance
        .collection('journeys')
        .where('userUID', isEqualTo: userUID())
        .limit(10)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        List<dynamic> list = [];
        for (var i = 0; i < doc["speed"].length; i++) {
          list.add([doc["time"][i],doc["speed"][i],doc["geoPoint"][i]]);
          _totalTime ++;
        }
        score.add(getDrivingScore(list));
        _totalDistance += getTripDistance(list).toDouble();
      });
    });
    print(score.toString());
    return score;
  }

  transformSeconds(int seconds) {
    //int hundreds = (milliseconds / 10).truncate();
    //int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();
    String hoursStr = (hours % 60).toString();
    String minutesStr = (minutes % 60).toString();
    //String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return "$hoursStr hours $minutesStr minutes";
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
  /*
  Future<void> getData(String documentID) async {
    List<dynamic> time = [];
    List<dynamic> speed = [];
    List<dynamic> location = [];

    var collection = FirebaseFirestore.instance.collection('journeys');
    var document = await collection.doc(documentID).get();

    if (document.exists) {
      Map<String, dynamic>? data = document.data();

      data?["time"].forEach((v) => time.add(v));
      data?["speed"].forEach((v) => speed.add(v));
      data?["geoPoint"].forEach((v) => location.add(v));

      for (var i = 0; i < time.length; i++) {
        trip.add([time[i],speed[i],location[i]]);
      }
    }
  }*/

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
}