import 'package:flutter/material.dart';
import 'monitor.dart';
import 'geolocator.dart';
import 'review.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
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
                  onPressed: () => {
                    Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => Monitor()
                        )
                    )
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
                  //Navigator.push(
                  //context, MaterialPageRoute(builder: (context) => Menu()));
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
                onPressed: () => {
                  Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) => Review()
                    )
                  )
                },
              ),
              TextButton(
                child: Text(
                    'Ranking',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24
                    )
                ),
                onPressed: () {
                  //Navigator.push(
                  //context, MaterialPageRoute(builder: (context) => Menu()));
                },
              ),

            ] ,
          ),
        ),
    );

  }
}