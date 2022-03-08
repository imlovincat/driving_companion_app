import 'package:geolocator/geolocator.dart';
import 'sharpSpeed.dart';

int getDrivingScore(List<dynamic> list) {
  var drivingScore = 100;
  int sharpAccelerated = getSharpAccelerated(list);
  int sharpDecelerated = getSharpDecelerated(list);

  drivingScore = drivingScore - sharpAccelerated - sharpDecelerated;

  //no negative score
  if (drivingScore < 0) {
    drivingScore = 0;
  }

  return drivingScore.toInt();
}

int getSharpAccelerated(List<dynamic> list) {

  var indexOfSharpAccelerated = 1;
  bool wavePeak = false;
  var level1 = 0;
  var level2 = 0;
  var level3 = 0;
  var level4 = 0;
  var level5 = 0;

  for (var i = 0; i < list.length -1; i++) {

    //speed wave peak
    if (wavePeak = false && list[i][1] - list[i+1][1] >=2 ) {
      wavePeak = true;
    }
    else if (wavePeak = true && list[i+1][1] - list[i][1] >= 2 ) {
      indexOfSharpAccelerated++;
      wavePeak = false;
    }

    if (list[i+1][1] - list[i][1]  >= getSharpSpeedValue("a5")) {
      level5++;
    }
    else if (list[i+1][1] - list[i][1]  >= getSharpSpeedValue("a4")) {
      level4++;
    }
    else if (list[i+1][1] - list[i][1]  >= getSharpSpeedValue("a3")) {
      level3++;
    }
    else if (list[i+1][1] - list[i][1]  >= getSharpSpeedValue("a2")) {
      level2++;
    }
    else if (list[i+1][1] - list[i][1]  >= getSharpSpeedValue("a1")) {
      level1++;
    }
  }

  var deduction= (((level1 + (level2 * 2) + (level3 * 3) + (level4 * 4) + (level5 * 5)) / (indexOfSharpAccelerated * 3)) * 100) /2;
  return deduction.toInt();
}

int getSharpDecelerated(List<dynamic> list) {

  var indexOfSharpDecelerated = 1;
  bool wavePeak = false;
  var level1 = 0;
  var level2 = 0;
  var level3 = 0;
  var level4 = 0;
  var level5 = 0;

  for (var i = 0; i < list.length -1; i++) {

    //speed wave peak
    if (wavePeak = false && list[i+1][1] - list[i][1] >=2 ) {
      wavePeak = true;
    }
    else if (wavePeak = true && list[i][1] - list[i+1][1] >= 2 ) {
      indexOfSharpDecelerated++;
      wavePeak = false;
    }

    if (list[i][1] - list[i+1][1] >= getSharpSpeedValue("d5")) {
      level5++;
    }
    else if (list[i][1] - list[i+1][1] >= getSharpSpeedValue("d4")) {
      level4++;
    }
    else if (list[i][1] - list[i+1][1] >= getSharpSpeedValue("a3")) {
      level3++;
    }
    else if (list[i][1] - list[i+1][1]  >= getSharpSpeedValue("a2")) {
      level2++;
    }
    else if (list[i][1] - list[i+1][1]  >= getSharpSpeedValue("a1")) {
      level1++;
    }
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