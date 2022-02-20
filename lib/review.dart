import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'result.dart';
import 'menu.dart';
import 'output.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
List<dynamic> trip = [];
String test ="o";

class Review extends StatelessWidget {

  CollectionReference journeys = FirebaseFirestore.instance.collection('journeys');
  late List<dynamic> trip = [];
  //late Map<String, dynamic>? test3;
  late String test;

  @override
  Widget build(BuildContext context) {
    getString();
    return WillPopScope (
        onWillPop: () async {
      return Future.value(false);
    },
    child: MaterialApp(
        home: Scaffold(
          appBar: PreferredSize(
            // hold space for mobile phone original topbar and ignore AppBar as its size is 0
              preferredSize: Size(double.infinity, 60),
              child: AppBar(
                title: Text('Journey Records'),
                centerTitle: true,
                backgroundColor: Colors.black,
                //leading: Icon(Icons.account_circle_rounded),
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
                    var documentID = document.reference.id;
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      return ListTile(
                        leading: Icon(Icons.list),
                        title: Text(data['createdAt']),
                        subtitle: Text(documentID),
                        trailing: TextButton(
                          child: Text('view'),
                          onPressed: () async{
                            await getData(documentID);
                            Navigator.push(
                                context, MaterialPageRoute(
                                builder: (context) => Result("review",trip))
                            );
                          }
                        ),
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



  Future<void> getString() async {
    var collection = FirebaseFirestore.instance.collection('journeys');
    var document = await collection.doc('4iew2iiVk93PGFyleSlx').get();
    if (document.exists) {
      Map<String, dynamic>? data = document.data();
      test = data?['createdAt'];
    }
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
}

