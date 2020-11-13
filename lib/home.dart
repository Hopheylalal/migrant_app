import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:migrant_app/screens/message_screen.dart';
import 'package:migrant_app/screens/profile.dart';
import 'package:migrant_app/screens/search_screen.dart';
import 'package:migrant_app/screens/tinder_screen.dart';
import 'package:migrant_app/screens/twits_screen.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as distance;


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  DataController _dataController = Get.put(DataController());

  FirebaseAuth _auth = FirebaseAuth.instance;
  GetStorage saveToken = GetStorage();
  GetStorage saveLocation = GetStorage();

  String userUid;

  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;


  Future getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();


    return LatLng(_locationData.latitude, _locationData.longitude);
  }

  getUserUid() async {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      userUid = userIdFuture;
    });
  }



  int _currentIndex = 0;
  final tabs = [
    SearchScreen(),
    TinderScreen(),
    TwitsScreen(),
    MessageScreen(),
    Profile(),
  ];

  void firebaseCloudMessagingListeners(BuildContext context) {
    _firebaseMessaging.getToken().then((deviceToken) {
      print("Firebase Device token: $deviceToken");
      saveToken.write('token', deviceToken);
    });
  }

  void getMessages(user) {
    _firebaseMessaging.configure(onMessage: (msg) {
      print(msg);

      return;
    }, onLaunch: (msg) {
      print(msg);

      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserUid();
    _firebaseMessaging.requestNotificationPermissions();
    this.firebaseCloudMessagingListeners(context);
    getMessages(userUid);
    getLocation().then((value) {
      LatLng latLng = LatLng(value.latitude, value.longitude);
      print(latLng);
      _dataController.setLocation(latLng);
      GetStorage filterSave = GetStorage();
      filterSave.write('Lat', latLng.latitude);
      filterSave.write('Lng', latLng.longitude);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(actions: [IconButton(icon: Icon(Icons.eight_k), onPressed: (){
      //   print(_dataController.hashChatId);
      // })],),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFE8E8E8),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.globeAmericas), label: ''),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.images), label: ''),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.fileAlt), label: ''),
          BottomNavigationBarItem(
              icon:  FaIcon(FontAwesomeIcons.commentAlt),

              label: ''),
          BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.user,
                size: 28,
              ),
              label: '')
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
