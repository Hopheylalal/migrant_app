import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:get_storage/get_storage.dart';
import 'package:migrant_app/screens/image_viewer.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shimmer/shimmer.dart';

class PhotoAlbumWidgetCommon extends StatefulWidget {
  final userId;

  const PhotoAlbumWidgetCommon({Key key, @required this.userId}) : super(key: key);

  @override
  _PhotoAlbumWidgetCommonState createState() => _PhotoAlbumWidgetCommonState();
}

class _PhotoAlbumWidgetCommonState extends State<PhotoAlbumWidgetCommon> {
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  List<String> _imageUrlList = [];
  GetStorage _userId = GetStorage();

  bool photoEnable = false;

  Future<void> loadAssets() async {
    setState(() {
      photoEnable = true;
    });
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';


  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userId.write('usrIdCommonPhoto', widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [

          Expanded(
            child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('userCollection')
                    .doc(_userId.read('usrIdCommonPhoto'))
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
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'Фото не загружены',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
                            List<String> phList = [];
                            phList.add(photos);
                            return GestureDetector(
                              onTap: (){
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
