import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'menu.dart';
import 'register.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

/// Entrypoint example for various sign-in flows with Firebase.
class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);
  /// The page title.
  final String title = 'Sign In & Out';
  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  User? user;

  @override
  void initState() {
    _auth.userChanges().listen(
          (event) => setState(() => user = event),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      return Future.value(false);
      },
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 0),
            child: AppBar(
              backgroundColor: Colors.black,
              elevation: 0, //remove shadow effect
            )
        ),
      body: Builder(
        builder: (BuildContext context) {
          return Center(
            child: Container(
              alignment:Alignment.center,
              padding: EdgeInsets.only(
                  left: 30,
                  top:10,
                  right: 30,
                  bottom: 10
              ),
              color: Color.fromARGB(255, 37, 141, 229),
              child: Column (
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _EmailPasswordForm(),
                ]
              )
            )
          );
        },
      ),
    ));
  }
  @override
  void dispose() {
    super.dispose();
  }
}

class _EmailPasswordForm extends StatefulWidget {
  const _EmailPasswordForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 200,
                height: 170,
                child: Image.asset(
                  'assets/images/icon1.png',
                ),
              ),
              /*Container(
                alignment: Alignment.center,
                child: const Text(
                  'Sign in with email and password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                  height:50
              ),*/
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
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
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 14),
                ),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) => RegisterPage()
                  )
                  );
                },
                child: const Text('Register new account                                    \n'),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                alignment: Alignment.center,
                child: SignInButton(
                  Buttons.Email,
                  text: 'Sign In',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _signInWithEmailAndPassword();
                    }
                  },
                ),
              ),
              SizedBox(
                  height:50
              ),
            ],
          ),
        ),
      ),
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
      Navigator.push(
          context, MaterialPageRoute(
          builder: (context) => Menu()
      ));
    } catch (e) {
        print (e);
    }
  }
}


