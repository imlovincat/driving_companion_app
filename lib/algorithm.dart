import 'package:geolocator/geolocator.dart';
import 'sharpSpeed.dart';

int algorithm_Default(List<dynamic> list) {

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
    if (wavePeak = false && list[i][1] - list[i+1][1] >=2 ) {wavePeak = true;}
    else if (wavePeak = true && list[i+1][1] - list[i][1] >= 2 ) {
      indexOfSharpAccelerated++;
      wavePeak = false;
    }
    if (list[i+1][1] - list[i][1]  >= 14) {level5++;}
    else if (list[i+1][1] - list[i][1]  >= 12) {level4++;}
    else if (list[i+1][1] - list[i][1]  >= 10) {level3++;}
    else if (list[i+1][1] - list[i][1]  >= 8) {level2++;}
    else if (list[i+1][1] - list[i][1]  >= 6) {level1++;}
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
    if (wavePeak = false && list[i+1][1] - list[i][1] >=3 ) {
      wavePeak = true;
    }
    else if (wavePeak = true && list[i][1] - list[i+1][1] >= 3 ) {
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