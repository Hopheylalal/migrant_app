import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_picker/country.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:migrant_app/chat/chat_room.dart';
import 'package:badges/badges.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:migrant_app/controllers/message_controller.dart';

class MessageWidget extends StatefulWidget {
  final imgAvatar;
  final name;
  final age;
  final country;
  final countryCode;
  final userId;
  final currentUserId;
  final currentUserName;

  const MessageWidget(
      {Key key,
      this.imgAvatar,
      this.name,
      this.age,
      this.country,
      this.countryCode,
      this.userId,
      this.currentUserId,
      this.currentUserName})
      : super(key: key);

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  void deleteContact() async {
    FirebaseFirestore _firebase = FirebaseFirestore.instance;


    MessageController _mc = Get.find();

    List delToArray = [];
    delToArray.add(widget.userId);
    _firebase.collection('userCollection').doc(widget.currentUserId).update({
      'favor': FieldValue.arrayRemove(delToArray),
    }).whenComplete(() {
      _firebase
          .collection('userCollection')
          .doc(widget.currentUserId)
          .collection('favorites')
          .doc(widget.userId)
          .delete();
    }).whenComplete(() {
      favorStatus.write('${widget.userId}', false);
      Get.back();
    }).catchError((err) {
      print(err);
    });
  }

  FirebaseFirestore _firebase = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot currentFavorUser;
  DataController _dataController = Get.put(DataController());
  String currentUser;

  getCurrentFavorUser() async {
    currentFavorUser = await _firebase
        .collection('userCollection')
        .doc(widget.currentUserId)
        .get();
  }

  getUserUid() {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      currentUser = userIdFuture;
    });
  }

  GetStorage favorStatus = GetStorage();
  List userToFav = [];

  putUserToFavor() async {
    userToFav.add(widget.currentUserId);
    favorStatus.write('${widget.userId}', true);

    FirebaseFirestore.instance
        .collection('userCollection')
        .doc(widget.userId)
        .update({'favor': FieldValue.arrayUnion(userToFav)}).whenComplete(() {
      _firebase
          .collection('userCollection')
          .doc(widget.userId)
          .collection('favorites')
          .doc(widget.currentUserId)
          .set({
        'about': currentFavorUser.data()['about'],
        'age': currentFavorUser.data()['age'],
        'country': currentFavorUser.data()['country'],
        'countryCode': currentFavorUser.data()['countryCode'],
        'email': currentFavorUser.data()['email'],
        'gender': currentFavorUser.data()['gender'],
        'id': currentFavorUser.data()['id'],
        'name': currentFavorUser.data()['name'],
        'ownerFavor': widget.currentUserId,
        'phoneNumber': currentFavorUser.data()['phoneNumber'],
        'urlAvatar': currentFavorUser.data()['urlAvatar'],
      });
    });
  }

  var hashChatID;

  getPath() {
    String strUser;
    var chatId = widget.userId.hashCode + widget.currentUserId.hashCode;
    hashChatID = chatId;
  }

  clearNewMessage() async {
    final result = await _firebase
        .collection('chats')
        .doc(hashChatID.toString())
        .collection('messages')
        .get();
    final List newMessageList = result.docs;

    print(newMessageList.length);
    print(newMessageList);
    newMessageList.forEach((element) {
      _firebase
          .collection('chats')
          .doc(hashChatID.toString())
          .collection('messages')
          .doc(element.id)
          .update({
        '${widget.currentUserId}': false,
      });
    });
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
    return InkWell(
      onTap: () {
        putUserToFavor();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoom(
              resiverName: widget.name,
              resiverId: widget.userId,
              senderId: widget.currentUserId,
              senderName: widget.currentUserName,
            ),
          ),
        ).then((value) {
          setState(() {});
        });
        clearNewMessage();
      },
      onLongPress: () {
        Get.defaultDialog(
          title: 'Удалить из избранного?',
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton.icon(
                onPressed: () {
                  deleteContact();
                },
                label: Text('Удалить'),
                icon: Icon(Icons.delete),
              ),
              SizedBox(
                width: 10,
              ),
              FlatButton.icon(
                onPressed: () {
                  Get.back();
                },
                label: Text('Отмена'),
                icon: Icon(Icons.close),
              ),
            ],
          ),
        );
      },
      child: Card(
        color: Color(0xfff0f0f0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircleAvatar(
                radius: 40,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.imgAvatar,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.name}, ${widget.age.round()}',
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: Flag('${widget.countryCode}'),
                              ),
                            ),
                            widget.country.length > 24
                                ? Expanded(
                                    child: Text(
                                      '${widget.country}',
                                      overflow: TextOverflow.fade,
                                    ),
                                  )
                                : Text(
                                    '${widget.country}',
                                    overflow: TextOverflow.fade,
                                  ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('chats')
                                  .doc(hashChatID.toString())
                                  .collection('messages')
                                  .where(widget.currentUserId, isEqualTo: true)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox();
                                }
                                if (snapshot.hasData) {
                                  List docs = snapshot.data.docs;

                                  return docs == null || docs.length == 0
                                      ? SizedBox()
                                      : Badge(
                                          badgeContent: Text(
                                            '${docs.length}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        );
                                }
                                return SizedBox();
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
