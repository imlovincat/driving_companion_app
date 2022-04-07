import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'monitor.dart';
import 'review.dart';
import 'signInPage.dart';
import 'profile.dart';
import 'setting.dart';
import 'settingAdmin.dart';
import 'ranking.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Menu extends StatelessWidget {

  final User? user = _auth.currentUser;
  late String group = "USER";

  Menu() {
    groupAccess().then((val) {
      group = val;
      printSession();

    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      return Future.value(false);
    },

      child: Center(
        child: Container(
          alignment:Alignment.center,
          /*
          constraints: BoxConstraints(
            maxWidth: 300,
            maxHeight: 300,
            minWidth: 50,
            minHeight: 50
          ),
          margin: EdgeInsets.only(
            left: 10,
            top:10,
            right: 10,
            bottom: 10
          ),
          */
          padding: EdgeInsets.only(
            left: 10,
            top:10,
            right: 10,
            bottom: 10
          ),

          color: Color.fromARGB(255, 37, 141, 229),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              /*Container(
                width: 100,
                height: 100,
                child: Image.asset(
                  'assets/images/a1.png',
                ),
              ),*/
              TextButton.icon(
                  icon: Icon(Icons.directions_car,size: 32.0),
                  label: Text('Monitor', style: TextStyle(color: Colors.white, fontSize: 28)),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => new Monitor()
                    ));
                  },
                ),
              TextButton.icon(
                icon: Icon(Icons.person,size: 32.0),
                label: Text('Profile', style: TextStyle(color: Colors.white, fontSize: 28)),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context, MaterialPageRoute(
                        builder: (context) => Profile()
                    )
                  );
                },
              ),
              TextButton.icon(
                icon: Icon(Icons.history,size: 32.0),
                label: Text('History', style: TextStyle(color: Colors.white, fontSize: 28)),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) => Review()
                  )
                  );
                },
              ),
              TextButton.icon(
                icon: Icon(Icons.assistant_photo,size: 32.0),
                label: Text('Ranking', style: TextStyle(color: Colors.white, fontSize: 28)),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) => Ranking()
                  )
                  );
                },
              ),
              TextButton.icon(
                icon: Icon(Icons.settings,size: 32.0),
                label: Text('Setting', style: TextStyle(color: Colors.white, fontSize: 28)),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  if (group == "ADMIN") {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => SettingAdmin()
                    ));
                  }
                  else {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => Setting()
                    ));
                  }

                },
              ),
              TextButton.icon(
                icon: Icon(Icons.add_to_home_screen,size: 32.0),
                label: Text('Sign out', style: TextStyle(color: Colors.white, fontSize: 28)),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () async {
                  await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        content: Text("Are you sure to exit current account."),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Cancel"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          FlatButton(
                            child: Text("OK"),
                            onPressed: () {
                              _auth.signOut();
                              Navigator.push(
                                  context, MaterialPageRoute(
                                  builder: (context) => SignInPage()
                              ));
                            }
                          )
                        ]
                      )
                  );
                },
              ),
            ] ,
          ),
        ),
    ));
  }

  Future<String> groupAccess() async{
    return await SessionManager().get('group');
  }

  void printSession() async{
    print(await SessionManager().get('firstname'));
    print(await SessionManager().get('surname'));
    print(await SessionManager().get('nickname'));
    print(await SessionManager().get('group'));
    print(await SessionManager().get('algorithm'));

  }

}