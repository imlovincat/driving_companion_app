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

  String dropdownValue = 'Experience';
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
                      title: Text('Admin Setting'),
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
                                  height:20
                              ),
                              Text(
                                "SCORING METHOD",
                                style: TextStyle(color: Colors.black, fontSize: 24),
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
                                  height:40
                              ),
                              Row(
                                children: [
                                  RaisedButton.icon(
                                      icon: Icon(Icons.arrow_back_ios),
                                      label: Text('Save'),
                                      textColor: Colors.grey,
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
                                  SizedBox(
                                      width:20
                                  ),
                                  RaisedButton.icon(
                                      icon: Icon(Icons.arrow_back_ios),
                                      label: Text('Edit'),
                                      textColor: Colors.grey,
                                      onPressed:() {
                                        Navigator.push(
                                            context, MaterialPageRoute(
                                            builder: (context) => SetAlgorithm(dropdownValue)
                                        )
                                        );
                                      }
                                  ),
                                ],
                              ),

                              SizedBox(
                                  height:20
                              ),
                            ]
                        )
                    )
                )
            )
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

}