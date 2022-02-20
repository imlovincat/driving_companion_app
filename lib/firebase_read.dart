import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Review extends StatelessWidget {

  CollectionReference journeys = FirebaseFirestore.instance.collection('journeys');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          // hold space for mobile phone original topbar and ignore AppBar as its size is 0
            preferredSize: Size(double.infinity, 0),
            child: AppBar(
              backgroundColor: Colors.black,
              elevation: 0, //remove shadow effect
            )
        ),
        body: FutureBuilder<DocumentSnapshot> (
            future: journeys.doc('4iew2iiVk93PGFyleSlx').get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return Text("Document does not exist");
              }

              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                return Text("Created at: ${data['createdAt']}");
              }
              return Text("Loading");

            }


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
}

