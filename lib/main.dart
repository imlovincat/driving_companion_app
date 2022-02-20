import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'menu.dart';
import 'signInPage.dart';

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

class MyApp extends StatelessWidget {

  var isLoggedIn = (user != null) ? false: user == null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          home: isLoggedIn ? SignInPage() : Menu()
    );
  }
}
