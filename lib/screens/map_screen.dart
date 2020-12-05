import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:migrant_app/common/constants.dart';
import 'package:migrant_app/common_profile/coomon_profile.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:migrant_app/controllers/data_controller2.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String masterName;
  LatLng startLocation;
  LatLng startLocationError = LatLng(55.749711, 37.616806);
  final box = GetStorage();
  DataController _dataController = Get.put(DataController());
  DataController2 _dataController2 = Get.put(DataController2());
  FirebaseAuth _auth = FirebaseAuth.instance;






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
  String userUid;
  getUserUid()async{
    final result = _auth.currentUser.uid;
    userUid = result;
  }

  Future getMarkers(data) async {
    Set<Marker> usersListFn = {};
    try {

      for (var n in data) {
        if (CountryCodes.cntrCode.contains(n.data()['countryCode'])) {
          final Uint8List markerIcon = await getBytesFromAsset(
              'assets/flags/${n.data()['countryCode']}.png');
          usersListFn.add(
            Marker(
              markerId: MarkerId(n.id),
              infoWindow: InfoWindow(title: '${n.data()['name']}'),
              position: LatLng(
                  n.data()['geoLoc'].latitude, n.data()['geoLoc'].longitude),
              icon: BitmapDescriptor.fromBytes(markerIcon),
              onTap: () {
                Get.to(
                    ProfileCommon(
                      fromMapGetBack: true,
                      reciverName: n.data()['name'],
                    ),
                    arguments: n.data()['id']);
              },
            ),
          );
        } else {
          final Uint8List markerIcon =
          await getBytesFromAsset('assets/flags/none.png');
          usersListFn.add(
            Marker(
              markerId: MarkerId(n.id),
              infoWindow: InfoWindow(title: '${n.data()['name']}'),
              position: LatLng(
                  n.data()['geoLoc'].latitude, n.data()['geoLoc'].longitude),
              icon: BitmapDescriptor.fromBytes(markerIcon),
              onTap: () {
                Get.to(
                    ProfileCommon(
                      fromMapGetBack: true,
                      reciverName: n.data()['name'],
                    ),
                    arguments: n.data()['id']);
              },
            ),
          );
        }
      }
    } catch (e) {
      print(e);
    }
    return usersListFn;
  }

  Future getMyCoordsLocator()async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    LatLng _latLng = LatLng(position.latitude,position.longitude);
    _dataController.setLocation(_latLng,userUid);
    return _latLng;

  }

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
          child: Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            Get.back();
                          }),
                    ),
                    Text('ФИЛЬТР'),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            _dataController2.setMinAge(
                                _dataController2.ageControl.value.start);
                            _dataController2.setMaxAge(
                                _dataController2.ageControl.value.end);
                            _dataController2.setGender(_dataController2.gender.value);
                            setState(() {

                            });

                            Get.back();
                          }),
                    ),
                  ],
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('Меня интересуют'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text('Мужчины'),
                            Obx(
                              () => Radio(
                                value: 1,
                                groupValue: _dataController2.gender.value,
                                onChanged: ((val) {
                                  _dataController2.setGender(val);
                                }),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Column(
                          children: [
                            Text('Девушки'),
                            Obx(
                              () => Radio(
                                activeColor: Colors.pinkAccent,
                                value: 2,
                                groupValue: _dataController2.gender.value,
                                onChanged: ((val) {
                                  _dataController2.setGender(val);
                                }),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Column(
                          children: [
                            Text('Все'),
                            Obx(
                              () => Radio(
                                activeColor: Colors.green,
                                value: 3,
                                groupValue: _dataController2.gender.value,
                                onChanged: ((val) {
                                  _dataController2.setGender(val);
                                }),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('Возраст'),
                          Expanded(
                            child: Obx(
                              () => RangeSlider(
                                min: 18,
                                max: 100,
                                divisions: 100,
                                labels: RangeLabels(
                                    '${_dataController2.ageControl.value.start.round()}',
                                    '${_dataController2.ageControl.value.end.round()}'),
                                values: _dataController2.ageControl.value,
                                onChanged: (RangeValues values) {
                                  _dataController2.ageControl.value = values;
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      )
      ..show();
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
      appBar: AppBar(
        title: Text('Карта'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.filter_list_rounded),
              onPressed: () {
                yYDialogDemo(context);
              })
        ],
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('userCollection').get(),
        builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            _dataController2.genderUsersList.clear();
            _dataController2.userSetAge.clear();

            snapshot.data.docs.forEach((element) {
              if (element['gender'] == _dataController2.gender.value &&
                  element['gender'] != 3) {
                _dataController2.genderUsersList.add(element);
              } else if (element['gender'] == 3 ||
                  _dataController2.gender.value == 3) {
                _dataController2.genderUsersList.add(element);
              }
            });

            _dataController2.genderUsersList.forEach((element) {
              if (element['age'] <= _dataController2.maxAge.value &&
                  element['age'] >= _dataController2.minAge.value) {
                _dataController2.userSetAge.add(element);
              }
            });

            print(_dataController2.userSetAge.length);




            return FutureBuilder(
              future: getMyCoordsLocator(),
              builder: (context, snapshot2) {
                if(snapshot2.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator());
                }
                if(snapshot2.hasData){
                  return FutureBuilder(
                    future: getMarkers(_dataController2.userSetAge),
                    builder: (context, snapshot3) {
                      return GoogleMap(
                        markers: snapshot3.data,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        initialCameraPosition: CameraPosition(
                            target:
                            snapshot2.data?? _dataController.myLocation,
                            zoom: 12),
                        mapType: MapType.normal,
                      );
                    }
                  );
                }return Center(child: CircularProgressIndicator());

              }
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
