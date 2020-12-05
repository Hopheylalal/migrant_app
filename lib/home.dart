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

import 'controllers/message_controller.dart';

class Home extends StatefulWidget {
  final currentIndex;

  const Home({Key key, this.currentIndex = 0}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  DataController _dataController = Get.put(DataController());

  MessageController _mc = Get.find();

  FirebaseAuth _auth = FirebaseAuth.instance;
  GetStorage saveToken = GetStorage();
  GetStorage saveLocation = GetStorage();

  GetStorage saveMessageCount = GetStorage();

  String userUid;

  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  List newList2 = [];

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
 int messageCount;
  getMessagesFromFireStore() async {
    print('it is alive');
    final chatIds = [];
    final chatList = [];

    final msgArrFb = await FirebaseFirestore.instance
        .collection('chats')
        .where('convers', arrayContains: userUid)
        .get()
        .then((val) => val.docs);

    msgArrFb.forEach((element) {
      chatIds.add(element.id);
    });

    for (int i = 0; i < chatIds.length; i++) {
      var ff = await FirebaseFirestore.instance
          .collection("chats")
          .doc(chatIds[i])
          .collection("messages")
          .get();
      var fff = ff.docs.where((element) => element.data()['$userUid'] == true);
      chatList.addAll(fff.toList());


    }


    messageCount = chatList.length;
    print(chatList.length);
  }

  void getMessages(user) {
    _firebaseMessaging.configure(
        onMessage: (msg) {
          print(msg);
          getMessagesFromFireStore();
          setState(() {});

          return;
        },
        onLaunch: (msg) {
          print(msg);
          getMessagesFromFireStore();
          setState(() {});

          return;
        },
        onResume: (msg) {
          print(msg);
          getMessagesFromFireStore();
          setState(() {});
          return;
        });
  }

  Stream getMessageCounter() async* {
    await getMessagesFromFireStore();
    final result = messageCount;

    yield result;
  }

  getGeoLocAppStart()async{
    print('getGeoLocAppStart');
    FirebaseFirestore.instance
        .collection('userCollection')
        .doc(userUid)
        .update({
      'geoLoc': GeoPoint(_dataController.myLocation?.latitude?? _dataController.myLocation2.latitude, _dataController.myLocation?.longitude?? _dataController.myLocation2.longitude),
    }).catchError((e) {
      print(e.message);
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
      _dataController.setLocation(latLng,userUid);
      GetStorage filterSave = GetStorage();
      filterSave.write('Lat', latLng.latitude);
      filterSave.write('Lng', latLng.longitude);
    });
    WidgetsBinding.instance.addObserver(this);
    getMessageCounter();
    if (widget.currentIndex == 3) {
      _currentIndex = 3;
    }
    getGeoLocAppStart();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('coool resume is work');
      _dataController.distanceUsersListGetBuilder.clear();
      FirebaseFirestore.instance
          .collection('userCollection')
          .doc(userUid)
          .update({
        'geoLoc': GeoPoint(_dataController.myLocation.latitude?? _dataController.myLocation2.latitude, _dataController.myLocation.longitude?? _dataController.myLocation2.longitude),
      }).catchError((e) {
        print(e.message);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
              icon:
                  // _mc.messageCount.value == null || _mc.messageCount.value == 0
                  //     ? FaIcon(
                  //         FontAwesomeIcons.commentAlt,
                  //       )
                  //     :
                  StreamBuilder(
                stream: getMessageCounter(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return FaIcon(
                      FontAwesomeIcons.commentAlt,
                    );
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data == 0) {
                      FaIcon(
                        FontAwesomeIcons.commentAlt,
                      );
                    } else {
                      return Badge(
                        toAnimate: false,
                        badgeContent: Text(
                          '${snapshot.data}',
                          style: TextStyle(color: Colors.white),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.commentAlt,
                        ),
                      );
                    }
                  }
                  return FaIcon(
                    FontAwesomeIcons.commentAlt,
                  );
                },
              ),
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
