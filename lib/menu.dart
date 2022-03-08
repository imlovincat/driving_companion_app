import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'monitor.dart';
import 'review.dart';
import 'register.dart';
import 'signInPage.dart';
import 'profile.dart';
import 'pageviewDemo.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Menu extends StatelessWidget {

  final User? user = _auth.currentUser;

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
              TextButton(
                  child: Text(
                      'Monitor',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24
                      )
                  ),
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => new Monitor()
                    ));
                  },
                ),
              TextButton(
                child: Text(
                    'Profile',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24
                    )
                ),
                onPressed: () {
                  Navigator.push(
                    context, MaterialPageRoute(
                        builder: (context) => Profile()
                    )
                  );
                },
              ),
              TextButton(
                child: Text(
                    'Review',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24
                    )
                ),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) => Review()
                  )
                  );
                },
              ),
              TextButton(
                child: Text(
                    'Sign out',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24
                    )
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
}