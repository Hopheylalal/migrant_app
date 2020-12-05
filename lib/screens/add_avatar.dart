import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../home.dart';

class AddAvatar extends StatefulWidget {
  @override
  _AddAvatarState createState() => _AddAvatarState();
}

class _AddAvatarState extends State<AddAvatar> {
  File pickedImage;
  File cropedImage;

  bool inProcess = false;

  bool isLoading = false;

  var maskFormatter = new MaskTextInputFormatter(
    mask: '#-#',
    filter: {
      "#": RegExp(r'[0-9]'),
    },
  );

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
      addImageToFirebase();
    } else {
      setState(() {
        inProcess = false;
      });
      Get.back();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading == false
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    cropedImage == null
                        ? Icon(
                            Icons.photo_camera_rounded,
                            size: 120,
                          )
                        : Center(
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
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                        'Никто не увидит ваш профиль, до тех пор пока Вы не добавите фото'),
                    SizedBox(
                      height: 40,
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
            )
          : Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
