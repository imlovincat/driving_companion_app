import 'package:flutter/material.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'menu.dart';

class Result extends StatefulWidget {

  List<dynamic> trip = [];
  Result(this.trip);
  @override
  Report createState() => Report();
}

class Report extends State<Result> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference journeys = FirebaseFirestore.instance.collection('journeys');
  //DatabaseReference fireBaseDB = FirebaseDatabase.instance.reference();
  List<dynamic> list = [];
  var drivingScore = 0;
  var tripDistance = "0";
  var IndexOfSharpAccelerated = 0;
  var IndexOfSharpDecelerated = 0;
  double x_axis = 0.0;
  double y_axis = 0.0;
  int maxSpeed = 0;
  int avgSpeed = 0;
  String totalTime ="00:00:00";
  bool savedSuccess = true;

  //https://www.quartix.com/en-ie/blog/driver-score-calculations/
  //Calculating the driver score
  //To get the driving style score, the Quartix system:
  // * Adds up all the weighted acceleration and braking events;
  // * Factors in vehicle speed;
  // * Calculates the total driving time;
  // * Works out the acceleration and braking indexes;
  //Averages these and subtracts from 100.
  //For example, if you have a driver with an acceleration index of 10 and a braking index of 6,
  //the average for this driver would be 8. This drivers’ driving score would be 100 minus 8,
  //equalling a score of 92.
  int getDrivingScore(List<dynamic> list) {
    var drivingScore = 100;

    int count = 0;

    //Driving at a speed of at least 5 km/h or more is considered valid driving
    for (var i = 0; i < list.length; i++) {
      if (list[i][1] > 5) count++;
    }

    //if total time less then 1 minutes or idle time takes up half of driving time
    if (list.length < 60 || count < list.length ~/ 2) {
      drivingScore = 0;
    }

    //reduction discount for long-distance driving
    int tripTotalSecond = count;
    double reductionDiscount = 1;
    if (tripTotalSecond ~/ 3600 > 1) {
      reductionDiscount = 0.9;
    }
    else if (tripTotalSecond ~/ 3600 > 2) {
      reductionDiscount = 0.8;
    }
    else if (tripTotalSecond ~/ 3600 > 2) {
      reductionDiscount = 0.7;
    }

    //Deduction for mistakes
    int sharpAccelerated = getSharpAccelerated(list);
    int sharpDecelerated = getSharpDecelerated(list);
    double reduction = ((sharpAccelerated + sharpDecelerated) / 2) * reductionDiscount;

    drivingScore = drivingScore - reduction.toInt();

    //no negative score
    if (drivingScore < 0) {
      drivingScore = 0;
    }

    return drivingScore;
  }

  //level of accelerated
  //level1: + 4 mph per second (7 kph)
  //level2: + 5 mph per second (8 kph)
  //level3: + 6 mph per second (10 kph)
  //level5: + 7 mph per second (12 kph)
  //level6: + 8 mph per second (13 kph)
  //the sum of all the acceleration incidents,
  //each multiplied by their severity and finally divided by the driving time in hours.
  // Calculating it in this way means that no drivers are penalised for driving more or less than any other driver.
  int getSharpAccelerated(List<dynamic> list) {

    var level1 = 0;
    var level2 = 0;
    var level3 = 0;
    var level4 = 0;
    var level5 = 0;
    var result = 0;

    for (var i = 0; i < list.length -1; i++) {
      if (list[i+1][1] - list[i][1]  >= 13) {
        level5++;
      }
      else if (list[i+1][1] - list[i][1]  >= 12) {
        level4++;
      }
      else if (list[i+1][1] - list[i][1]  >= 10) {
        level3++;
      }
      else if (list[i+1][1] - list[i][1]  >= 8) {
        level2++;
      }
      else if (list[i+1][1] - list[i][1]  >= 7) {
        level1++;
      }
    }
    IndexOfSharpAccelerated = level1 + level2 + level3 + level4 + level5;
    result = level1 + (level2 * 2) + (level3 * 3) + (level4 * 4) + (level5 * 5);
    return result;
  }

  //level of decelerated
  //level1: - 5 mph per second (7 kph)
  //level2: - 7  mph per second (9 kph)
  //level3: - 9 mph per second (14 kph)
  //level5: - 11 mph per second (18 kph)
  //level6: - 13 mph per second (21 kph)
  //the sum of all braking incidents, worked out in a similar way,
  // except that the levels of speed change are slightly different,
  // as are the severity weightings, as excessive braking is considered to be more of a risk factor.
  int getSharpDecelerated(List<dynamic> list) {
    var level1 = 0;
    var level2 = 0;
    var level3 = 0;
    var level4 = 0;
    var level5 = 0;
    var result = 0;

    for (var i = 0; i < list.length -2; i++) {
      if (list[i][1] - list[i+1][1] >= 21) {
        level5++;
      }
      else if (list[i][1] - list[i+1][1] >= 18) {
        level4++;
      }
      else if (list[i][1] - list[i+1][1] >= 14) {
        level3++;
      }
      else if (list[i][1] - list[i+1][1]  >= 9) {
        level2++;
      }
      else if (list[i][1] - list[i+1][1]  >= 7) {
        level1++;
      }
    }
    IndexOfSharpDecelerated = level1 + level2 + level3 + level4 + level5;
    result = level1 + (level2 * 2) + (level3 * 3) + (level4 * 4) + (level5 * 5);
    return result;
  }

  int getTripDistance(List<dynamic> list) {
    var distance = 0.0;
    var totalDistance = 0.0;
    var currentlatitude = 0.0;
    var currentlongitude = 0.0;
    var lastlatitude = 0.0;
    var lastlongitude = 0.0;
    for (var i = 10; i < list.length -2; i++) {
      lastlatitude = list[i][2].latitude;
      lastlongitude = list[i][2].longitude;
      currentlatitude = list[i+1][2].latitude;
      currentlongitude = list[i+1][2].longitude;
      if (lastlatitude != 0.0 || lastlongitude != 0.0 || currentlatitude != 0.0 || currentlongitude != 0.0) {
        distance = Geolocator.distanceBetween(
            lastlatitude,lastlongitude,
            currentlatitude,currentlongitude
        );
        totalDistance += distance;
      }
    }
    return totalDistance.toInt();
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

  int getMaxSpeed(List<dynamic> list) {
    var maxSpeed = 0;
    for (var i = 0; i < list.length; i++) {
      if (list[i][1] > maxSpeed) {
        maxSpeed = list[i][1];
      }
    }
    return maxSpeed;
  }

  int getAvgSpeed(List<dynamic> list) {
    double sumOfSpeed = 0;
    int count = 0;
    int result = 0;
    /*
    for (var i = 0; i < list.length; i++) {
      if (list[i][1] > 5) {
        count++;
      }
      sumOfSpeed += list[i][1];
    }

    result = sumOfSpeed ~/ count;
    */
    return result;
  }

  String getComment(int drivingScore) {
    if (drivingScore >= 90) {
      return "Excellent";
    }
    else if (drivingScore >= 80) {
      return "Very Good";
    }
    else if (drivingScore >= 70) {
      return "Good";
    }
    else if (drivingScore >= 60) {
      return "Average";
    }
    else if (drivingScore >= 50) {
      return "Fair";
    }
    else if (drivingScore >= 40) {
      return "Poor";
    }
    else {
      return "Very Poor";
    }

  }

  Future<void> addRecord(List<dynamic> list) {

    DateTime now = DateTime.now();
    String savedTime = "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}";

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
      geoPoint.add(GeoPoint(list[1][2].latitude,list[1][2].longitude));
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
        .then((value) {
          setState(() {
            savedSuccess = true;
          });
        })
        .catchError((error) {
          setState(() {
            savedSuccess = false;
          });
        });



  }

  @override
  void initState() {
    super.initState();
    list = widget.trip;
    drivingScore = getDrivingScore(list);
    IndexOfSharpAccelerated = getSharpAccelerated(list);
    IndexOfSharpDecelerated = getSharpDecelerated(list);
    tripDistance = getTripDistance(list).toString();
    maxSpeed = getMaxSpeed(list);
    avgSpeed = getAvgSpeed(list);
    totalTime = list.last[0];
    //x_axis = list.length -1.toDouble();
    //y_axis = 20.toDouble();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          // hold space for mobile phone original topbar and ignore AppBar as its size is 0
            preferredSize: Size(double.infinity, 0),
            child: AppBar(
              backgroundColor: Colors.black,
              elevation: 0, //remove shadow effect
            )
        ),
        body: Center(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Your Journey Report",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),


              Container(
                padding: EdgeInsets.all(10),
                width: 300,
                height: 200,
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

                          titleText: 'Time',
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
                "Driving Score",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              Text(
                drivingScore.toString(),
                style: TextStyle(color: Colors.black, fontSize: 80),
              ),
              Text(
                getComment(drivingScore),
                style: TextStyle(color: Colors.black, fontSize: 30),
              ),
              Text(
                "Total Time: $totalTime",
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              Text(
                "Total Distance: $tripDistance meters",
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),

              Text(
                "Max Speed: $maxSpeed",
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              Text(
                "Avg Speed: $avgSpeed",
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              Text(
                "Sharp Acceleration: $IndexOfSharpAccelerated",
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              Text(
                "Sharp Deceleration: $IndexOfSharpDecelerated",
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              TextButton(
                child: Text(
                    'Save',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 24
                    )
                ),
                onPressed: () {
                  addRecord(list);
                  if (savedSuccess) {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => Menu()
                    ));
                  }
                  final snackBar = SnackBar(content: Text('Failed, Please try again'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              )

            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}
