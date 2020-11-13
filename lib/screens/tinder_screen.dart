import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:migrant_app/widgets/tinder_container_widget.dart';
import 'package:tcard/tcard.dart';

class TinderScreen extends StatefulWidget {
  @override
  _TinderScreenState createState() => _TinderScreenState();
}

class _TinderScreenState extends State<TinderScreen> {
  String userUid;
  String favorId;

  GetStorage favorStatus = GetStorage();

  TCardController _tCardController = TCardController();
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

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
      
      body: SafeArea(
        child: Center(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('userCollection')
                  .snapshots(),
              builder:
                  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasData) {
                  List cards = snapshot.data.docs;
                  List favorInCards = [];
                  cards.forEach((element) {
                    if (element['id'] == userUid) {
                      favorInCards.addAll(element['favor']);
                    }
                  });

                  return TCard(
                    controller: _tCardController,
                    onForward: (int, info) {
                      if (info.direction == SwipDirection.Left) {
                        String useIdToCard = cards[int - 1]['id'];
                        List addUserIdToFavor = [];
                        addUserIdToFavor.add(useIdToCard);

                        print(favorInCards);
                        print(useIdToCard);

                        if (favorInCards.contains(useIdToCard)) {
                          Get.snackbar(
                              'Оповещение', 'Пользователь уже был добавлен ранее',
                              backgroundColor: Colors.orange,
                              colorText: Colors.white);
                        } else {
                          Get.snackbar(
                              'Оповещение', 'Пользователь добавлен в избранное',
                              backgroundColor: Colors.green,
                              colorText: Colors.white);
                          _firebaseFirestore
                              .collection('userCollection')
                              .doc(userUid)
                              .update({
                            'favor': FieldValue.arrayUnion(addUserIdToFavor),
                          }).whenComplete(() {
                            _firebaseFirestore
                                .collection('userCollection')
                                .doc(userUid).collection('favorites').doc(cards[int - 1]['id'])
                                .set({
                              'id': cards[int - 1]['id'],
                              'about': cards[int - 1]['about'],
                              'age': cards[int - 1]['age'],
                              'country': cards[int - 1]['country'],
                              'countryCode': cards[int - 1]['countryCode'],
                              'email': cards[int - 1]['email'],
                              'gender': cards[int - 1]['gender'],
                              'name': cards[int - 1]['name'],
                              'phoneNumber': cards[int - 1]['phoneNumber'],
                              'urlAvatar': cards[int - 1]['urlAvatar'],
                              'ownerFavor' : userUid,

                            });
                            favorStatus.write('${cards[int - 1]['id']}', true);
                          }).catchError(
                            (err) {
                              Get.snackbar('Ошибка', 'Попробуйте позже',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white);
                            },
                          );
                        }
                      }
                    },
                    onEnd: () {
                      _tCardController.reset();
                    },
                    size: Size(360, 500),
                    cards: cards.map<Widget>((card) {
                      return TinderContainer(
                        imgUrl: card['urlAvatar'],
                        name: card['name'],
                        age: card['age'].round().toString(),
                        country: card['country'],
                        countryCode: card['countryCode'],
                        id: card['id'],
                      );
                    }).toList(),
                  );
                } else {
                  return SizedBox();
                }
              }),
        ),
      ),
    );
  }
}
