import 'package:flutter/material.dart';
import 'menu.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          body: Menu(),

        ));
  }
}
