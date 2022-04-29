/**
 * Institue of Technology Carlow
 * Software Development Final Year Project
 * Student Chi Ieong Ng C00223421
 */

import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart';
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
  return drivingScoreAlgorithm(rule,list);
}

Future<int> drivingScoreAlgorithm(Map<String, dynamic> rule,List<dynamic> list) async {

  var drivingScore = 100;
  List<int> speeding = rule['speeding'];
  List<int> accelerating = rule['accelerating'];
  List<int> braking = rule['braking'];

  int sharpAccelerated = getSharpAccelerated(accelerating,list);
  int sharpDecelerated = getSharpDecelerated(braking,list);
  int overSpeed = await getOverSpeeding(speeding, list);
  print("overspeed: $overSpeed");

  drivingScore = drivingScore - sharpAccelerated - sharpDecelerated - overSpeed;

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
    if (wavePeak == false && list[i][1] - list[i+1][1] >= 1 ) {wavePeak = true;}
    else if (wavePeak == true && list[i+1][1] - list[i][1] >= 1 ) {
      indexOfSharpAccelerated++;
      wavePeak = false;
    }

    if (list[i+1][1] - list[i][1] >= accelerating[4]) {level5++;}
    else if (list[i+1][1] - list[i][1] >= accelerating[3]) {level4++;}
    else if (list[i+1][1] - list[i][1] >= accelerating[2]) {level3++;}
    else if (list[i+1][1] - list[i][1] >= accelerating[1]) {level2++;}
    else if (list[i+1][1] - list[i][1] >= accelerating[0]) {level1++;}
  }

  var indice = 100 /indexOfSharpAccelerated;
  var mistakes = level1 + (level2 * 2) + (level3 * 3) + (level4 * 4) + (level5 * 5);
  var deduction= (mistakes * indice) / 2;
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
    if (wavePeak == false && list[i+1][1] - list[i][1] >= 1 ) {
      wavePeak = true;
    }
    else if (wavePeak == true && list[i][1] - list[i+1][1] >= 1 ) {
      indexOfSharpDecelerated++;
      wavePeak = false;
    }

    if (list[i][1] - list[i+1][1] >= braking[4]) {level5++;}
    else if (list[i][1] - list[i+1][1] >= braking[3]) {level4++;}
    else if (list[i][1] - list[i+1][1] >= braking[2]) {level3++;}
    else if (list[i][1] - list[i+1][1] >= braking[1]) {level2++;}
    else if (list[i][1] - list[i+1][1] >= braking[0]) {level1++;}
  }

  var indice = 100 / indexOfSharpDecelerated;
  var mistakes = level1 + (level2 * 2) + (level3 * 3) + (level4 * 4) + (level5 * 5);
  var deduction= (mistakes * indice) / 2;
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

Future<List<double>> getRating(AlgorithmJson json, List<dynamic> list) async {

  List<double> output = [0,0,0];

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

  int sharpAccelerated = getSharpAccelerated(rule['accelerating'],list);
  int sharpDecelerated = getSharpDecelerated(rule['braking'],list);
  int overSpeed = await getOverSpeeding(rule['speeding'], list);

  double speedingPercent = (50 - overSpeed) / 50;
  if (speedingPercent < 0) {
    speedingPercent = 0;
  }

  double acceleratingPercent = (50 - sharpAccelerated) / 50;
  if(acceleratingPercent < 0) {
    acceleratingPercent = 0;
  }

  double brakingPercent = (50 - sharpDecelerated) / 50;
  if(brakingPercent < 0) {
    brakingPercent = 0;
  }

  output = [speedingPercent,acceleratingPercent,brakingPercent];

  return output;
}

