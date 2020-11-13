import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:migrant_app/models/latlng_model.dart';


class DataController2 extends GetxController {

  RxSet<Marker> mapDocProfiles = RxSet();

  setMapDocProfiles(doc){
    mapDocProfiles.add(doc) ;
  }

  var distanceUsersList = [].obs;
  var distanceUser = 100000000.0.obs;

  var distanceSlider = 5.0.obs;

  LatLng myLocation;



  setLocation(LatLng loc) {
    distanceUsersList.clear();
    myLocation = loc;
    update();
  }

  setDistance(dist) {
    distanceUsersList.clear();
    distanceUser.value = dist;
  }


  GetStorage filterSave = GetStorage();
  var ageControl = RangeValues(18, 100).obs;

  var minAge = 18.0.obs;
  var maxAge = 100.0.obs;

  var gender = 3.obs;

  var minRadius = RxDouble().obs;
  var maxRadius = RxDouble().obs;

  setAge(age) {
    ageControl.value = age;
  }

  setGender(genderPast) {
    gender.value = genderPast;
    filterSave.write('gender1', genderPast);
  }

  setMinAge(age) {
    minAge.value = age;
    filterSave.write('minAge1', age);
  }

  setMaxAge(age) {
    maxAge.value = age;
    filterSave.write('maxAge1', age);
  }


  Map<String, dynamic> userDataController;

  var urlAvatar = ''.obs;

  var newMessages = [].obs;

  // LatLng myLatLng;
  //
  // setLatLng(coords){
  //   myLatLng = coords;
  //   print('!!!!!!!$myLatLng');
  //   update();
  // }

  addNewMessages(val) {
    newMessages.add(val);
  }


  putUrlAvatar(url) {
    urlAvatar.value = url;
  }

  userDataControllerUpdate(userData) {
    userDataController = userData;
    update();
  }


}