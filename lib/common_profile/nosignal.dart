import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoSignal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // initialBinding: AuthBinding(),
      debugShowCheckedModeBanner: false,
      title: 'Migrant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: 300,
                  width: 300,
                  child: Image.asset('assets/img/plsholder.png')),
              SizedBox(
                height: 30,
              ),
              Text(
                'Нет сети',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }
}
