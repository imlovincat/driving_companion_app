import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'menu.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

/// Entrypoint example for various sign-in flows with Firebase.
class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);
  /// The page title.
  final String title = 'Account Sign In';
  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  User? user;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    _auth.userChanges().listen(
          (event) => setState(() => user = event),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Builder(
            builder: (BuildContext context) {
              return Center(
                  child: Form(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget> [
                            Spacer(flex: 2),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(labelText: 'Email address'),
                              validator: (String? value) {
                                if (value!.isEmpty) return 'Please enter some text';
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(labelText: 'Password'),
                              validator: (String? value) {
                                if (value!.isEmpty) return 'Please enter some text';
                                return null;
                              },
                              obscureText: true,
                            ),
                            SignInButton(
                              Buttons.Email,
                              text: 'Sign In',
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await _signInWithEmailAndPassword();
                                }
                              },
                            ),
                            Spacer(flex: 2),
                          ]
                      )
                  )
              );
            }
        )
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Example code of how to sign in with email and password.
  Future<void> _signInWithEmailAndPassword() async {
    try {
      final User user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )).user!;
      ScaffoldSnackbar.of(context).show('${user.email} signed in');
      Navigator.push(
          context, MaterialPageRoute(
          builder: (context) => Menu()
      ));
    } catch (e) {
      ScaffoldSnackbar.of(context)
          .show('Failed to sign in with Email & Password');
    }
  }
}

/// Helper class to show a snackbar using the passed context.
class ScaffoldSnackbar {
  ScaffoldSnackbar(this._context);
  final BuildContext _context;

  /// The scaffold of current context.
  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  /// Helper method to show a SnackBar.
  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}
