import 'package:flutter/material.dart';

class Result extends StatefulWidget {

  List<dynamic> trip = [];
  Result(this.trip);

  @override
  Report createState() => Report();
}

class Report extends State<Result> {
  var message1 = "";
  var message2 = "Test";
  var message3 = "Test";

  List<dynamic> list = [];
  var timeOfSharpAccelerated = 0;
  var timeOfSharpDecelerated = 0;

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
    double deduction =  (sharpAccelerated + sharpDecelerated) / tripTotalSecond;
    int deductionToInt = deduction.toInt();
    drivingScore = drivingScore - deductionToInt;
    return drivingScore;
  }

  //level of accelerated
  //level1: + 4 mph per second (7 kph)
  //level2: + 5 mph per second (8 kph)
  //level3: + 6 mph per second (10 kph)
  //level5: + 7 mph per second (12 kph)
  //level6: + 8 mph per second (13 kph)
  int getSharpAccelerated(List<dynamic> list) {

    var level1 = 0;
    var level2 = 0;
    var level3 = 0;
    var level4 = 0;
    var level5 = 0;
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
    return result;
  }

  //level of accelerated
  //level1: - 5 mph per second (7 kph)
  //level2: - 7  mph per second (9 kph)
  //level3: - 9 mph per second (14 kph)
  //level5: - 11 mph per second (18 kph)
  //level6: - 13 mph per second (21 kph)
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
    result = level1 + (level2 * 2) + (level3 * 3) + (level4 * 4) + (level5 * 5);
    return result;
  }



  @override
  Widget build(BuildContext context) {

    list = widget.trip;

    message1 = list.length.toString();

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
                message1,
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              Text(
                message2,
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              Text(
                message3,
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