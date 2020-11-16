import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:migrant_app/models/latlng_model.dart';


class DataController2 extends GetxController {

  RxSet<Marker> userMarkersSet = RxSet();

  RxList userSetAge = RxList();



  setUserMarkersSet(doc){
    userMarkersSet.clear();
    userMarkersSet.add(doc) ;
  }

  var genderUsersList = [].obs;

  var distanceUser = 100000000.0.obs;

  var distanceSlider = 5.0.obs;

  LatLng myLocation;



  setLocation(LatLng loc) {

    myLocation = loc;
    update();
  }




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

  }

  setMinAge(age) {
    minAge.value = age;
  }

  setMaxAge(age) {
    maxAge.value = age;
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