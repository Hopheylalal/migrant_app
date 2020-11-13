import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:migrant_app/models/latlng_model.dart';
import 'package:migrant_app/screens/map_screen.dart';
import 'package:migrant_app/widgets/filter_widget.dart';
import 'package:migrant_app/widgets/user_widget.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as map;

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  GetStorage filterSave = GetStorage();
  DataController _dataController = Get.put(DataController());
  FirebaseAuth _auth = FirebaseAuth.instance;

  YYDialog yYDialogDemo(BuildContext context) {
    return YYDialog().build(context)
      ..width = Get.height
      ..height = 300
      ..gravity = Gravity.top
      ..margin = EdgeInsets.symmetric(vertical: 80)
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

  getMyCoordsLocator()async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    map.LatLng _latLng = map.LatLng(position.latitude,position.longitude);
    _dataController.setLocation(_latLng);

  }

  getUserUid() {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      currentUser = userIdFuture;
    });
  }

  LatLng myCurrentCoords;

  getMyCoords() async {
    final result = await FirebaseFirestore.instance
        .collection('userCollection')
        .doc(currentUser)
        .get();
    GeoPoint myCoords = result.data()['geoLoc'];
    final lat = myCoords.latitude;
    final lng = myCoords.longitude;

    LatLng _latLng = LatLng(lat, lng);

    myCurrentCoords = _latLng;

    filterSave.write('Lat', _latLng.latitude);
    filterSave.write('Lng', _latLng.longitude);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
    getMyCoords();
    getMyCoordsLocator();
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
        stream:
            FirebaseFirestore.instance.collection('userCollection').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {

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
              LatLng latLng2 = new LatLng(_dataController?.myLocation?.latitude, _dataController?.myLocation?.longitude);
              LatLng latLng3 = new LatLng(filterSave.read('Lat'),filterSave.read('Lng'));

              var distanceBetweenPoints;
              try {
                distanceBetweenPoints =
                    SphericalUtil.computeDistanceBetween(
                        latLng, latLng2);
              }catch(e){
                distanceBetweenPoints =
                    SphericalUtil.computeDistanceBetween(
                        latLng, latLng3);
              }
              print(distanceBetweenPoints);

              LatLngModel _ltLng =
                  LatLngModel(doc: element, distance: distanceBetweenPoints);

              if (_ltLng.distance <= _dataController.distanceUser.value) {
                _dataController.distanceUsersListGetBuilder.add(_ltLng.doc);
              }
            });

            return ListView.builder(
              itemCount: _dataController.distanceUsersListGetBuilder?.length,
              itemBuilder: (BuildContext context, int index) {
                return UserWidget(
                  imgAvatar: _dataController?.distanceUsersListGetBuilder[index]
                      ['urlAvatar'],
                  name: _dataController?.distanceUsersListGetBuilder[index]
                      ['name'],
                  age: _dataController?.distanceUsersListGetBuilder[index]
                      ['age'],
                  countryCode: _dataController
                      ?.distanceUsersListGetBuilder[index]['countryCode'],
                  country: _dataController?.distanceUsersListGetBuilder[index]
                      ['country'],
                  userId: _dataController?.distanceUsersListGetBuilder[index]
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
