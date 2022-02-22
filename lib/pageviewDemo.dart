import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'drivingScore.dart';
import 'review.dart';
import 'menu.dart';

class PageViewDemo extends StatefulWidget {
  final List<dynamic> trip;
  final String mode;
  PageViewDemo(this.mode,this.trip);
  @override
  PageViewState createState() => PageViewState();
}

class PageViewState extends State<PageViewDemo> {

  final PageController controller = PageController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference journeys = FirebaseFirestore.instance.collection('journeys');
  //DatabaseReference fireBaseDB = FirebaseDatabase.instance.reference();
  List<dynamic> list = [];
  var drivingScore = 0;
  var tripDistance = "0";
  int maxSpeed = 0;
  int avgSpeed = 0;
  String totalTime ="00:00:00";

  @override
  void initState() {
    super.initState();
    list = widget.trip;
    drivingScore = getDrivingScore(list);
    //tripDistance = getTripDistance(list).toString();
    //maxSpeed = getMaxSpeed(list);
    //avgSpeed = getAvgSpeed(list);
    totalTime = list.last[0];
    //addRecord(list);
  }

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
              title: Text('Journey Report'),
              centerTitle: true,
              backgroundColor: Colors.black,
              //leading: Icon(Icons.account_circle_rounded),
              leading: IconButton(
                onPressed: () {
                  if (widget.mode == "review") {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => Review()
                    ));
                  }
                  else if (widget.mode == "monitor") {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => Menu()
                    ));
                  }

                },
                icon: Icon(Icons.home_outlined),
              ),
              elevation: 0, //remove shadow effect
            )
        ),
        body: PageView(
          controller: controller,
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Your Journey Report",
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                  Text(
                    "Driving Score",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  Text(
                    drivingScore.toString(),
                    style: TextStyle(color: Colors.black, fontSize: 80),
                  ),
                  Text(
                    "Total Time: $totalTime",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ]
              ),
            ),
            Center(
              child: Text('Second Page'),
            ),
            Center(
              child: Text('Third Page'),
            )
          ],
        )
      ),
    ));
  }
  @override
  void dispose() {
    super.dispose();
  }
}
