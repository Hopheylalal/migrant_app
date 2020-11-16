import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:migrant_app/models/latlng_model.dart';


class DataController extends GetxController {



  List distanceUsersListGetBuilder = [];

  var distanceUsersList = [].obs;
  var distanceUser = 100000000.0.obs;

  var distanceSlider = 5.0.obs;

  LatLng myLocation;
  LatLng myLocation2;

  setDistanceUsersListGetBuilder(list){
    distanceUsersListGetBuilder.add(list);
    update();
  }

  setDistanceSliderToDistanceUser(num) {
    print(num);
    if(num == 1.0){
      distanceUser.value = 500;
    }else if ( num == 1.8){
      distanceUser.value = 1000;
    }else if ( num == 2.6){
      distanceUser.value = 2500;
    }else if ( num == 3.4){
      distanceUser.value = 5000;
    }else if ( num == 4.2){
      distanceUser.value = 10000;
    }

    else if ( num == 5.0){
      distanceUser.value = 100000000;
    }
    print(distanceUser.value);
  }

  setLocation(LatLng loc) {
    distanceUsersListGetBuilder.clear();
    myLocation = loc;
    update();
  }
  setLocation2(LatLng loc) {

    myLocation2 = loc;
    update();
  }

  setDistance(dist) {
    distanceUsersListGetBuilder.clear();
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
    filterSave.write('gender', genderPast);
  }

  setMinAge(age) {
    minAge.value = age;
    filterSave.write('minAge', age);
  }

  setMaxAge(age) {
    maxAge.value = age;
    filterSave.write('maxAge', age);
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