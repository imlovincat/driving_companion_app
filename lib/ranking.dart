import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'algorithmJson.dart';
import 'drivingScore.dart';
import 'menu.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Ranking extends StatefulWidget {
  @override
  _Ranking createState() => _Ranking();

}

class _Ranking extends State<Ranking> {

  late List<dynamic> scoreList = [];
  String groupName = 'Default';

  @override
  void initState() {
    getData().then((list) => setState(() {
      print("list: $list");
      getUser(list).then((name) => setState(() {
        scoreList = name;
        print(scoreList);
      }));
    }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope (
        onWillPop: () async {
          return Future.value(false);
        },
        child: MaterialApp(
          home: Scaffold(
              appBar: PreferredSize(
                  preferredSize: Size(double.infinity, 60),
                  child: AppBar(
                    title: Text('Drivers Ranking'),
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
              body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,

                    children: <Widget>[
                      SizedBox(
                          height:30
                      ),
                      Container(
                        width: 200,
                        height: 120,
                        child: Image.asset(
                          'assets/images/trophy.png',
                        ),
                      ),
                      SizedBox(
                          height:30
                      ),
                      Expanded(child: ListView.builder(
                        //physics: ClampingScrollPhysics(),
                          shrinkWrap:true,
                          itemCount: scoreList.length,
                          itemBuilder: (BuildContext context, int index) {
                            Color rank = Colors.white;
                            Color edge = Colors.grey;
                            if (index == 0) {
                              rank = Colors.amber;
                              edge = Colors.amber;
                            }
                            else if (index == 1) {
                              rank =  Color.fromARGB(255, 121, 121, 121);
                              edge =  Color.fromARGB(255, 121, 121, 121);
                            }
                            else if (index == 2) {
                              rank =  Color.fromARGB(255, 130, 116, 89);
                              edge =  Color.fromARGB(255, 130, 116, 89);
                            }
                            return Container(
                                color: Colors.white,
                                margin: EdgeInsets.all(5),
                                padding: EdgeInsets.all(5),
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 20
                                    ),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: rank,
                                          border: Border.all(
                                            color: edge,
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(100))
                                      ),
                                      child: Text(
                                          "${index+1}",
                                          //scoreList[index].toString(),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize:28,
                                          )
                                      ),
                                    ),
                                    SizedBox(
                                        width: 30
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            scoreList[index][0].toString(),
                                            //scoreList[index].toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize:22,
                                            )
                                        ),
                                        Text(
                                            "Score: ${scoreList[index][1]} | ${scoreList[index][2]}  | ${scoreList[index][3]} meters",
                                            //scoreList[index].toString(),
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize:14,
                                            )
                                        ),

                                      ],
                                    ),
                                  ],
                                )
                            );
                          }
                      ))
                    ]
                ),

              )
          ),
        )
    );
  }

  Future <List<dynamic>> getData() async {
    List<dynamic> dataList = [];
    AlgorithmJson json = AlgorithmJson.fromJson(await SessionManager().get('scoring'));

    await FirebaseFirestore.instance
        .collection('journeys')
        .limit(100)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async{
        List<dynamic> list = [];
        var username = "";
        var createdAt;
        var score = 0;
        var second = 0;
        var duration = '0 second';
        var distance = 0;

        for (var i = 0; i < doc["speed"].length; i++) {
          list.add([doc["time"][i],doc["speed"][i],doc["geoPoint"][i]]);
          second ++;
        }
        username = doc['userUID'];
        score = await getDrivingScore(json,list);
        duration = transformSeconds(second);
        distance = getTripDistance(list);

        if (dataList.length == 0) {
          dataList.add([username,score,duration,distance]);
        }
        else {
          var add = false;
          for (var j = 0; j < dataList.length; j++) {
            if (score > dataList[j][1]) {
              dataList.insert(j,[username,score,duration,distance]);
              add = true;
              break;
            }
          }
          if (add == false) {
            dataList.add([username,score,duration,distance]);
          }
        }
      });
    });
    return Future.delayed(Duration(seconds: 2), () =>dataList);
  }

  Future <List<dynamic>> getUser(List<dynamic> list) async {

    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async{

        for (var i = 0; i < list.length; i++) {
          if (list[i][0] == doc.id) {
            list[i][0] = doc['nickname'];
          }
        }
      });
    });
    return list;
  }

  transformSeconds(int seconds) {
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();
    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return "$hoursStr:$minutesStr:$secondsStr";
  }

}