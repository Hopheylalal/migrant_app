import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:migrant_app/common/constants.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:migrant_app/main.dart';
import 'package:migrant_app/screens/edit_profile.dart';
import 'package:migrant_app/widgets/photo_album.dart';
import 'package:migrant_app/widgets/profile_user_widget.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  DataController _dataController = Get.put(DataController());
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String userUid;

  String content;

  bool buttonEnabled = true;
  bool buttonEnabled2 = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
  }

  getUserUid() {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      userUid = userIdFuture;
    });
  }

  void signOut() async {
    try {
      _auth.signOut();
      GoogleSignIn().signOut();
      print('You are sign out');
      print(_auth.currentUser);

    } catch (e) {
      Get.snackbar('Ошибка', e.message, snackPosition: SnackPosition.TOP);
    }
  }

  void addTwit(){
    try{
    String twitId = DateTime.now().millisecondsSinceEpoch.toString();
    _firebaseFirestore.collection('twits').doc(twitId).set({
      'ownerId' : userUid,
      'content' : content,
      'createDate' : FieldValue.serverTimestamp(),
      'name' : _dataController.userDataController['name'],
      'urlAvatar' : _dataController.userDataController['urlAvatar'],
      'twitId' : twitId,
      'countryCode' : _dataController.userDataController['countryCode'],
    }).whenComplete(() {
      Get.snackbar('Оповещение', 'Ваше сообщение отправленно',backgroundColor: Colors.lightGreen, colorText: Colors.white);
    });
  }catch(e){
      Get.snackbar('Ошибка', 'Попробуйте позже',backgroundColor: GetSnackbarConst.getSnackErrorBack,colorText: GetSnackbarConst.getSnackErrorText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Text('Мой профиль'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(),
                ),
              ).then((value) {
                setState(() {});
              });
            },
          ),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.signOutAlt),
            onPressed: () {
              signOut();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileUserWidget(),
            PhotoAlbumWidget(userId: userUid,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 30),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  color: Colors.black45,
                  child: buttonEnabled == true
                      ? Text(
                    'Добавить запись',
                    style:
                    TextStyle(color: Colors.white, fontSize: 18),
                  )
                      : SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator()),
                  onPressed: () {
                    Get.bottomSheet(
                      SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Text('Введите сообщение',style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  enableSuggestions: true,
                                  textCapitalization:
                                  TextCapitalization.sentences,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 4,
                                  maxLines: 4,
                                  onChanged: (val) {
                                    content = val;
                                  },
                                    decoration: InputDecoration(
                                      hintText: 'Начните набирать ваше сообщение',
                                      border: new OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(30.0),
                                        ),
                                      ),
                                    ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0)),
                                    color: Colors.black45,
                                    child: buttonEnabled2 == true
                                        ? Text(
                                      'Отправить',
                                      style:
                                      TextStyle(color: Colors.white, fontSize: 18),
                                    )
                                        : SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator()),
                                    onPressed: () {
                                      if(content == null || content == ''){
                                        Get.snackbar('Внимание', 'Введите сообщение',backgroundColor:Colors.blueAccent,colorText: GetSnackbarConst.getSnackErrorText);
                                      }else{
                                        addTwit();
                                        content = null;
                                        Get.back();

                                      }

                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    );
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
