import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:migrant_app/common_profile/coomon_profile.dart';

class TwitWidget extends StatefulWidget {
  final urlAvatar;
  final Timestamp createDate;
  final name;
  final content;
  final countryCode;
  final userId;
  final twitId;
  final age;
  final country;

  const TwitWidget(
      {Key key,
      this.urlAvatar,
      this.createDate,
      this.name,
      this.content,
      this.countryCode,
      this.userId,
      this.twitId,
      this.age, this.country})
      : super(key: key);

  @override
  _TwitWidgetState createState() => _TwitWidgetState();
}

class _TwitWidgetState extends State<TwitWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userUid;
  int userAge;

  getUserUid() {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      userUid = userIdFuture;
    });
  }

  // getUserAge()async{
  //   final result = await FirebaseFirestore.instance.collection('userCollection').doc(widget.userId).get();
  //   var result2 = await result.data()['age'];
  //
  //
  // }

  deleteMyTwit() {
    if (widget.userId == userUid) {
      Get.defaultDialog(
        title: 'Удалить запись?',
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton.icon(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('twits')
                    .doc(widget.twitId)
                    .delete()
                    .whenComplete(
                      () => Get.back(),
                    )
                    .catchError((err) {
                  print(err);
                });
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
    } else {
      Get.snackbar('Внимание', 'Вы не можете удалять чужие записи',
          backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  // getUserAge()async{
  //    FirebaseFirestore.instance
  //       .collection('userCollection')
  //       .doc(widget.userId).get();
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
    // getUserAge();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(
            ProfileCommon(
              fromMapGetBack: true,
            ),
            arguments: widget.userId);
      },
      onLongPress: () {
        deleteMyTwit();
      },
      child: Card(
        color: Color(0xfff0f0f0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 30,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.urlAvatar,
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
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
                    ),
                    Text(
                      '${DateFormat('dd-MM-yyyy  HH:mm').format(
                        widget.createDate.toDate(),
                      )}',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.content,
                      style: TextStyle(fontSize: 15),
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
