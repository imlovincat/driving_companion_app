import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final FirebaseAuth _auth = FirebaseAuth.instance;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () async {
                  final User? user = _auth.currentUser;
                  if (user == null) {
                    ScaffoldSnackbar.of(context).show('No one has signed in.');
                    return;
                  }
                  await _signOut();

                  final String uid = user.uid;
                  ScaffoldSnackbar.of(context)
                      .show('$uid has successfully signed out.');
                },
                child: const Text('Sign out'),
              );
            },
          )
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          return ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              _UserInfoCard(user: user),
              const _EmailPasswordForm(),
            ],
          );
        },
      ),
    );
  }

  /// Example code for sign out.
  Future<void> _signOut() async {
    await _auth.signOut();
  }
}

class _UserInfoCard extends StatefulWidget {
  const _UserInfoCard({Key? key, this.user}) : super(key: key);

  final User? user;

  @override
  _UserInfoCardState createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<_UserInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              alignment: Alignment.center,
              child: const Text(
                'User info',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (widget.user != null)
              if (widget.user!.photoURL != null)
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Image.network(widget.user!.photoURL!),
                )
              else
                Align(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.black,
                    child: const Text(
                      'No image',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            Text(
              widget.user == null
                  ? 'Not signed in'
                  : '${widget.user!.isAnonymous ? 'User is anonymous\n\n' : ''}'
                  'Email: ${widget.user!.email} (verified: ${widget.user!.emailVerified})\n\n'
                  'Phone number: ${widget.user!.phoneNumber}\n\n'
                  'Name: ${widget.user!.displayName}\n\n\n'
                  'ID: ${widget.user!.uid}\n\n'
                  'Tenant ID: ${widget.user!.tenantId}\n\n'
                  'Refresh token: ${widget.user!.refreshToken}\n\n\n'
                  'Created: ${widget.user!.metadata.creationTime.toString()}\n\n'
                  'Last login: ${widget.user!.metadata.lastSignInTime}\n\n',
            ),
            if (widget.user != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.user!.providerData.isEmpty
                        ? 'No providers'
                        : 'Providers:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  for (var provider in widget.user!.providerData)
                    Dismissible(
                      key: Key(provider.uid!),
                      onDismissed: (action) =>
                          widget.user!.unlink(provider.providerId),
                      child: Card(
                        color: Colors.grey[700],
                        child: ListTile(
                          leading: provider.photoURL == null
                              ? IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () =>
                                  widget.user!.unlink(provider.providerId))
                              : Image.network(provider.photoURL!),
                          title: Text(provider.providerId),
                          subtitle: Text(
                              "${provider.uid == null ? "" : "ID: ${provider.uid}\n"}"
                                  "${provider.email == null ? "" : "Email: ${provider.email}\n"}"
                                  "${provider.phoneNumber == null ? "" : "Phone number: ${provider.phoneNumber}\n"}"
                                  "${provider.displayName == null ? "" : "Name: ${provider.displayName}\n"}"),
                        ),
                      ),
                    ),
                ],
              ),
            Visibility(
              visible: widget.user != null,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => widget.user!.reload(),
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) =>
                            UpdateUserDialog(user: widget.user),
                      ),
                      icon: const Icon(Icons.text_snippet),
                    ),
                    IconButton(
                      onPressed: () => widget.user!.delete(),
                      icon: const Icon(Icons.delete_forever),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateUserDialog extends StatefulWidget {
  const UpdateUserDialog({Key? key, this.user}) : super(key: key);

  final User? user;

  @override
  _UpdateUserDialogState createState() => _UpdateUserDialogState();
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  TextEditingController? _nameController;
  TextEditingController? _urlController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.user!.displayName);
    _urlController = TextEditingController(text: widget.user!.photoURL);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update profile'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            TextFormField(
              controller: _nameController,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'displayName'),
            ),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'photoURL'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autocorrect: false,
              validator: (String? value) {
                if (value != null && value.isNotEmpty) {
                  var uri = Uri.parse(value);
                  if (uri.isAbsolute) {
                    //You can get the data with dart:io or http and check it here
                    return null;
                  }
                  return 'Faulty URL!';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.user!.updateDisplayName(_nameController!.text);
            widget.user!.updatePhotoURL(_urlController!.text);

            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        )
      ],
    );
  }

  @override
  void dispose() {
    _nameController!.dispose();
    _urlController!.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'Sign in with email and password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
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
      ))
          .user!;
      ScaffoldSnackbar.of(context).show('${user.email} signed in');
    } catch (e) {
      ScaffoldSnackbar.of(context)
          .show('Failed to sign in with Email & Password');
    }
  }
}