Future<int> getOverSpeeding(List<int> speeding, List<dynamic> list) async{
  int result = 0;
  List<dynamic> motorways = ['M1','M2','M3','M4','M6','M7','M8','M9','M11','M17','M18','M20','M50'];
  List<dynamic> nationalRoad = ['N1','N2','N3','N4','N5','N6','N7','N8','N9','N10','N11','N12','N13','N14','N15','N16','N17','N18','N19','N20','N21','N22','N23','N24','N25','N26','N27','N28','N29','N30','N31','N32','N33','N40'];
  List<dynamic> specifiedRoad = ['Green Rd'];
  int highestSpeed = 0;
  int index = 0;
  for(var i = 0; i < list.length; i++) {
    if (list[i][1] > highestSpeed) {
      highestSpeed = list[i][1];
      index = i;
    }
  }
  String postsURL = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${list[index][2].latitude},${list[index][2].longitude}&key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
  Response res = await get(Uri.parse(postsURL));
  if (res.statusCode == 200) {
    Map<String, dynamic> geocode = jsonDecode(res.body);
    for (var j = 0; j < geocode['results'].length; j++) {
      var address = geocode['results'][j]['address_components'][0]['short_name'].toString();
      print('address: ${address}');
      //motorways
      if(motorways.contains(address)) {
        if ((list[index][1] * (100 / 120)) - 100 >= speeding[4]) { result += 50;}
        else if ((list[index][1] * (100 / 120)) - 100 >= speeding[3]) { result += 30;}
        else if ((list[index][1] * (100 / 120)) - 100 >= speeding[2]) { result += 15;}
        else if ((list[index][1] * (100 / 120)) - 100 >= speeding[1]) { result += 10;}
        else if ((list[index][1] * (100 / 120)) - 100 >= speeding[0] ) { result += 5;}
        break;
      }
      //rationalRoad
      else if(nationalRoad.contains(address)) {
        if ((list[index][1] * (100 / 100)) - 100 >= speeding[4]) { result += 50;}
        else if ((list[index][1] * (100 / 100)) - 100 >= speeding[3]) { result += 30;}
        else if ((list[index][1] * (100 / 100)) - 100 >= speeding[2]) { result += 15;}
        else if ((list[index][1] * (100 / 100)) - 100 >= speeding[1]) { result += 10;}
        else if ((list[index][1] * (100 / 100)) - 100 >= speeding[0]) { result += 5;}
        break;
      }
      //Regional roads
      else if(address.length == 4 && address[0] == 'R' && double.tryParse(address[1]) != null && double.tryParse(address[2]) != null && double.tryParse(address[3]) != null) {
        if ((list[index][1] * (100 / 80)) - 100 >= speeding[4]) { result += 50;}
        else if ((list[index][1] * (100 / 80)) - 100 >= speeding[3]) { result += 30;}
        else if ((list[index][1] * (100 / 80)) - 100 >= speeding[2]) { result += 15;}
        else if ((list[index][1] * (100 / 80)) - 100 >= speeding[1]) { result += 10;}
        else if ((list[index][1] * (100 / 80)) - 100 >= speeding[0]) { result += 5;}
      }
      //specificed speed road
      else if(specifiedRoad.contains(address)) {
        if ((list[index][1] * (100 / 50)) - 100 >= speeding[4]) { result += 50;}
        else if ((list[index][1] * (100 / 50)) - 100 >= speeding[3]) { result += 30;}
        else if ((list[index][1] * (100 / 50)) - 100 >= speeding[2]) { result += 15;}
        else if ((list[index][1] * (100 / 50)) - 100 >= speeding[1]) { result += 10;}
        else if ((list[index][1] * (100 / 50)) - 100 >= speeding[0]) { result += 5;}
        break;
      }
      //city max speed
      else {
        if ((list[index][1] * (100 / 50)) - 100 >= speeding[4]) { result += 50;}
        else if ((list[index][1] * (100 / 50)) - 100 >= speeding[3]) { result += 30;}
        else if ((list[index][1] * (100 / 50)) - 100 >= speeding[2]) { result += 15;}
        else if ((list[index][1] * (100 / 50)) - 100 >= speeding[1]) { result += 10;}
        else if ((list[index][1] * (100 / 50)) - 100 >= speeding[0]) { result += 5;}
        break;
      }
    }
  }
  else { throw "Unable to retrieve posts.";}
  return result;
}
