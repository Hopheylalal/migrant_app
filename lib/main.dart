import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:migrant_app/home.dart';
import 'package:migrant_app/screens/registration.dart';
import 'package:migrant_app/screens/sign_in.dart';

import 'controllers/data_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();

  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  DataController _dataController = Get.put(DataController());

  getMyCoordsLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
    LatLng _latLng = LatLng(position.latitude, position.longitude);
    _dataController.setLocation2(_latLng);
  }
  @override
  Widget build(BuildContext context) {
    getMyCoordsLocator();
    YYDialog.init(context);
    return GetMaterialApp(
      // initialBinding: AuthBinding(),
      debugShowCheckedModeBanner: false,
      title: 'Migrant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            print('Current User != null');

            return Home();
          }
          return FirstPage();
        },
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 150,
                ),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset('assets/img/plsholder.png'),
                ),
                SizedBox(
                  height: 50,
                ),
                FlatButton(
                  onPressed: () {
                    Get.to(Registration());
                  },
                  child: Text(
                    'РЕГИСТРАЦИЯ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton(
                  onPressed: () {
                    Get.to(SignIn());
                  },
                  child: Text(
                    'ВХОД',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
