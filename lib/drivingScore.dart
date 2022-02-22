int getDrivingScore(List<dynamic> list) {
  var drivingScore = 100;

  int count = 0;

  //Driving at a speed of at least 5 km/h or more is considered valid driving
  for (var i = 0; i < list.length; i++) {
    if (list[i][1] > 5) count++;
  }

  //if total time less then 1 minutes or idle time takes up half of driving time
  //if (list.length < 60 || count < list.length ~/ 2) {
  //  drivingScore = 0;
  //}

  //reduction discount for long-distance driving
  int tripTotalSecond = count;
  double reductionDiscount = 1;
  if (tripTotalSecond ~/ 3600 > 1) {
    reductionDiscount = 0.9;
  }
  else if (tripTotalSecond ~/ 3600 > 2) {
    reductionDiscount = 0.8;
  }
  else if (tripTotalSecond ~/ 3600 > 3) {
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

int getSharpAccelerated(List<dynamic> list) {

  var level1 = 0;
  var level2 = 0;
  var level3 = 0;
  var level4 = 0;
  var level5 = 0;

  for (var i = 0; i < list.length -1; i++) {
    if (list[i+1][1] - list[i][1]  >= 14) {
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
    else if (list[i+1][1] - list[i][1]  >= 6) {
      level1++;
    }
  }
  var indexOfSharpAccelerated = level1 + (level2 * 2) + (level3 * 3) + (level4 * 4) + (level5 * 5);
  return indexOfSharpAccelerated;
}

int getSharpDecelerated(List<dynamic> list) {
  var level1 = 0;
  var level2 = 0;
  var level3 = 0;
  var level4 = 0;
  var level5 = 0;

  for (var i = 0; i < list.length -2; i++) {
    if (list[i][1] - list[i+1][1] >= 21) {
      level5++;
    }
    else if (list[i][1] - list[i+1][1] >= 17) {
      level4++;
    }
    else if (list[i][1] - list[i+1][1] >= 13) {
      level3++;
    }
    else if (list[i][1] - list[i+1][1]  >= 9) {
      level2++;
    }
    else if (list[i][1] - list[i+1][1]  >= 7) {
      level1++;
    }
  }

  var indexOfSharpDecelerated = level1 + (level2 * 2) + (level3 * 3) + (level4 * 4) + (level5 * 5);
  return indexOfSharpDecelerated;
}

