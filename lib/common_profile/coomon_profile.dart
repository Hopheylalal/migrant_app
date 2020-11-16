import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:migrant_app/chat/chat_room.dart';
import 'package:migrant_app/common_profile/photo_album_common.dart';
import 'package:migrant_app/common_profile/profile_user_widget_common.dart';
import 'package:migrant_app/controllers/data_controller.dart';

import '../home.dart';

class ProfileCommon extends StatefulWidget {
  final reciverName;
  final senderName;
  final fromMapGetBack;

  const ProfileCommon({Key key, this.reciverName, this.senderName,this.fromMapGetBack}) : super(key: key);
  @override
  _ProfileCommonState createState() => _ProfileCommonState();
}

class _ProfileCommonState extends State<ProfileCommon> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  DataController _dataController = Get.put(DataController());

  String currentUser;
  DocumentSnapshot currentFavorUser;
  String content;

  String superNewUser = Get.arguments;

  bool buttonEnabled = true;
  bool buttonEnabled2 = true;
  bool buttonFavorStatus = false;

  GetStorage favorStatus = GetStorage();

  var hashChatID;

  getPath() {
    String strUser;
    var chatId = currentUser.hashCode + superNewUser.hashCode;
    hashChatID = chatId;
  }

  List userToFav = [];

  putUserToFavor() async {
    userToFav.add(superNewUser);
    favorStatus.write('$superNewUser', true);

    FirebaseFirestore.instance
        .collection('userCollection')
        .doc(currentUser)
        .update({'favor': FieldValue.arrayUnion(userToFav)}).whenComplete(() {
      _firebaseFirestore
          .collection('userCollection')
          .doc(currentUser)
          .collection('favorites')
          .doc(superNewUser)
          .set({
        'about': currentFavorUser.data()['about'],
        'age': currentFavorUser.data()['age'],
        'country': currentFavorUser.data()['country'],
        'countryCode': currentFavorUser.data()['countryCode'],
        'email': currentFavorUser.data()['email'],
        'gender': currentFavorUser.data()['gender'],
        'id': currentFavorUser.data()['id'],
        'name': currentFavorUser.data()['name'],
        'ownerFavor': currentUser,
        'phoneNumber': currentFavorUser.data()['phoneNumber'],
        'urlAvatar': currentFavorUser.data()['urlAvatar'],
      });
    });
  }

  void deleteContact() async {
    FirebaseFirestore _firebase = FirebaseFirestore.instance;

    List delToArray = [];
    delToArray.add(superNewUser);
    _firebase.collection('userCollection').doc(currentUser).update({
      'favor': FieldValue.arrayRemove(delToArray),
    }).whenComplete(() {
      _firebase
          .collection('userCollection')
          .doc(currentUser)
          .collection('favorites')
          .doc(superNewUser)
          .delete();
    }).whenComplete(() {
      favorStatus.write('$superNewUser', false);

      setState(() {});
    }).catchError((err) {
      print(err);
    });
  }

  getCurrentFavorUser() async {
    currentFavorUser = await _firebaseFirestore
        .collection('userCollection')
        .doc(Get.arguments)
        .get();
  }

  getUserUid() {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      currentUser = userIdFuture;
    });
  }

  addToFavor() async {
    final allFavorUser = await _firebaseFirestore
        .collection('userCollection')
        .doc(currentUser)
        .get();
    List allFavorUserList = allFavorUser.data()['favor'];
    List addFavor = [];

    if (allFavorUserList.contains(superNewUser)) {
      Get.snackbar('Оповещение', 'Пользователь уже был добавлен ранее',
          backgroundColor: Colors.orange, colorText: Colors.white);
    } else {
      favorStatus.write('$superNewUser', true);
      Get.snackbar('Оповещение', 'Пользователь добавлен в избранное',
          backgroundColor: Colors.green, colorText: Colors.white);
      addFavor.add(superNewUser);
      _firebaseFirestore.collection('userCollection').doc(currentUser).update({
        'favor': FieldValue.arrayUnion(addFavor),
      }).whenComplete(() {
        _firebaseFirestore
            .collection('userCollection')
            .doc(currentUser)
            .collection('favorites')
            .doc(superNewUser)
            .set({
          'about': currentFavorUser.data()['about'],
          'age': currentFavorUser.data()['age'],
          'country': currentFavorUser.data()['country'],
          'countryCode': currentFavorUser.data()['countryCode'],
          'email': currentFavorUser.data()['email'],
          'gender': currentFavorUser.data()['gender'],
          'id': currentFavorUser.data()['id'],
          'name': currentFavorUser.data()['name'],
          'ownerFavor': currentUser,
          'phoneNumber': currentFavorUser.data()['phoneNumber'],
          'urlAvatar': currentFavorUser.data()['urlAvatar'],
        });
      }).whenComplete(() {
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
    getCurrentFavorUser();
    getPath();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.fromMapGetBack);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Профиль'),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
          if(widget.fromMapGetBack == true){
            Get.back();

          }else{
            Get.offAll(Home());
          }

        },),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileUserWidgetCommon(
              userId: Get.arguments.toString(),
            ),
            PhotoAlbumWidgetCommon(
              userId: Get.arguments.toString(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  color: Colors.black45,
                  child: buttonEnabled == true
                      ? Text(
                          'Отправить сообщение',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )
                      : SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator()),
                  onPressed: () {
                    print('1111${widget.reciverName}');
                    putUserToFavor();

                    var data = Get.to(
                      ChatRoom(
                        resiverName: widget.reciverName,
                        resiverId: superNewUser,
                        senderId: currentUser,
                        senderName: widget.senderName,
                        fromWhere: 1,
                      ),
                    ).then((value) {
                      setState(() {

                      });
                    });
                  },
                ),
              ),
            ),
            favorStatus.read('$superNewUser') == true
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        color: Colors.black45,
                        child: buttonEnabled == true
                            ? Text(
                                'Убрать из избранного',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )
                            : SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator()),
                        onPressed: () {
                          deleteContact();
                        },
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        color: Colors.black45,
                        child: buttonEnabled == true
                            ? Text(
                                'Добавить в избранное',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )
                            : SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator()),
                        onPressed: () {
                          addToFavor();
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
