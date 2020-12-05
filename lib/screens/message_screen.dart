import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:migrant_app/widgets/message_widget.dart';

class MessageScreen extends StatefulWidget {

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  DataController _dataController = Get.find();
  FirebaseAuth _auth = FirebaseAuth.instance;
  String userUid;
  String currentUserName;

  getUserName()async{
   final result = await FirebaseFirestore.instance.collection('userCollection').doc(userUid).get();
   currentUserName = result.data()['name'];
  }


  getUserUid() async {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      userUid = userIdFuture;
    });
  }
  error(){
    Get.snackbar('Ошибка', 'Повторите позже',colorText: Colors.white, backgroundColor: Colors.red);
  }

  setGeoLoc(){
    FirebaseFirestore.instance.collection('userCollection').doc(userUid).update({
      'geoLoc' : GeoPoint(_dataController.myLocation.latitude, _dataController.myLocation.latitude),
    }).catchError((e){
      print(e.message);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
    getUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Избранное'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('userCollection').doc(userUid).collection('favorites').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return LinearProgressIndicator();
          }
          if(snapshot.hasError){
            return error();
          }
          if(snapshot.hasData){
            List favorites = snapshot.data.docs;

            return ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (BuildContext context, int index) {
                return MessageWidget(
                  imgAvatar: favorites[index]['urlAvatar'],
                  name: favorites[index]['name'],
                  age: favorites[index]['age'],
                  countryCode: favorites[index]['countryCode'],
                  country: favorites[index]['country'],
                  userId: favorites[index]['id'],
                  currentUserId: userUid,
                  currentUserName: currentUserName,

                );
              },
            );
          }
          return Container();
        }
      ),
    );
  }
}
