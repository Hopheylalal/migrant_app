import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:migrant_app/screens/add_avatar.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  var phoneNumber;
  var name;
  double age;
  var pass;
  var email;
  var urlAvatar;
  Country selectedCountry;
  int radioGroup;
  List emptyList;

  bool buttonEnable = true;

  DataController _dataController = Get.put(DataController());


  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var maskFormatter = new MaskTextInputFormatter(
    mask: '+# (###) ###-##-##',
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

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

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
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: pass)
              .catchError((e) {
            Get.snackbar('Ошибка', e.message);
            setState(() {
              buttonEnable = true;
            });
          }).then((value) async{
            savedUserUid.write('userUid', value.user.uid);
            final fbm = FirebaseMessaging();
            final token = await fbm.getToken();

            FirebaseFirestore.instance
                .collection('userCollection')
                .doc(value.user.uid)
                .set({
              'geoLoc' : GeoPoint(_locationData.latitude,_locationData.longitude),
              'token' : token,
              'id': value.user.uid,
              'email': email,
              'pass': pass,
              'gender': radioGroup,
              'name': name,
              'age': age.round(),
              'phoneNumber': phoneNumber,
              'createDate': Timestamp.now(),
              'urlAvatar': 'https://firebasestorage.googleapis.com/v0/b/migrant-app-5f27c.appspot.com/o/user.png?alt=media&token=e3e62cdb-edab-49c5-bb0b-ca0d10c15867',
              'country': selectedCountry.name,
              'countryCode' : selectedCountry.isoCode,
              'about' : null,
              'userPhoto' : [],
              'favor' : [],
            }).catchError((e) {
              Get.snackbar('Ошибка', e.message,
                  backgroundColor: Colors.redAccent, colorText: Colors.white);
              print(e);
            });
            setState(() {
              buttonEnable = true;
            });
            Get.off(AddAvatar());
          });
        }
      } catch (e) {
        print(e);
      }
    }
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

    void _mailEditingComplete() {
      final newFocus = _passFocusNode;
      FocusScope.of(context).requestFocus(newFocus);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Регистрация'),
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
                  keyboardType: TextInputType.number,
                  onSaved: (val) {
                    age = double.parse(val);
                  },
                  validator: (String arg) {
                    if (arg.length < 1) {
                      return 'Заполните поле';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 30,
                ),

                //_____________________________

                TextFormField(
                  decoration: InputDecoration(
                      hintText: 'Мой email',
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(30.0),
                        ),
                      ),
                      prefixIcon: Icon(Icons.email)),
                  textInputAction: TextInputAction.next,
                  focusNode: _mailFocusNode,
                  onEditingComplete: _mailEditingComplete,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (val) {
                    email = val;
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
                    pass = val;
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
                      color: Colors.black45,
                      child: buttonEnable == true
                          ? Text(
                              'Зарегистрироваться',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            )
                          : SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator()),
                      onPressed: () {
                        _validateInputs();
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
