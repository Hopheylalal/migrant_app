import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class NewMessageWidget extends StatefulWidget {
  final resiverName;
  final resiverId;
  final resiverAvatar;
  final senderName;
  final senderId;
  final senderAvatar;

  const NewMessageWidget(
      {Key key,
      this.resiverName,
      this.resiverId,
      this.resiverAvatar,
      this.senderName,
      this.senderId,
      this.senderAvatar})
      : super(key: key);

  @override
  _NewMessageWidgetState createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String currentUser;

  bool inProcess = false;
  bool isLoading = false;

  File cropedImage;

  String currentUserName;

  getUserName()async{
    final result = await FirebaseFirestore.instance.collection('userCollection').doc(currentUser).get();
    currentUserName = result.data()['name'];
  }

  getUserUid() {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      currentUser = userIdFuture;
    });
  }

  var hashChatID;

  File pickedImage;
  void loadPicker(ImageSource source) async {
    setState(() {
      inProcess = true;
      isLoading = true;
    });
    final imagePicker = ImagePicker();
    PickedFile picked = await imagePicker.getImage(source: source);
    File readyImage = picked == null ? null : File(picked?.path);
    if (picked != null) {
      pickedImage = File(picked.path);
      addImageToFirebase();

    } else {
      setState(() {
        inProcess = false;
      });
    }
  }

  void showPicOptionsDialog() {
    Get.defaultDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlatButton.icon(
            onPressed: () {
              loadPicker(ImageSource.gallery);
              Get.back();
            },
            label: Text('Галерея'),
            icon: FaIcon(FontAwesomeIcons.images),
          ),
          SizedBox(
            width: 10,
          ),
          FlatButton.icon(
            onPressed: () {
              loadPicker(ImageSource.camera);
              Get.back();
            },
            label: Text('Камера'),
            icon: FaIcon(FontAwesomeIcons.camera),
          ),
        ],
      ),
      textCancel: 'Отмена',
      title: '',
      onCancel: () {
        setState(() {
          inProcess = false;
        });
      },
    );
  }

  Future addImageToFirebase() async {
    final userId = FirebaseAuth.instance.currentUser.uid;
    try {
      StorageReference reference = FirebaseStorage.instance
          .ref()
          .child('/images/$userId/avatar/${DateTime.now().toIso8601String()}');

      StorageUploadTask uploadTask = reference.putFile(pickedImage);

      StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

      String urlImg = await downloadUrl.ref.getDownloadURL();

      _firebaseFirestore
          .collection('chats')
          .doc(hashChatID.toString())
          .collection('messages')
          .doc()
          .set({
        'message': urlImg,
        'sender': widget.senderId,
        'resiver': widget.resiverId,
        'createDate': FieldValue.serverTimestamp(),
        'resiverName': widget.resiverName,
        'senderName': currentUserName,
        'resiverAvatr': widget.resiverAvatar,
        'senderAvatar': widget.senderAvatar,
        '${widget.senderId}' : false,
        '${widget.resiverId}' : true,
      }).whenComplete(() {

        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {

      setState(() {
        inProcess = false;
      });
    }
  }

  getPath() {
    String strUser;
    var chatId = widget.senderId.hashCode + widget.resiverId.hashCode;
    hashChatID = chatId;
  }

  final _controller = TextEditingController();
  String message = '';

  File image;
  final picker = ImagePicker();

  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void sendMessage() async {
    FocusScope.of(context).unfocus();

    if(_controller.text.isNotEmpty){
      await _firebaseFirestore
          .collection('chats')
          .doc(hashChatID.toString())
          .set({
        'convers': [widget.senderId, widget.resiverId],
      }).whenComplete(() {
        _firebaseFirestore
            .collection('chats')
            .doc(hashChatID.toString())
            .collection('messages')
            .doc()
            .set({
          'message': message,
          'sender': widget.senderId,
          'resiver': widget.resiverId,
          'createDate': FieldValue.serverTimestamp(),
          'resiverName': widget.resiverName,
          'senderName': currentUserName,
          'resiverAvatr': widget.resiverAvatar,
          'senderAvatar': widget.senderAvatar,
          '${widget.senderId}' : false,
          '${widget.resiverId}' : true,
        });
      });
      _controller.clear();
    }else{
      print('Controller is empty!!!');
    }

    // await FirebaseApi.uploadMessage(widget.idUser, message);



  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
    getPath();
    getUserName();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  labelText: 'Напишите сообщение',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 0),
                    gapPadding: 10,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onChanged: (value) => setState(() {
                  message = value;
                }),
              ),
            ),
            SizedBox(width: 5),
            GestureDetector(
              onTap: showPicOptionsDialog,
              child: Icon(Icons.image, color: Colors.black54),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: message.trim().isEmpty && _controller.text.isEmpty ? null : sendMessage,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      );
}
