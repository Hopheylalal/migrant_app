import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:migrant_app/controllers/message_controller.dart';
import 'package:migrant_app/home.dart';
import 'package:migrant_app/screens/registration.dart';
import 'package:migrant_app/screens/sign_in.dart';

import 'controllers/data_controller.dart';

void main() async {
  Future<void>initMessageService()async{
    await Get.putAsync<MessageController>(()async => MessageController());
  }
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  await initMessageService();

  runApp(
    MyApp(),
  );

}

class MyApp extends StatelessWidget {
  DataController _dataController = Get.put(DataController());
  MessageController _messageController = Get.put(MessageController());

  getMyCoordsLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
    LatLng _latLng = LatLng(position.latitude, position.longitude);
    _dataController.setLocation2(_latLng);
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }



  @override
  Widget build(BuildContext context) {
    getMyCoordsLocator();
    YYDialog.init(context);
    const color = const Color(0xfff2255d);
    return GetMaterialApp(
      // initialBinding: AuthBinding(),
      debugShowCheckedModeBanner: false,
      title: 'Migrant',
      theme: ThemeData(
        buttonColor: Color(0xfff2255d),
        primarySwatch: createMaterialColor(Color(0xfff2255d)),
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
                  height: 70,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Image.asset(
                    'assets/img/plsholder.png',
                    width: Get.size.width,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: RaisedButton(
                        onPressed: () {
                          Get.to(Registration());
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Text(
                          'РЕГИСТРАЦИЯ',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: RaisedButton(
                        onPressed: () {
                          Get.to(SignIn());
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Text(
                          'ВХОД',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )),
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
