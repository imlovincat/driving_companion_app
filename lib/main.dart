import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'menu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
