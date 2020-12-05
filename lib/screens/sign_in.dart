import 'dart:io';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';

import '../home.dart';
import 'add_field_google_sigin.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  String _mail;

  String _pass;

  final FocusNode _mailFocusNode = FocusNode();

  final FocusNode _passFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Future<bool> _isAvailableFuture = AppleSignIn.isAvailable();

  bool _autoValidate = false;
  GetStorage savedUserUid = GetStorage();

  bool buttonEnabled = true;

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  getLocation() async {
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
  }

  loginUser({String email, String pass}) async {
    setState(() {
      buttonEnabled = false;
    });

    await _auth
        .signInWithEmailAndPassword(email: email.trim(), password: pass.trim())
        .then((value) async {
      if (value != null) {
        final fbm = FirebaseMessaging();
        final token = await fbm.getToken();
        FirebaseFirestore.instance
            .collection('userCollection')
            .doc(value.user.uid)
            .update({
          'token': token,
          'geoLoc': GeoPoint(_locationData.latitude, _locationData.longitude),
        });
        savedUserUid.write('userUid', value.user.uid);
        setState(() {
          buttonEnabled = true;
        });
        Navigator.pop(context);
      }
    }).catchError((e) {
      Get.snackbar(
        'Ошибка',
        e.code == 'user-not-found'
            ? 'Такой почтовый ящик не найден.'
            : e.code == 'invalid-email'
                ? 'Некорректный email адрес'
                : e.code == 'invalid-email'
                    ? 'Такой почтовый ящик не найден.'
                    : e.code == 'wrong-password'
                        ? 'Неверный пароль.'
                        : e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        print(e.code);
        buttonEnabled = true;
      });
    });
  }

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      setState(() {
        buttonEnabled = false;
      });
      loginUser(
        email: _mail.trim(),
        pass: _pass.trim(),
      );
    } else {
//    If all data are not valid then start auto validation.

      _autoValidate = true;
    }
  }

  List allIds = [];

  getAllUserIds()async{
    try{
      final result = await FirebaseFirestore.instance.collection('userCollection').get();
      final result2 = result.docs;
      result2.forEach((element) {
        allIds.add(element.id);
      });

    }catch(e){
      print(e);
    }

  }

  signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    final acc = await googleSignIn.signIn();
    final auth = await acc.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken, idToken: auth.idToken);
    final res = await _auth.signInWithCredential(credential);
    if (res.additionalUserInfo.isNewUser && !allIds.contains(res.user.uid)) {
      savedUserUid.write('userUid', res.user.uid);
      Get.off(RegistrationGoogleSignIn(), arguments: res.user);
    } else {
      final fbm = FirebaseMessaging();
      final token = await fbm.getToken();
      FirebaseFirestore.instance
          .collection('userCollection')
          .doc(res.user.uid)
          .update({
        'token': token,
      });
      Get.offAll(Home());
    }
  }

  void logInApple() async {
    final AuthorizationResult result = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    switch (result.status) {
      case AuthorizationStatus.authorized:

      print('ok');
        break;

      case AuthorizationStatus.error:
        print("Sign in failed: ${result.error.localizedDescription}");

        break;

      case AuthorizationStatus.cancelled:
        print('User cancelled');
        break;
    }


    // GoogleSignIn googleSignIn = GoogleSignIn();
    // final acc = await googleSignIn.signIn();
    // final auth = await acc.authentication;
    // final credential = GoogleAuthProvider.credential(
    //     accessToken: auth.accessToken, idToken: auth.idToken);
    // final res = await _auth.signInWithCredential(credential);
    // if (res.additionalUserInfo.isNewUser) {
    //   savedUserUid.write('userUid', res.user.uid);
    //   Get.off(RegistrationGoogleSignIn(), arguments: res.user);
    // } else {
    //   final fbm = FirebaseMessaging();
    //   final token = await fbm.getToken();
    //   FirebaseFirestore.instance
    //       .collection('userCollection')
    //       .doc(res.user.uid)
    //       .update({
    //     'token': token,
    //   });
    //   Get.offAll(Home());
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppleSignIn.onCredentialRevoked.listen((_) {
      print("Credentials revoked");
    });
    getAllUserIds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Вход'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),

                TextFormField(
                  decoration: InputDecoration(
                      hintText: 'Логин',
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(30.0),
                        ),
                      ),
                      prefixIcon: Icon(Icons.alternate_email_sharp)),
                  textInputAction: TextInputAction.next,
                  focusNode: _mailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (val) {
                    _mail = val.trim();
                  },
                  validator: (String arg) {
                    if (arg.length < 1)
                      return 'Введите ваш email';
                    else
                      return null;
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                //_____________________________
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Пароль',
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(30.0),
                      ),
                    ),
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  focusNode: _passFocusNode,
                  keyboardType: TextInputType.text,
                  onSaved: (val) {
                    _pass = val;
                  },
                  validator: (String arg) {
                    if (arg.length < 1)
                      return 'Введите пароль';
                    else
                      return null;
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      child: buttonEnabled == true
                          ? Text(
                              'Войти',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            )
                          : SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(backgroundColor: Colors.white,)),
                      onPressed: () {
                        _validateInputs();
                      },
                    ),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                Text(
                  'Быстрый вход',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 2,
                ),
                Platform.isAndroid
                    ? SignInButton(
                        Buttons.GoogleDark,
                        onPressed: () {
                          signInWithGoogle();
                        },
                        text: 'Войти с Google',
                      )
                    : SignInButton(
                        Buttons.AppleDark,
                        onPressed: () {
                          logInApple();
                        },
                        text: 'Войти с Apple',
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
