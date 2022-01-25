import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Result extends StatefulWidget {

  List<dynamic> trip = [];
  Result(this.trip);

  @override
  Report createState() => Report();
}

class Report extends State<Result> {

  List<dynamic> list = [];
  var drivingScore = 0;
  var tripDistance = "0";
  var IndexOfSharpAccelerated = 0;
  var IndexOfSharpDecelerated = 0;

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
    int tripTotalSecond = list.length;
    int sharpAccelerated = getSharpAccelerated(list);
    int sharpDecelerated = getSharpDecelerated(list);
    drivingScore = drivingScore - ((sharpAccelerated + sharpDecelerated) ~/ 2);
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
    var time = 0;
    var result = 0;

    for (var i = 0; i < list.length -2; i++) {
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
    result = level1 + (level2 * 2) + (level3 * 3) + (level4 * 4) + (level5 * 5);
    time = list.length ~/3600 + 1;
    result = result ~/ time;
    return result;
  }

  //level of accelerated
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
    var time = 0;
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
    result = level1 + (level2 * 2) + (level3 * 3) + (level4 * 4) + (level5 * 5);
    time = list.length ~/3600 + 1;
    result = result ~/ time;
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


  @override
  Widget build(BuildContext context) {

    list = widget.trip;

    drivingScore = getDrivingScore(list);
    IndexOfSharpAccelerated = getSharpAccelerated(list);
    IndexOfSharpDecelerated = getSharpDecelerated(list);
    tripDistance = getTripDistance(list).toString();

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
                "Length of List",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              Text(
                "Driving Score: $drivingScore",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              Text(
                "Sharp Acceleration: $IndexOfSharpAccelerated",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              Text(
                "Sharp Deceleration: $IndexOfSharpDecelerated",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              Text(
                "Distance: $tripDistance",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              Container(
                // set width equal to height to make a square
              )
            ],
          ),
        ),
      ),
    );
  }
}