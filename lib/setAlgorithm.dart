import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'algorithmJson.dart';
import 'drivingScore.dart';
import 'route.dart';
import 'review.dart';
import 'menu.dart';

class SetAlgorithm extends StatefulWidget {
  final String algorithm;
  final Map<String, dynamic> list;
  SetAlgorithm(this.algorithm, this.list);
  @override
  SetAlgorithmState createState() => SetAlgorithmState();
}

class SetAlgorithmState extends State<SetAlgorithm> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final TextEditingController _speedingController = TextEditingController(text: widget.list['speeding'].toString());
    final TextEditingController _acceleratingController = TextEditingController(text: widget.list['accelerating'].toString());
    final TextEditingController _brakingController = TextEditingController(text: widget.list['braking'].toString());

    return WillPopScope(
        onWillPop: () async {
          return Future.value(false);
        },
        child: MaterialApp(
          home: Scaffold(
              appBar: PreferredSize(
                  preferredSize: Size(double.infinity, 60),
                  child: AppBar(
                    title: Text('Scoring Setup'),
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

              body: Form (
                key: _formKey,
                child: Container(
                  alignment:Alignment.center,
                  padding: EdgeInsets.only(
                      left: 10,
                      top:10,
                      right: 10,
                      bottom: 10
                  ),
                  color: Color.fromARGB(255, 255, 255, 255),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Scoring Method",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      Text(
                        "${widget.algorithm}",
                        style: TextStyle(color: Colors.black, fontSize: 40),
                      ),
                      SizedBox(
                          height:20
                      ),
                      TextFormField(
                        controller: _speedingController,
                        decoration: const InputDecoration(labelText: 'Speeding : '),
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return 'Format: [1,2,3,4,5]';}
                          else if (json.decode(value).length != 5) {
                            return 'Format: [1,2,3,4,6]';

                          }
                          else {
                            return null;
                          }
                        },
                      ),
                      TextFormField (
                        controller: _acceleratingController,
                        decoration: const InputDecoration(labelText: 'Accelerating : '),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Please enter some text';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _brakingController,
                        decoration: const InputDecoration(labelText: 'Braking: '),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Please enter some text';
                          return null;
                        },
                      ),
                      SizedBox(
                          height:50
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          var method = widget.algorithm;
                          var speeding = json.decode(_speedingController.text);
                          var accelerating = json.decode(_acceleratingController.text);
                          var braking = json.decode(_brakingController.text);

                          /*if (_formKey.currentState!.validate()) {
                            await saveData(method,speeding,accelerating,braking);
                          }*/
                        },
                        child: const Text('Submit'),
                      ),


                    ] ,
                  ),
                ),
              )
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> saveData(String method, List<dynamic> speeding, List<dynamic> accelerating, List<dynamic> braking) async {
    FirebaseFirestore.instance.collection('algorithm')
        .doc(method)
        .update({'speeding': speeding, 'accelerating' : accelerating, 'braking' : braking})
        .then((value) => print("Data updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

}
