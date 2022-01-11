import 'package:flutter/material.dart';

class Review extends StatelessWidget {
  int count = 0;

  void incrementCounter() {
      count++;
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