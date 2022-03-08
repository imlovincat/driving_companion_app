import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';


class Output extends StatefulWidget {

  String test = "";
  Output(this.test);
  @override
  GoForOutPut createState() => GoForOutPut();
}

class GoForOutPut extends State<Output> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference journeys = FirebaseFirestore.instance.collection('journeys');
  String test2 = "";



  @override
  Widget build(BuildContext context) {
    test2 = widget.test;
    return MaterialApp(
          home: Scaffold(
            appBar: PreferredSize(
              // hold space for mobile phone original topbar and ignore AppBar as its size is 0
                preferredSize: Size(double.infinity, 0),
                child: AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0, //remove shadow effect
                )
            ),
            body: Center(

              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Your Journey Report",
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                  Text(
                    test2,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  TextButton(
                    child: Text(
                        'Save',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 24
                        )
                    ),
                    onPressed: () {
                    },
                  )
                ],
              ),
            ),
          ),
        );
  }
  @override
  void dispose() {
    super.dispose();
  }
}
