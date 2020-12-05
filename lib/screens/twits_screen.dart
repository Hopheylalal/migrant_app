import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:migrant_app/widgets/twit_widget.dart';

class TwitsScreen extends StatefulWidget {
  @override
  _TwitsScreenState createState() => _TwitsScreenState();
}

class _TwitsScreenState extends State<TwitsScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  bool myTwits = false;
  String userUid;

  getUserUid() async {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      userUid = userIdFuture;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Лента'),
        centerTitle: true,
        actions: [
          FlatButton.icon(
              label: myTwits == false
                  ? Text(
                      'Все',
                      style: TextStyle(color: Colors.white),
                    )
                  : Text(
                      'Мои',
                      style: TextStyle(color: Colors.white),
                    ),
              icon: Icon(
                Icons.filter_list,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  myTwits = !myTwits;
                });
              })
        ],
      ),
      body: myTwits == false
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('twits')
                  .orderBy('createDate', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  List twits = snapshot.data.docs;

                  return ListView.builder(
                    itemCount: twits.length,
                    itemBuilder: (BuildContext context, int index) {
                      return TwitWidget(
                        urlAvatar: twits[index]['urlAvatar'],
                        createDate: twits[index]['createDate'],
                        name: twits[index]['name'],
                        content: twits[index]['content'],
                        countryCode: twits[index]['countryCode'],
                        userId: twits[index]['ownerId'],
                        twitId: twits[index]['twitId'],
                        age: twits[index]['age'],
                        country: twits[index]['country'],

                      );
                    },
                  );
                }
                return Container();
              },
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('twits')
                  .where('ownerId', isEqualTo: userUid)
                  .orderBy('createDate', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  List twits = snapshot.data.docs;

                  return ListView.builder(
                    itemCount: twits.length,
                    itemBuilder: (BuildContext context, int index) {
                      return TwitWidget(
                        urlAvatar: twits[index]['urlAvatar'],
                        createDate: twits[index]['createDate'],
                        name: twits[index]['name'],
                        content: twits[index]['content'],
                        countryCode: twits[index]['countryCode'],
                        userId: twits[index]['ownerId'],
                        twitId: twits[index]['twitId'],
                        age: twits[index]['age'],
                        country: twits[index]['country'],
                      );
                    },
                  );
                }
                return Container();
              },
            ),
    );
  }
}
