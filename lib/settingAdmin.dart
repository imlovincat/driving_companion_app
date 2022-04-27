import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'algorithmJson.dart';
import 'menu.dart';
import 'setAlgorithm.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SettingAdmin extends StatefulWidget {
  @override
  _SettingAdminState createState() => _SettingAdminState();
}

class _SettingAdminState extends State<SettingAdmin> {

  String dropdownValue = '';
  late List<DropdownMenuItem<String>> dropdownMenu = [];

  @override
  void initState() {
    getScoringMethod().then((val) => setState(() {
      dropdownValue = val;
    }));
    dropdownItemList().then((items) => setState(() {
      dropdownMenu = items;
    }));
    super.initState();
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
                      title: Text('SCORING METHOD'),
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
                      actions: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.settings),
                          tooltip: 'Setting',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('This is a snackbar')));
                          },
                        ),
                      ],
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
                              SizedBox(
                                  height:60
                              ),
                              Container(
                                width: 250,
                                height: 250,
                                child: Image.asset(
                                  'assets/images/scoring.png',
                                ),
                              ),
                              SizedBox(
                                  height:60
                              ),
                              Text(
                                "Difficulty Level",
                                style: TextStyle(color: Colors.grey, fontSize: 30),
                              ),
                              SizedBox(
                                  height:20
                              ),
                              Container(
                                color: Colors.white,
                                height: 50,
                                width: 200,
                                alignment: Alignment.center,
                                // set width equal to height to make a square
                                child: DropdownButton<String>(
                                    value: dropdownValue,
                                    //elevation: 156,
                                    style: const TextStyle(color: Colors.black, fontSize: 30),
                                    //itemHeight: 20,
                                    iconEnabledColor: Colors.black,
                                    //focusColor: Colors.purple,
                                    //dropdownColor: Colors.purple,
                                    //borderRadius: BorderRadius.all(Radius.circular(20)),
                                    onChanged: (String? newValue){
                                      setState(() {
                                        dropdownValue = newValue!;
                                        print(newValue);
                                      });
                                    },
                                    items: dropdownMenu
                                ),
                              ),
                              SizedBox(
                                  height:60
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width:50
                                  ),
                                  SizedBox(
                                    width: 120,
                                    height: 50,
                                    child: RaisedButton.icon(
                                        icon: Icon(Icons.save_alt),
                                        color: Colors.green,
                                        label: Text(
                                          'Save',
                                          style: TextStyle(color: Colors.black, fontSize: 22),
                                        ),
                                        //textColor: Colors.grey,
                                        onPressed:() {
                                          setScoringMethod(dropdownValue);
                                          setSession(dropdownValue);
                                          Navigator.push(
                                              context, MaterialPageRoute(
                                              builder: (context) => Menu()
                                          )
                                          );
                                        }
                                    ),
                                  ),
                                  SizedBox(
                                      width:10
                                  ),
                                  SizedBox(
                                    width: 120,
                                    height: 50,
                                    child: RaisedButton.icon(
                                        icon: Icon(Icons.edit),
                                        color: Colors.red,
                                        label: Text(
                                          'Edit',
                                          style: TextStyle(color: Colors.black, fontSize: 22),
                                        ),
                                        //textColor: Colors.grey,
                                        onPressed:() async{
                                          setScoringMethod(dropdownValue);
                                          setSession(dropdownValue);
                                          Map<String, dynamic> list = await getData(dropdownValue);
                                          Navigator.push(
                                              context, MaterialPageRoute(
                                              builder: (context) => SetAlgorithm(dropdownValue,list)
                                          )
                                          );
                                        }
                                    ),
                                  ),
                                  SizedBox(
                                      width:50
                                  ),
                                ],
                              ),

                              SizedBox(
                                  height:100
                              ),
                            ]
                        )
                    )
                )
            )
        )
    );
  }
  @override
  void dispose() {
    super.dispose();
  }

  String userUID() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return user.uid.toString();
    }
    return "";
  }

  String userEmail() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return user.email.toString();
    }
    return "";
  }

  Future<void> setScoringMethod(String algorithmName) async {
    FirebaseFirestore.instance.collection('users')
        .doc(userUID())
        .update({'algorithm': algorithmName})
        .then((value) => print("Data updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> setSession(String algorithmName) async{
    var collection = FirebaseFirestore.instance.collection('algorithm');
    var document = await collection.doc(algorithmName).get();
    Map<String, dynamic> rule = {};
    if (document.exists) {
      Map<String, dynamic>? data = document.data();

      print(data.toString());
      rule['speeding'] = data?['speeding'];
      rule['braking'] = data?['braking'];
      rule['accelerating'] = data?['accelerating'];
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
      await SessionManager().remove('scoring');
      await SessionManager().set('scoring',scoring);
      await SessionManager().remove('algorithm');
      await SessionManager().set('algorithm',dropdownValue);
    }
  }


  Future<List<DropdownMenuItem<String>>> dropdownItemList() async {
    List<DropdownMenuItem<String>> menuItems = [];
    await FirebaseFirestore.instance
        .collection('algorithm')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        menuItems.add(DropdownMenuItem(child: Text(doc.reference.id.toString()),value: doc.reference.id.toString()),);
      });
    });
    return menuItems;
  }

  Future<String> getScoringMethod() async{
    return await SessionManager().get('algorithm');
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
    return list;
  }


}