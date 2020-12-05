import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:migrant_app/chat/widgets/messages_widget.dart';
import 'package:migrant_app/chat/widgets/new_message_widget.dart';
import 'package:migrant_app/common_profile/coomon_profile.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:migrant_app/controllers/message_controller.dart';

import '../home.dart';

class ChatRoom extends StatefulWidget {
  final resiverName;
  final resiverId;
  final senderName;
  final senderId;
  final int fromWhere;

  const ChatRoom({
    Key key,
    this.resiverName,
    this.resiverId,
    this.senderName,
    this.senderId, this.fromWhere,
  }) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  FirebaseFirestore _firebase = FirebaseFirestore.instance;


  var hashChatID;

  getPath() {
    String strUser;
    var chatId = widget.resiverId.hashCode + widget.senderId.hashCode;
    hashChatID = chatId;
  }

  clearNewMessage() async {
    final result = await _firebase
        .collection('chats')
        .doc(hashChatID.toString())
        .collection('messages')
        .get();
    final List newMessageList = result.docs;

    newMessageList.forEach((element) {
      _firebase.collection('chats').doc(hashChatID.toString()).collection('messages').doc(element.id).update({
        '${widget.senderId}' : false,
      });
    });
  }

  DataController _dataController = Get.put(DataController());

  FirebaseAuth _auth = FirebaseAuth.instance;
  String userUid;

  MessageController _mc = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPath();
  }

  @override
  Widget build(BuildContext context) {
    print(Get.size.height);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
          clearNewMessage();
          _mc.getMessagesFromFireStore();
          Get.offAll(Home(currentIndex: 3,));
        },),
        title: Text(
          '${widget.resiverName}',
          overflow: TextOverflow.fade,
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              if(widget.fromWhere != 1){
                Get.to(ProfileCommon(reciverName: widget.resiverName,senderName: widget.senderName,), arguments: widget.resiverId);

              }else{
                Get.back();
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('userCollection')
                      .doc(widget.resiverId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Неизвестная ошибка'));
                    }
                    if (snapshot.hasData) {
                      _dataController.putUrlAvatar(snapshot.data['urlAvatar']);
                      return CircleAvatar(
                        radius: 23,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data['urlAvatar'],
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      );
                    }
                    return SizedBox();
                  }),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MessagesWidget(
                idUser: widget.senderId, resiverId: widget.resiverId),
          ),
          NewMessageWidget(
            resiverId: widget.resiverId,
            senderId: widget.senderId,
            resiverName: widget.resiverName,
            senderName: widget.senderName,
          ),
        ],
      ),
    );
  }
}
