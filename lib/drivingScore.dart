import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'algorithmJson.dart';

Future<int> getDrivingScore(AlgorithmJson json, List<dynamic> list) async{
  Map<String, dynamic> rule = {};
  List<int> speeding = [];
  List<int> braking = [];
  List<int> accelerating = [];
  for (var i = 0; i < json.speeding.length; i++) {
    speeding.add(json.speeding[i].toInt());
  }
  for (var i = 0; i < json.braking.length; i++) {
    braking.add(json.braking[i].toInt());
  }
  for (var i = 0; i < json.accelerating.length; i++) {
    accelerating.add(json.accelerating[i].toInt());
  }
  rule['speeding'] = speeding;
  rule['braking'] = braking;
  rule['accelerating'] = accelerating;
  return drivingScoreAlgorithm(rule,list).toInt();
}

int drivingScoreAlgorithm(Map<String, dynamic> rule,List<dynamic> list) {

  var drivingScore = 100;
  List<int> speeding = rule['speeding'];
  List<int> accelerating = rule['accelerating'];
  List<int> braking = rule['braking'];

  int sharpAccelerated = getSharpAccelerated(accelerating,list);
  int sharpDecelerated = getSharpDecelerated(braking,list);

  drivingScore = drivingScore - sharpAccelerated - sharpDecelerated;

  //no negative score
  if (drivingScore < 0) {
    drivingScore = 0;
  }

  return drivingScore.toInt();
}

int getSharpAccelerated(List<int> accelerating,List<dynamic> list) {

  var indexOfSharpAccelerated = 1;
  bool wavePeak = false;
  var level1 = 0;
  var level2 = 0;
  var level3 = 0;
  var level4 = 0;
  var level5 = 0;

  for (var i = 0; i < list.length -1; i++) {
    //speed wave peak
    if (wavePeak = false && list[i][1] - list[i+1][1] >=2 ) {wavePeak = true;}
    else if (wavePeak = true && list[i+1][1] - list[i][1] >= 2 ) {
      indexOfSharpAccelerated++;
      wavePeak = false;
    }
    if (list[i+1][1] - list[i][1]  >= accelerating[4]) {level5++;}
    else if (list[i+1][1] - list[i][1]  >= accelerating[3]) {level4++;}
    else if (list[i+1][1] - list[i][1]  >= accelerating[2]) {level3++;}
    else if (list[i+1][1] - list[i][1]  >= accelerating[1]) {level2++;}
    else if (list[i+1][1] - list[i][1]  >= accelerating[0]) {level1++;}
  }

  var deduction= (((level1 + (level2 * 2) + (level3 * 3) + (level4 * 4) + (level5 * 5)) / (indexOfSharpAccelerated * 3)) * 100) /2;
  return deduction.toInt();
}

int getSharpDecelerated(List<int> braking,List<dynamic> list) {

  var indexOfSharpDecelerated = 1;
  bool wavePeak = false;
  var level1 = 0;
  var level2 = 0;
  var level3 = 0;
  var level4 = 0;
  var level5 = 0;

  for (var i = 0; i < list.length -1; i++) {
    //speed wave peak
    if (wavePeak = false && list[i+1][1] - list[i][1] >=3 ) {
      wavePeak = true;
    }
    else if (wavePeak = true && list[i][1] - list[i+1][1] >= 3 ) {
      indexOfSharpDecelerated++;
      wavePeak = false;
    }

    if (list[i][1] - list[i+1][1] >= braking[4]) {level5++;}
    else if (list[i][1] - list[i+1][1] >= braking[3]) {level4++;}
    else if (list[i][1] - list[i+1][1] >= braking[2]) {level3++;}
    else if (list[i][1] - list[i+1][1]  >= braking[1]) {level2++;}
    else if (list[i][1] - list[i+1][1]  >= braking[0]) {level1++;}
  }
  var deduction= (((level1 + (level2 * 2) + (level3 * 3) + (level4 * 4) + (level5 * 5)) / (indexOfSharpDecelerated * 3)) * 100) /2;
  return deduction.toInt();
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

  for (var i = 0; i < list.length; i++) {
    if (list[i][1] >= 5) {
      count++;
      sumOfSpeed += list[i][1];
    }
  }
  result = sumOfSpeed ~/ count;
  return result;
}

int getTripDistance(List<dynamic> list) {
  var distance = 0.0;
  var totalDistance = 0.0;
  var currentLatitude = 0.0;
  var currentLongitude = 0.0;
  var lastLatitude = 0.0;
  var lastLongitude = 0.0;
  for (var i = 10; i < list.length -2; i++) {
    lastLatitude = list[i][2].latitude;
    lastLongitude = list[i][2].longitude;
    currentLatitude = list[i+1][2].latitude;
    currentLongitude = list[i+1][2].longitude;
    if (lastLatitude != 0.0 || lastLongitude != 0.0 || currentLatitude != 0.0 || currentLongitude != 0.0) {
      distance = Geolocator.distanceBetween(
          lastLatitude,lastLongitude,
          currentLatitude,currentLongitude
      );
      totalDistance += distance;
    }
  }
  return totalDistance.toInt();
}

String getEvaluate(int drivingScore) {
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

