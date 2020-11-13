import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:migrant_app/chat/models/message.dart';
import 'package:migrant_app/chat/widgets/chat_message_widget.dart';

class MessagesWidget extends StatefulWidget {
  final String idUser;
  final String resiverId;
  final String reciverAvatar;
  final String senderAvatar;

  const MessagesWidget({
    @required this.idUser,
    Key key,
    this.resiverId,
    this.reciverAvatar,
    this.senderAvatar,
  }) : super(key: key);

  @override
  _MessagesWidgetState createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget> {
  List<String> idsArray = [];
  FirebaseAuth _auth = FirebaseAuth.instance;

  bool isMe;
  String currentUser;

  getTreuChat(){
   var isMe2;
   if(currentUser == widget.resiverId){
     isMe2 = true;
   }else if (currentUser == widget.idUser){
     isMe2 = false;
   }
   isMe = isMe2;
  }

  getUserUid() {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      currentUser = userIdFuture;
    });
  }

  var chatHash;
  getHash(){
    var chatId = widget.idUser.hashCode + widget.resiverId.hashCode;
    chatHash = chatId;
  }


  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
    idsArray.add(widget.resiverId);
    idsArray.add(widget.idUser);
    print(idsArray);
    getHash();
    getTreuChat();

  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(chatHash.toString())
            .collection('messages').orderBy('createDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return buildText('Something Went Wrong Try later');
              } else {
                final messages = snapshot.data.docs;
                print(messages);
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ChatMessageWidget(
                      message: message['message'],
                      isMe: currentUser == message['sender'],
                      senderUrl: widget.resiverId,
                    );
                  },
                );
              }
          }
        },
      );

  Widget buildText(text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24),
        ),
      );
}
