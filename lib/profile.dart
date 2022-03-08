import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu.dart';
import 'drivingScore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Profile extends StatelessWidget {

  //CollectionReference journeys = FirebaseFirestore.instance.collection('journeys');
  final Future<QuerySnapshot<Map<String,dynamic>>> query = FirebaseFirestore
    .instance
    .collection('journeys')
    .get();


  late List<dynamic> trip = [];

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
                  "Profile",
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
                Text(
                  "Username",
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
                FutureBuilder(
                  future: query,
                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasError) return Text('Something went wrong');
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      List<Map<String, dynamic>> lists = snapshot.data!.docs.map((e) => e.data() as Map<String, dynamic>).toList();

                    }

                ),
                RaisedButton.icon(
                    icon: Icon(Icons.play_arrow),
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
              ]
          )
      )
    )
      )
    )



    );
  }

  /*
  getAvgScore() async {
    List<dynamic> list = [];
    int score = 0;
    int count = 0;
    QuerySnapshot querySnapshot = await journeys
        .where('userUID', isEqualTo: userUID())
        .get();

    /*querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      var documentID = doc.reference.id;
      //getData(documentID);
      //score += getDrivingScore(list);
      count++;
    }).toList();
    //return score ~/ count;
    return count;*/
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    return allData.toString();
  }*/


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
  }

  String userUID() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return user.uid.toString();
    }
    return "";
  }
}