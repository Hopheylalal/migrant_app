import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:migrant_app/common/constants.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:migrant_app/controllers/data_controller2.dart';
import 'package:migrant_app/models/latlng_model.dart';
import 'package:migrant_app/screens/map_screen.dart';
import 'package:migrant_app/widgets/filter_widget.dart';
import 'package:migrant_app/widgets/user_widget.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as map;
import 'dart:ui' as ui;

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  GetStorage filterSave = GetStorage();
  DataController _dataController = Get.put(DataController());
  DataController2 _dataController2 = Get.put(DataController2());
  FirebaseAuth _auth = FirebaseAuth.instance;

  YYDialog yYDialogDemo(BuildContext context) {
    return YYDialog().build(context)
      ..width = Get.height
      ..height = 300
      ..gravity = Gravity.top
      ..margin = Get.size.height >= 896
          ? EdgeInsets.symmetric(vertical: 100)
          : EdgeInsets.symmetric(vertical: 80)
      ..widget(
        Padding(
          padding: EdgeInsets.all(0.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilterWidget(),
          ),
        ),
      )
      ..show();
  }

  String currentUser;
  map.LatLng userSafeLocation;

  getMyCoordsLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium).catchError((err){
          print(err);
    });
    map.LatLng _latLng = map.LatLng(position.latitude, position.longitude);
    userSafeLocation = _latLng;
  }

  getUserUid() {
    final userIdFuture = _auth.currentUser.uid;

    currentUser = userIdFuture;
  }

  // LatLng myCurrentCoords;
  //
  // getMyCoords() async {
  //   final result = await FirebaseFirestore.instance
  //       .collection('userCollection')
  //       .doc(currentUser)
  //       .get();
  //   GeoPoint myCoords = result.data()['geoLoc'];
  //   final lat = myCoords.latitude;
  //   final lng = myCoords.longitude;
  //
  //   LatLng _latLng = LatLng(lat, lng);
  //
  //   myCurrentCoords = _latLng;
  //
  //   filterSave.write('Lat', _latLng.latitude);
  //   filterSave.write('Lng', _latLng.longitude);
  // }

  Future<Uint8List> getBytesFromAsset(String path) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: pixelRatio.round() * 30);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Set<map.Marker> users = {};

  getMarkers() async {
    List usersGenderList = [];

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('userCollection').get();

      users.clear();

      setState(() {});

      snapshot.docs.forEach((element) {
        if (element['gender'] == _dataController.gender.value &&
            element['gender'] != 3) {
          usersGenderList.add(element);
        } else if (element['gender'] == 3 ||
            _dataController.gender.value == 3) {
          usersGenderList.add(element);
        }
      });

      for (var n in usersGenderList) {
        if (CountryCodes.cntrCode.contains(n.data()['countryCode'])) {
          final Uint8List markerIcon = await getBytesFromAsset(
              'assets/flags/${n.data()['countryCode']}.png');
          _dataController2.userMarkersSet.add(
            map.Marker(
              markerId: map.MarkerId(n.id),
              infoWindow: map.InfoWindow(title: '${n.data()['name']}'),
              position: map.LatLng(
                  n.data()['geoLoc'].latitude, n.data()['geoLoc'].longitude),
              icon: map.BitmapDescriptor.fromBytes(markerIcon),
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => Wrap(children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: SingleChildScrollView(
                        child: SizedBox(
                          height: Get.height * 0.8,
                          child: Container(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ]),
                );
              },
            ),
          );
        } else {
          final Uint8List markerIcon =
              await getBytesFromAsset('assets/flags/none.png');
          _dataController2.userMarkersSet.add(
            map.Marker(
              markerId: map.MarkerId(n.id),
              infoWindow: map.InfoWindow(title: '${n.data()['name']}'),
              position: map.LatLng(
                  n.data()['geoLoc'].latitude, n.data()['geoLoc'].longitude),
              icon: map.BitmapDescriptor.fromBytes(markerIcon),
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => Wrap(children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: SingleChildScrollView(
                        child: SizedBox(
                          height: Get.height * 0.8,
                          child: Container(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ]),
                );
              },
            ),
          );
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
    // getMyCoords();
    getMyCoordsLocator();
    getMyCoordsLocator();
    getMarkers();
  }

  @override
  Widget build(BuildContext context) {
    _dataController.distanceUsersListGetBuilder.clear();
    return Scaffold(
      appBar: AppBar(
        title: Text('Поиск'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.map),
              onPressed: () {
                Get.to(MapScreen());
              }),
          IconButton(
              icon: Icon(Icons.filter_list_rounded),
              onPressed: () {
                yYDialogDemo(context);
              })
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('userCollection')
            .where('id', isNotEqualTo: currentUser)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LinearProgressIndicator();
          }
          if (snapshot.hasData) {
            _dataController.distanceUsersListGetBuilder.clear();
            List users = snapshot.data.docs;
            List result = [];
            List resultGender = [];

            users.forEach((element) {
              if (element['gender'] == _dataController.gender.value &&
                  element['gender'] != 3) {
                resultGender.add(element);
              } else if (element['gender'] == 3 ||
                  _dataController.gender.value == 3) {
                resultGender.add(element);
              }
            });

            resultGender.forEach((element) {
              if (element['age'] <= _dataController.maxAge.value &&
                  element['age'] >= _dataController.minAge.value) {
                result.add(element);
              }
            });

            result.forEach((element) async {
              GeoPoint fbUserGeo = element['geoLoc'];

              var lat = fbUserGeo.latitude;
              var lng = fbUserGeo.longitude;
              LatLng latLng = new LatLng(lat, lng);
              LatLng latLng2 = new LatLng(
                  _dataController?.myLocation?.latitude,
                  _dataController?.myLocation?.longitude);
              LatLng latLng3 = new LatLng(
                  _dataController.myLocation2.latitude,
                  _dataController.myLocation2.longitude);

              var distanceBetweenPoints;
              try {
                distanceBetweenPoints =
                    SphericalUtil.computeDistanceBetween(latLng, latLng2);
              } catch (e) {
                distanceBetweenPoints =
                    SphericalUtil.computeDistanceBetween(latLng, latLng3);
              }
              print(distanceBetweenPoints);

              LatLngModel _ltLng =
                  LatLngModel(doc: element, distance: distanceBetweenPoints);

              if (_ltLng.distance <= _dataController.distanceUser.value) {
                _dataController.distanceUsersListGetBuilder.add(_ltLng.doc);
              }
            });


            // return Column(
            //   children: _dataController.distanceUsersListGetBuilder
            //       .map<Widget>(
            //         (value) => UserWidget(
            //           imgAvatar: value['urlAvatar'],
            //           name: value['name'],
            //           age: value['age'],
            //           countryCode: value['countryCode'],
            //           country: value['country'],
            //           userId: value['id'],
            //         ),
            //       )
            //       .toList(),
            // );


           return ListView.builder(
              itemCount: _dataController.distanceUsersListGetBuilder.length,
              itemBuilder: (BuildContext context, int index) {
                return UserWidget(
                  imgAvatar: _dataController
                      .distanceUsersListGetBuilder[index]['urlAvatar'],
                  name: _dataController.distanceUsersListGetBuilder[index]
                      ['name'],
                  age: _dataController.distanceUsersListGetBuilder[index]
                      ['age'],
                  countryCode: _dataController
                      .distanceUsersListGetBuilder[index]['countryCode'],
                  country: _dataController.distanceUsersListGetBuilder[index]
                      ['country'],
                  userId: _dataController.distanceUsersListGetBuilder[index]
                      ['id'],
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
