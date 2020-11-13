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

  const TwitWidget(
      {Key key,
      this.urlAvatar,
      this.createDate,
      this.name,
      this.content,
      this.countryCode,
      this.userId,
      this.twitId})
      : super(key: key);

  @override
  _TwitWidgetState createState() => _TwitWidgetState();
}

class _TwitWidgetState extends State<TwitWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userUid;

  getUserUid() {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      userUid = userIdFuture;
    });
  }

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
                    .delete().whenComplete(() => Get.back(),)
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(ProfileCommon(), arguments: widget.userId);
      },
      onLongPress: () {
        deleteMyTwit();
      },
      child: Card(
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
                            '${widget.name}',
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: Flag(widget.countryCode),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${DateFormat('dd-MM-yyyy').format(
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
