import 'package:flutter/material.dart';
import 'menu.dart';

class Invalid extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      return Future.value(false);
    },
    child: MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 60),
            child: AppBar(
              title: Text('Invalid Record'),
              centerTitle: true,
              backgroundColor: Colors.black,
              leading: IconButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) => Menu()
                  ));
                },
                icon: Icon(Icons.home_outlined),
              ),
              elevation: 0, //remove shadow effect
            )
        ),
        body:
         Center(
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

            color: Color.fromARGB(255, 255, 255, 255),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    height:30
                ),
                Container(
                  width: 300,
                  height: 300,
                  child: Image.asset(
                    'assets/images/sorry.png',
                  ),
                ),
                SizedBox(
                    height:30
                ),
                Text(
                  "Your driving is not recorded!",
                  style: TextStyle(color: Colors.black, fontSize: 22),
                ),
                SizedBox(
                    height:30
                ),
                Text(
                  "A valid record must meet the following criteria:\n  • Driving for more than 5 minutes\n  • The driving distance is more than 1000 meters",
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
                SizedBox(
                    height:30
                ),
                SizedBox(
                    width: 200,
                    height: 50,
                    child: RaisedButton.icon(
                        icon: Icon(Icons.home),
                        color: Colors.green,
                        label: Text(
                            'Home',
                            style: TextStyle(color: Colors.black, fontSize: 22),
                        ),
                        //textColor: Colors.grey,
                        onPressed:() {
                          Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => Menu()
                          )
                          );
                        }
                    ),
                ),

                SizedBox(
                    height:100
                ),
              ] ,
            ),
          ),
        ),
      ),
    ));
  }
}