import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
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
  SetAlgorithm(this.algorithm);
  @override
  SetAlgorithmState createState() => SetAlgorithmState();
}

class SetAlgorithmState extends State<SetAlgorithm> {

  late Map<String, dynamic> dataList = {};
  late String method ="";

  @override
  void initState() {
    getMethod().then((val) => setState(() {
      method = val;
      print("method: ${method.toString()}");
      getData(method).then((val) => setState(() {
        dataList = val;
        print("list: ${dataList.toString()}");
      }));
    }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    print("list: ${dataList.toString()}");

    List<dynamic> speeding = dataList['speeding'];
    List<dynamic> accelerating = dataList['accelerating'];
    List<dynamic> braking = dataList['braking'];

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

              body: Center (
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
                        "${method}",
                        style: TextStyle(color: Colors.black, fontSize: 40),
                      ),
                      SizedBox(
                          height:20
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Speeding : '),
                        initialValue: speeding.toString(),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Format: [1,2,3,4,5]';
                          return null;
                        },
                      ),
                      TextFormField (
                        decoration: const InputDecoration(labelText: 'Accelerating : '),
                        initialValue: accelerating.toString(),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Please enter some text';
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Braking: '),
                        initialValue: braking.toString(),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Please enter some text';
                          return null;
                        },
                      ),
                      SizedBox(
                          height:50
                      ),
                      ElevatedButton(
                        onPressed: () {

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

  Future<Map<String, dynamic>> getData(String method) async{

    Map<String, dynamic> list = {};
    var collection = FirebaseFirestore.instance.collection('algorithm');
    var document = await collection.doc(method).get();
    if (document.exists) {
      Map<String, dynamic>? data = document.data();
      list['speeding'] = data?['speeding'];
      list['braking'] = data?['braking'];
      list['accelerating'] = data?['accelerating'];
    }
    print(list.toString());
    return list;
  }

  Future<String> getMethod() async{
    return widget.algorithm;
  }




}
