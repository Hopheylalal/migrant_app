
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:migrant_app/common/constants.dart';
import 'package:migrant_app/controllers/data_controller.dart';

class MessageController extends GetxService{

  FirebaseAuth _auth = FirebaseAuth.instance;
  DataController _dataController = Get.put(DataController());

  RxInt messageCount = RxInt();
  String userUid;

  RxInt messageCount2 = RxInt();


  getCountMessage(data){
    messageCount2.value = data;
  }



  getCurrentUser()async{
    final user = _auth.currentUser?.uid;
    userUid = user;
  }

  setGeoLoc(){
    FirebaseFirestore.instance.collection('userCollection').doc(userUid).update({
      'geoLoc' : GeoPoint(_dataController.myLocation2.latitude, _dataController.myLocation2.latitude),
    }).catchError((e){
      print(e.message);
    });
  }

  getMessagesFromFireStore() async {
    print('it is alive');
    final chatIds = [];
    final chatList = [];

    final msgArrFb = await FirebaseFirestore.instance
        .collection('chats')
        .where('convers', arrayContains: userUid)
        .get()
        .then((val) => val.docs);

    msgArrFb.forEach((element) {
      chatIds.add(element.id);
    });

    for (int i = 0; i < chatIds.length; i++) {
      var ff = await FirebaseFirestore.instance
          .collection("chats")
          .doc(chatIds[i])
          .collection("messages")
          .get();
      var fff = ff.docs.where((element) => element.data()['$userUid'] == true);
      chatList.addAll(fff.toList());


    }


    messageCount.value = chatList.length;
    print(chatList.length);
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getCurrentUser();
    getMessagesFromFireStore();
  }



}