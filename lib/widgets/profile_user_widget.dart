import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:migrant_app/common/constants.dart';
import 'package:migrant_app/controllers/data_controller.dart';

class ProfileUserWidget extends StatefulWidget {
  @override
  _ProfileUserWidgetState createState() => _ProfileUserWidgetState();
}

class _ProfileUserWidgetState extends State<ProfileUserWidget> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  DataController _dataController = Get.put(DataController());

  String userUid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
  }

  getUserUid() async {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      userUid = userIdFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('userCollection')
          .doc(userUid)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {

          Get.snackbar('Ошибка', 'Попробуйте позже',
              backgroundColor: GetSnackbarConst.getSnackErrorBack,
              colorText: GetSnackbarConst.getSnackErrorText);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LinearProgressIndicator();
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data.data() != null) {
          Map<String, dynamic> userData = snapshot.data.data();
          _dataController.userDataControllerUpdate(userData);
          String countryName = userData['country'];
          String about = userData['about'];
          return Card(
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
                        imageUrl: userData['urlAvatar'],
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
                        Text(
                          '${userData['name']}, ${userData['age'].round()}',
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 0),
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: Flag('${userData['countryCode']}'),
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            countryName.length > 24
                                ? Expanded(
                                    child: Text(
                                      '${userData['country']}',
                                      overflow: TextOverflow.fade,
                                    ),
                                  )
                                : Text(
                                    '${userData['country']}',
                                    overflow: TextOverflow.fade,
                                  ),


                          ],
                        ),
                        Text(
                          'О себе',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, right: 10),
                          child: about == null
                              ? Text(
                                  'Краткая информация о пользователе',
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                )
                              : Text(
                                  '${userData['about']}',
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          Text('Err');
        }
        return Container(child: LinearProgressIndicator());
      },
    );
  }
}
