import 'package:flutter/material.dart';

class Monitor extends StatefulWidget {
  @override
  Journey createState() => new Journey();
}

class Journey extends State<Monitor> {
  int count = 0;

  void incrementCounter() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: null,
        ),
        body: Center(
          child: TextButton(
            onPressed: () => {
              incrementCounter()
            },
            child: Text('Button Clicks - $count'),
          ),
        ),
      ),
    );
  }
}