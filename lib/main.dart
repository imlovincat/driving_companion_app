import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'menu.dart';
import 'signInPage.dart';
import 'algorithmJson.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;


Future<void> main() async {

  //for firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //only allow portrait mode
  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  //fullscreen, disable status and navigation bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyState createState() => _MyState();

}

class _MyState extends State<MyApp> {

  var isLoggedIn = (user != null) ? false: user == null;
  var userUID ="";

  @override
  void initState() {
    if (user != null) {
      getUserInfo(getUserUID());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          home: isLoggedIn ? SignInPage() : Menu()
    );
  }

  String getUserUID() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return user.uid.toString();
    }
    return "";
  }

  Future<void> getUserInfo(String uid) async{
    var sessionManager = SessionManager();
    var collection = FirebaseFirestore.instance.collection('users');
    var document = await collection.doc(uid).get();

    if (document.exists) {
      Map<String, dynamic>? data = document.data();
      await sessionManager.set('firstname', data?['firstname']);
      await sessionManager.set('surname', data?['surname']);
      await sessionManager.set('nickname', data?['nickname']);
      await sessionManager.set('group', data?['group']);
      await sessionManager.set('algorithm', data?['algorithm']);
      Map<String, dynamic> rule = await setAlgorithmSession(await SessionManager().get('algorithm'));
      List<int> speeding = [];
      for (var i = 0; i < rule['speeding'].length; i++) {
        speeding.add(rule['speeding'][i].toInt());
      }
      List<int> braking = [];
      for (var i = 0; i < rule['braking'].length; i++) {
        braking.add(rule['braking'][i].toInt());
      }
      List<int> accelerating = [];
      for (var i = 0; i < rule['accelerating'].length; i++) {
        accelerating.add(rule['accelerating'][i].toInt());
      }
      AlgorithmJson scoring = AlgorithmJson(speeding,braking,accelerating);
      await sessionManager.set('scoring', scoring);
    }
  }

  Future <Map<String, dynamic>> setAlgorithmSession(String algorithmName) async {

    Map<String, dynamic> rule = {};
    //Map<String, dynamic> rule = {'speeding':[5,10,15,20,25],'braking':[7,10,13,16,19],'accelerating':[6,8,10,12,14]};
    var collection = FirebaseFirestore.instance.collection('algorithm');
    var document = await collection.doc(algorithmName).get();
    if (document.exists) {
      Map<String, dynamic>? data = document.data();
      rule['speeding'] = data?['speeding'];
      rule['braking'] = data?['braking'];
      rule['accelerating'] = data?['accelerating'];
      return rule;
    }
    return rule;
  }

}

