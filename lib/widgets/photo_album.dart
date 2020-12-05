import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:migrant_app/screens/image_viewer.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shimmer/shimmer.dart';

class PhotoAlbumWidget extends StatefulWidget {
  final userId;

  const PhotoAlbumWidget({Key key, @required this.userId}) : super(key: key);

  @override
  _PhotoAlbumWidgetState createState() => _PhotoAlbumWidgetState();
}

class _PhotoAlbumWidgetState extends State<PhotoAlbumWidget> {
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  List<String> _imageUrlList = [];

  bool photoEnable = false;

  Future<void> loadAssets() async {
    setState(() {
      photoEnable = true;
    });
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {

      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          startInAllView: true,
          allViewTitle: 'Выберете фото',
          actionBarColor: "#f2255d",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    for (Asset i in resultList) {
      saveImage(i).whenComplete(() => print(_imageUrlList.length));
    }
    setState(() {
      images = resultList;
      _error = error;
    });
  }

  Future saveImage(Asset asset) async {

    ByteData byteData =
        await asset.getByteData(); // requestOriginal is being deprecated
    List<int> imageData = byteData.buffer.asUint8List();
    Random random = new Random();
    int randomNumber = random.nextInt(100000);

    StorageReference ref = FirebaseStorage().ref().child(
        '${widget.userId}/${Path.basename("$randomNumber.jpg")}'); // To be aligned with the latest firebase API(4.0)
    StorageUploadTask uploadTask =
        ref.putData(imageData, StorageMetadata(contentType: 'image/jpeg'));

    await uploadTask.onComplete.whenComplete(() {
      ref.getDownloadURL().then((fileUrl) {
        _imageUrlList.add(fileUrl.toString());
      }).whenComplete(() async {
        FirebaseFirestore.instance
            .collection('userCollection')
            .doc(widget.userId)
            .update({'userPhoto': FieldValue.arrayUnion(_imageUrlList)});
      }).whenComplete(() {

        setState(() {
          photoEnable = false;

          _imageUrlList.clear();
        });
      });
    });
  }

  void showPicOptionsDialog(phList) {
    Get.defaultDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlatButton.icon(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('userCollection')
                  .doc(widget.userId)
                  .update({
                'userPhoto': FieldValue.arrayRemove(phList)
              }).whenComplete(() {
                setState(() {});
              });
              Get.back();
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
      title: 'Удалить фото?',
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xfff0f0f0),
      child: Row(
        children: [
          IconButton(
              icon: Icon(
                Icons.add_circle,

              ),
              onPressed: () {
                loadAssets().whenComplete(() {
                  setState(() {
                    photoEnable = true;
                  });
                });
              }),
          Expanded(
            child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('userCollection')
                    .doc(widget.userId)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LinearProgressIndicator();
                  }
                  if (snapshot.hasData) {
                    List userImageUrl = snapshot.data.data()['userPhoto']?? [];
                    if (userImageUrl.length == 0 && photoEnable == false) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 33),
                        child: Text(
                          'Загрузите ваши фотографии',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    } else {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: userImageUrl.map<Widget>((photos) {
                            List phList = [];
                            phList.add(photos);
                            return GestureDetector(
                              onLongPress: () {
                                showPicOptionsDialog(phList);
                              },
                              onTap: () {

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewerWidget(
                                      url: photos,
                                      photos: userImageUrl,
                                      startPage: userImageUrl.indexOf(photos),

                                    ),
                                  ),
                                );

                              },


                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10,
                                    left: 0,
                                    right: 10,
                                    bottom: 10),
                                child: CachedNetworkImage(
                                  imageUrl: photos,
                                  placeholder: (context, url) => SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Shimmer.fromColors(
                                        child: Image.asset(
                                            'assets/img/imgplaseholder.png'),
                                        baseColor: Colors.grey[300],
                                        highlightColor: Colors.grey[100]),

                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }
                  }
                  return SizedBox();
                }),
          )
        ],
      ),
    );
  }
}
