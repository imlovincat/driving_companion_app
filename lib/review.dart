import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'result.dart';
import 'menu.dart';
import 'output.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Review extends StatelessWidget {

  CollectionReference journeys = FirebaseFirestore.instance.collection('journeys');
  late List<dynamic> trip = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope (
        onWillPop: () async {
      return Future.value(false);
    },
    child: MaterialApp(
        home: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size(double.infinity, 60),
              child: AppBar(
                title: Text('Journey Records 13'),
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
          body: FutureBuilder<QuerySnapshot> (
            future: journeys
                .where('userUID', isEqualTo: userUID())
                .get(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    var documentID = document.reference.id;

                    return ListTile(
                        leading: Icon(
                            Icons.directions_car,
                            size: 36.0,
                        ),
                        title: Text(
                            "Date: ${data['createdAt'].toDate().toString().substring(0,19)}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12
                            )
                        ),
                        subtitle: Text(
                            "Duration: ${data['time'][data['time'].length -1]}  Distance: ${getTripDistance(data['geoPoint']).toString()} meters",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 8
                            )
                        ),

                        trailing: RaisedButton (
                          child: Text('Details'),
                          textColor: Colors.grey,
                          onPressed: () async{
                            await getData(documentID);
                            Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => Result("review",trip))
                            );
                          }
                        )
                      );
                  }).toList(),
                );
              }
              return Text("Loading");
            }
          )
        ),
      )
    );
  }

  String userUID() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return user.uid.toString();
    }
    return "";
  }

  Future<void> getData(String documentID) async {
    trip = [];
    List<dynamic> time = [];
    List<dynamic> speed = [];
    List<dynamic> location = [];

    var collection = FirebaseFirestore.instance.collection('journeys');
    var document = await collection.doc(documentID).get();

    if (document.exists) {
      Map<String, dynamic>? data = document.data();
      //test3 = document.data();

      data?["time"].forEach((v) => time.add(v));
      data?["speed"].forEach((v) => speed.add(v));
      data?["geoPoint"].forEach((v) => location.add(v));

      for (var i = 0; i < time.length; i++) {
        trip.add([time[i],speed[i],location[i]]);
      }
    }
  }

  int getTripDistance(List<dynamic> list) {
    var distance = 0.0;
    var totalDistance = 0.0;
    var currentlatitude = 0.0;
    var currentlongitude = 0.0;
    var lastlatitude = 0.0;
    var lastlongitude = 0.0;
    for (var i = 0; i < list.length -2; i++) {
      lastlatitude = list[i].latitude;
      lastlongitude = list[i].longitude;
      currentlatitude = list[i+1].latitude;
      currentlongitude = list[i+1].longitude;
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
}

