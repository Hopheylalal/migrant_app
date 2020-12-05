import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:migrant_app/screens/add_avatar.dart';

import '../home.dart';

class RegistrationGoogleSignIn extends StatefulWidget {
  @override
  _RegistrationGoogleSignInState createState() =>
      _RegistrationGoogleSignInState();
}

class _RegistrationGoogleSignInState extends State<RegistrationGoogleSignIn> {
  var phoneNumber;
  var name;
  double age;
  var pass;
  var email;
  var urlAvatar;
  Country selectedCountry;
  int radioGroup;

  bool buttonEnable = true;

  List emptyList;

  DataController _dataController = Get.put(DataController());


  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var maskFormatter = new MaskTextInputFormatter(
    mask: '+# (###) ###-##-##',
    filter: {
      "#": RegExp(r'[0-9]'),
    },
  );

  var maskFormatterAge = new MaskTextInputFormatter(
    mask: '##',
    filter: {
      "#": RegExp(r'[0-9]'),
    },
  );

  GetStorage savedUserUid = GetStorage();

  final FocusNode _nameFocusNode = FocusNode();

  final FocusNode _phoneFocusNode = FocusNode();

  final FocusNode _mailFocusNode = FocusNode();

  final FocusNode _passFocusNode = FocusNode();

  final FocusNode _ageFocusNode = FocusNode();

  User user = Get.arguments;

  LatLng startCoords;

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  File pickedImage;
  File cropedImage;

