import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_picker/country.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:migrant_app/controllers/data_controller.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  String name;
  String about;
  String aboutOld;
  double age = 1.0;
  double age2;
  String userId;
  String urlAvatar;
  String oldName;
  Country selectedCountry;
  String uploadDone;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File pickedImage;
  File cropedImage;
  String newImgUrl;

  bool inProcess = false;
  bool buttonEnable = true;
  bool isLoading = false;

  String userUid;

  void _validateInputs() async {
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      updateFirestoreData(userUid);
      setState(() {
        buttonEnable = true;
      });


  }else{
      setState(() {
        buttonEnable = true;
      });
    }
  }

  getUserUid() async {
    final userIdFuture = _auth.currentUser.uid;
    setState(() {
      userUid = userIdFuture;
    });
  }

  Future getAllData() async {
    final fb = await FirebaseFirestore.instance
        .collection('userCollection')
        .doc(userUid)
        .get();
    age2 = double.parse(fb.data()['age'].toString());
    oldName = fb.data()['name'];
    aboutOld = fb.data()['about'];
    urlAvatar = fb.data()['urlAvatar'];

      uploadDone = fb.data()['country'];

  }

  Future updateFirestoreData(userId) async {
    setState(() {
      buttonEnable = false;
    });
    FirebaseFirestore.instance
        .collection('userCollection')
        .doc(userId)
        .update({
      'name': name == null ? oldName : name,
      'about': about == ''
          ? null
          : about != null
              ? about
              : about == null
                  ? aboutOld
                  : about,
      'age': age == 1.0 ? age2 : age,
      'urlAvatar': newImgUrl == null ? urlAvatar : newImgUrl,
    }).whenComplete(() {
      setState(() {
        buttonEnable = true;
      });
    }).whenComplete(
      () => Get.back(),
    );
  }

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
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        androidUiSettings: AndroidUiSettings(toolbarTitle: 'Редактор'),
        iosUiSettings: IOSUiSettings(title: 'Редактор'));
    if (croped != null) {
      setState(() {
        cropedImage = croped;
      });
      addImageToFirebase();
    }
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
      newImgUrl = urlImg;
    } catch (e) {
      Get.snackbar('Ошибка', e.toString());
      setState(() {
        inProcess = false;
      });
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
    getUserUid();
    getAllData().then((_) {
      setState(() {
        uploadDone = '';
      });
    } );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактор профиля'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            uploadDone == null ? Center(child: LinearProgressIndicator()) :
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showPicOptionsDialog();
                        },
                        child: Container(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, left: 10, right: 10, bottom: 3),
                                child: CircleAvatar(
                                  radius: 60,
                                  child: ClipOval(
                                    child: cropedImage == null
                                        ? CachedNetworkImage(
                                            imageUrl: urlAvatar,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          )
                                        : Image.file(cropedImage),
                                  ),
                                ),
                              ),
                              Text('Изменить'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // TextFormField(
                      //   enabled: false,
                      //   initialValue: oldName,
                      //   decoration: InputDecoration(
                      //       hintText: 'Мое имя',
                      //       border: new OutlineInputBorder(
                      //         borderRadius: const BorderRadius.all(
                      //           const Radius.circular(30.0),
                      //         ),
                      //       ),
                      //       prefixIcon: Icon(Icons.perm_contact_cal)),
                      //   textInputAction: TextInputAction.next,
                      //   keyboardType: TextInputType.text,
                      //   onChanged: (val) {
                      //     name = val;
                      //   },
                      //   validator: (String arg) {
                      //     if (arg.length < 1)
                      //       return 'Введите ваше имя';
                      //     else
                      //       return null;
                      //   },
                      // ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        maxLength: 280,
                        initialValue: aboutOld ?? '',
                        decoration: InputDecoration(
                            hintText: 'Краткая информация о пользователе',
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(30.0),
                              ),
                            ),
                            prefixIcon: Icon(Icons.info)),
                        textInputAction: TextInputAction.newline,
                        textCapitalization:
                        TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 6,
                        keyboardType: TextInputType.multiline,
                        onChanged: (val) {
                          about = val;
                        },
                        validator: (String arg) {
                          if (arg.length > 280)
                            return 'Максимальной число символов 280';

                          else
                            return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          // Text(
                          //   'Возраст:',
                          //   style: TextStyle(fontSize: 16),
                          // ),
                          // age == 1.0
                          //     ? Text(
                          //         '${age2.round()}',
                          //         style: TextStyle(
                          //             fontSize: 25,
                          //             fontWeight: FontWeight.bold),
                          //       )
                          //     : Text(
                          //         '${age.round()}',
                          //         style: TextStyle(
                          //             fontSize: 25,
                          //             fontWeight: FontWeight.bold),
                          //       ),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 20),
                          //   child: Slider(
                          //       min: 1,
                          //       max: 99,
                          //       value: age == 1 ? age2 : age,
                          //       onChanged: (newValue) {
                          //         setState(() {
                          //           age = newValue;
                          //         });
                          //       }),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 20, left: 20, top: 50, bottom: 30),
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                child: buttonEnable == true
                                    ? Text(
                                  'Сохранить',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                )
                                    : SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator()),
                                onPressed: () {
                                  setState(() {
                                    buttonEnable = false;
                                  });
                                  _validateInputs();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // CountryPicker(
                      //     dense: false,
                      //     showFlag: true,
                      //     showDialingCode: false,
                      //     showName: true,
                      //     showCurrency: false,
                      //     showCurrencyISO: false,
                      //     onChanged: (Country country) {
                      //       setState(() {
                      //         selectedCountry = country;
                      //       });
                      //     },
                      //     selectedCountry: selectedCountry == null ? oldSelectedCountry : selectedCountry),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