  getLocation()async{
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

  Future addImageToFirebase() async {
    final userId = FirebaseAuth.instance.currentUser.uid;
    try {
      StorageReference reference = FirebaseStorage.instance
          .ref()
          .child('/images/$userId/avatar/${DateTime.now().toIso8601String()}');

      StorageUploadTask uploadTask = reference.putFile(cropedImage);

      StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

      String urlImg = await downloadUrl.ref.getDownloadURL();

      FirebaseFirestore.instance
          .collection('userCollection')
          .doc(userId)
          .update(
        {'urlAvatar': urlImg},
      ).whenComplete(() {
        Get.offAll(Home());
      });
    } catch (e) {
      Get.snackbar('Ошибка', e.toString());
      setState(() {
        inProcess = false;
      });
    }
  }


  void _validateInputs() async {
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      try {
        if (selectedCountry == null) {
          Get.snackbar('Ошибка', 'Укажите ваш флаг',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        } else if (radioGroup == null) {
          Get.snackbar('Ошибка', 'Укажите ваш пол',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        } else {
          setState(() {
            buttonEnable = false;
          });

          final fbm = FirebaseMessaging();
          final token = await fbm.getToken();

          FirebaseFirestore.instance
              .collection('userCollection')
              .doc(user.uid)
              .set({
            'blocked' : false,
            'geoLoc' : GeoPoint(_dataController.myLocation.latitude,_dataController.myLocation.longitude),
            'token' : token,
            'id': user.uid,
            'email': user.email,
            'pass': pass,
            'gender': radioGroup,
            'name': name,
            'age': age.round(),
            'phoneNumber': phoneNumber,
            'createDate': Timestamp.now(),
            'urlAvatar': 'https://firebasestorage.googleapis.com/v0/b/migrant-app-5f27c.appspot.com/o/user.png?alt=media&token=e3e62cdb-edab-49c5-bb0b-ca0d10c15867',
            'country': selectedCountry.name,
            'countryCode': selectedCountry.isoCode,
            'about': null,
            'userPhoto' : [],
            'favor' : [],
          }).whenComplete(() {
            addImageToFirebase().catchError((e){
              Get.back();
            });
          }).catchError((e) {
            Get.snackbar('Ошибка', e.message,
                backgroundColor: Colors.redAccent, colorText: Colors.white);
            print(e);
          });
          setState(() {
            buttonEnable = true;
          });
          Get.off(Home());
        }
      } catch (e) {

        setState(() {
          buttonEnable = true;
        });
      }
    }
  }

  bool inProcess = false;

  bool isLoading = false;

  void loadPicker(ImageSource source) async {
    setState(() {
      inProcess = true;
      isLoading = true;
    });
    final imagePicker = ImagePicker();
    PickedFile picked = await imagePicker.getImage(source: source);
    File readyImage = picked == null ? null : File(picked?.path);
    if (picked != null) {
      cropImage(readyImage);
      // pickedImage = File(picked.path);
    } else {
      setState(() {
        inProcess = false;
      });
    }
  }

  void cropImage(File pick) async {
    File croped = await ImageCropper.cropImage(
      sourcePath: pick.path,
      compressQuality: 70,

      maxHeight: 600,
      maxWidth: 600,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      androidUiSettings: AndroidUiSettings(toolbarTitle: 'Редактор',cropFrameColor: Color(0xfff2255d)),
      iosUiSettings: IOSUiSettings(title: 'Редактор',),
    ).catchError((_) {
      setState(() {
        inProcess = false;
      });
      Get.back();
    });
    if (croped != null) {
      cropedImage = croped;

      setState(() {

      });
    } else {
      setState(() {
        inProcess = false;
      });
      Get.back();
    }
  }

  void showPicOptionsDialog() {
    Get.defaultDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlatButton.icon(
            onPressed: () {
              loadPicker(ImageSource.gallery);
              Get.back();
            },
            label: Text('Галерея'),
            icon: FaIcon(FontAwesomeIcons.images),
          ),
          SizedBox(
            width: 10,
          ),
          FlatButton.icon(
            onPressed: () {
              loadPicker(ImageSource.camera);
              Get.back();
            },
            label: Text('Камера'),
            icon: FaIcon(FontAwesomeIcons.camera),
          ),
        ],
      ),
      textCancel: 'Отмена',
      title: '',
      onCancel: () {
        setState(() {
          inProcess = false;
        });
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    void _phoneEditingComplete() {
      final newFocus = _nameFocusNode;
      FocusScope.of(context).requestFocus(newFocus);
    }

    void _nameEditingComplete() {
      final newFocus = _ageFocusNode;
      FocusScope.of(context).requestFocus(newFocus);
    }

    void _ageEditingComplete() {
      final newFocus = _mailFocusNode;
      FocusScope.of(context).requestFocus(newFocus);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Заполните форму'),
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        cropedImage == null
                            ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Icon(
                            Icons.photo_camera_rounded,
                            size: 120,
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.only(bottom: 10,top: 20),
                          child: Center(
                            child: CircleAvatar(
                              radius: 80,
                              backgroundImage: cropedImage != null
                                  ? FileImage(cropedImage)
                                  : Icon(
                                Icons.photo_camera_rounded,
                                size: 120,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Text(
                                'Добавить фото',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              onPressed: () {
                                showPicOptionsDialog();
                              }),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    hintText: 'Мой номер телефона',
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(30.0),
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  onEditingComplete: _phoneEditingComplete,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [maskFormatter],
                  onSaved: (val) {
                    phoneNumber = val;
                  },
                  validator: (String arg) {
                    if (arg.length < 1)
                      return 'Введите номер телефона';
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
                      hintText: 'Мое имя',
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(30.0),
                        ),
                      ),
                      prefixIcon: Icon(Icons.perm_contact_cal)),
                  textInputAction: TextInputAction.next,
                  onEditingComplete: _nameEditingComplete,
                  focusNode: _nameFocusNode,
                  textCapitalization:
                  TextCapitalization.sentences,
                  keyboardType: TextInputType.text,
                  onSaved: (val) {
                    name = val;
                  },
                  validator: (String arg) {
                    if (arg.length < 1)
                      return 'Введите ваше имя';
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
                      hintText: 'Мой возраст',
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(30.0),
                        ),
                      ),
                      prefixIcon: Icon(Icons.calendar_today)),
                  textInputAction: TextInputAction.next,
                  focusNode: _ageFocusNode,
                  onEditingComplete: _ageEditingComplete,
                  inputFormatters: [maskFormatterAge],
                  keyboardType: TextInputType.number,
                  onSaved: (val) {
                    age = double.parse(val);
                  },
                  validator: (String arg) {
                    if (arg.length < 2 || arg[0] == '0') {
                      return 'Введите корректные данные';
                    }
                    return null;
                  },
                ),

                SizedBox(
                  height: 30,
                ),
                //_____________________________
                Text(
                  'Мой флаг',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                CountryPicker(
                    dense: false,
                    showFlag: true,
                    showDialingCode: false,
                    showName: true,
                    showCurrency: false,
                    showCurrencyISO: false,
                    onChanged: (Country country) {
                      setState(() {
                        selectedCountry = country;
                      });
                    },
                    selectedCountry: selectedCountry),

                SizedBox(
                  height: 30,
                ),
                //_____________________________
                Text(
                  'Пол',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text('Мужчина'),
                        Radio(
                          value: 1,
                          groupValue: radioGroup,
                          onChanged: ((e) {
                            setState(() {
                              radioGroup = e;
                            });
                          }),
                        )
                      ],
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Column(
                      children: [
                        Text('Женщина'),
                        Radio(
                          activeColor: Colors.pinkAccent,
                          value: 2,
                          groupValue: radioGroup,
                          onChanged: ((val) {
                            setState(() {
                              radioGroup = val;
                            });
                          }),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 20, left: 20, top: 0, bottom: 30),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      child: buttonEnable == true
                          ? Text(
                              'Далее',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            )
                          : SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(backgroundColor: Colors.white,)),
                      onPressed: () {
                        if(cropedImage == null){
                          Get.snackbar('Внимание', 'Добавьте фото',colorText: Colors.white,backgroundColor: Colors.black26);
                        }else{
                          _validateInputs();
                        }
                      },
                    ),
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
