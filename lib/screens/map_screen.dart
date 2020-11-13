import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:migrant_app/controllers/data_controller2.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> users = {};
  String masterName;
  LatLng startLocation;
  LatLng startLocationError = LatLng(55.749711, 37.616806);
  final box = GetStorage();
  DataController _dataController = Get.put(DataController());
  DataController2 _dataController2 = Get.put(DataController2());

  int radioGroup = 3;
  RangeValues _age = RangeValues(18, 100);
  RangeValues _radius = RangeValues(0.3, 0.7);

  double ageMax = 100;
  double ageMin = 18;
  double radiusMax = 0;
  double radiusMin = 0;

  List<String> cntrCode = [
    'AF',
    'AL',
    'DZ',
    'AS',
    'AD',
    'AO',
    'AI',
    'AG',
    'AR',
    'AM',
    'AW',
    'AU',
    'AT',
    'AZ',
    'BS',
    'BH',
    'BD',
    'BB',
    'BY',
    'BE',
    'BZ',
    'BJ',
    'BM',
    'BT',
    'BO',
    'BA',
    'BW',
    'BR',
    'VG',
    'BN',
    'BG',
    'BF',
    'BI',
    'KH',
    'CM',
    'CA',
    'CV',
    'KY',
    'CF',
    'TD',
    'CL',
    'CN',
    'CX',
    'CC',
    'CO',
    'KM',
    'CK',
    'CR',
    'HR',
    'CU',
    'CW',
    'CY',
    'CZ',
    'CD',
    'DK',
    'DJ',
    'DM',
    'DO',
    'EC',
    'EG',
    'GQ',
    'ER',
    'EE',
    'ET',
    'FK',
    'FO',
    'FJ',
    'FI',
    'FR',
    'PF',
    'GA',
    'GM',
    'GE',
    'DE',
    'GH',
    'GI',
    'GR',
    'GL',
    'GD',
    'GU',
    'GT',
    'GG',
    'GN',
    'GW',
    'GY',
    'HT',
    'HN',
    'HK',
    'HU',
    'IS',
    'IN',
    'ID',
    'IR',
    'IQ',
    'IE',
    'IM',
    'IL',
    'IT',
    'CI',
    'JM',
    'JP',
    'JE',
    'JO',
    'KZ',
    'KE',
    'KI',
    'XK',
    'KW',
    'KG',
    'LA',
    'LV',
    'LB',
    'LS',
    'LR',
    'LY',
    'LI',
    'LT',
    'LU',
    'MO',
    'MG',
    'MW',
    'MY',
    'MV',
    'ML',
    'MT',
    'MH',
    'MR',
    'MU',
    'MX',
    'FM',
    'MD',
    'MC',
    'MN',
    'ME',
    'MS',
    'MA',
    'MZ',
    'MM',
    'NA',
    'NR',
    'NP',
    'NL',
    'NZ',
    'NI',
    'NE',
    'NG',
    'NU',
    'KP',
    'MP',
    'NO',
    'OM',
    'PK',
    'PW',
    'PS',
    'PA',
    'PG',
    'PY',
    'PE',
    'PH',
    'PN',
    'PL',
    'PT',
    'PR',
    'QA',
    'CG',
    'RO',
    'RU',
    'RW',
    'WS',
    'SM',
    'ST',
    'SA',
    'SN',
    'RS',
    'CS',
    'SC',
    'SL',
    'SG',
    'SX',
    'SK',
    'SI',
    'SB',
    'SO',
    'ZA',
    'KR',
    'SS',
    'ES',
    'LK',
    'SD',
    'SR',
    'SZ',
    'SE',
    'CH',
    'SY',
    'TW',
    'TJ',
    'TZ',
    'TH',
    'TG',
    'TK',
    'TO',
    'TT',
    'TN',
    'TR',
    'TM',
    'TC',
    'TV',
    'VI',
    'UG',
    'UA',
    'AE',
    'GB',
    'US',
    'UY',
    'UZ',
    'VU',
    'VA',
    'VE',
    'VN',
    'EH',
    'YE',
    'ZM',
    'ZW',
  ];

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  LatLng myLoc;

  Future getLocation() async {
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
    myLoc = LatLng(_locationData.latitude, _locationData.longitude);
    return LatLng(_locationData.latitude, _locationData.longitude);
  }

  Future<Uint8List> getBytesFromAsset(String path) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: pixelRatio.round() * 30);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  getMarkers() async {
    try{
    final snapshot =
        await FirebaseFirestore.instance.collection('userCollection').get();

    users.clear();

    setState(() {});

    for (var n in snapshot.docs) {
      if (cntrCode.contains(n.data()['countryCode'])) {
        final Uint8List markerIcon = await getBytesFromAsset(
            'assets/flags/${n.data()['countryCode']}.png');
        users.add(
          Marker(
            markerId: MarkerId(n.id),
            infoWindow: InfoWindow(title: '${n.data()['name']}'),
            position: LatLng(
                n.data()['geoLoc'].latitude, n.data()['geoLoc'].longitude),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            onTap: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) => Wrap(children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: Get.height * 0.8,
                        child: Container(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        );
      }else{
        final Uint8List markerIcon = await getBytesFromAsset(
            'assets/flags/none.png');
        users.add(
          Marker(
            markerId: MarkerId(n.id),
            infoWindow: InfoWindow(title: '${n.data()['name']}'),
            position: LatLng(
                n.data()['geoLoc'].latitude, n.data()['geoLoc'].longitude),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            onTap: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) => Wrap(children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: Get.height * 0.8,
                        child: Container(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        );
      }
    }
  }catch(e){
      print(e);
    }
  }

  YYDialog yYDialogDemo(BuildContext context) {
    return YYDialog().build(context)
      ..width = Get.height
      ..height = 300
      ..gravity = Gravity.top
      ..margin = EdgeInsets.symmetric(vertical: 80)
      ..widget(
        Padding(
          padding: EdgeInsets.all(0.0),
          child: Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            Get.back();
                          }),
                    ),
                    Text('ФИЛЬТР'),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            _dataController2
                                .setMinAge(_dataController.ageControl.value.start);
                            _dataController2
                                .setMaxAge(_dataController.ageControl.value.end);


                            Navigator.of(context).pop(true);
                          }),
                    ),
                  ],
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('Меня интересуют'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text('Мужчины'),
                            Obx(
                                  () => Radio(
                                value: 1,
                                groupValue: _dataController2.gender.value,
                                onChanged: ((val) {
                                  _dataController2.setGender(val);
                                }),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Column(
                          children: [
                            Text('Девушки'),
                            Obx(
                                  () => Radio(
                                activeColor: Colors.pinkAccent,
                                value: 2,
                                groupValue: _dataController2.gender.value,
                                onChanged: ((val) {
                                  _dataController2.setGender(val);
                                }),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Column(
                          children: [
                            Text('Все'),
                            Obx(
                                  () => Radio(
                                activeColor: Colors.green,
                                value: 3,
                                groupValue: _dataController2.gender.value,
                                onChanged: ((val) {
                                  _dataController2.setGender(val);
                                }),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('Возраст'),
                          Expanded(
                            child: Obx(
                                  () => RangeSlider(
                                min: 18,
                                max: 100,
                                divisions: 100,
                                labels: RangeLabels(
                                    '${_dataController2.ageControl.value.start.round()}',
                                    '${_dataController2.ageControl.value.end.round()}'),
                                values: _dataController2.ageControl.value,
                                onChanged: (RangeValues values) {
                                  _dataController2.ageControl.value = values;
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ),
      )
      ..show();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
    getMarkers();
  }

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty && startLocation != null) {
      getMarkers();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Карта'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.filter_list_rounded),
              onPressed: () {
                yYDialogDemo(context);
              })
        ],
      ),
      body: FutureBuilder(
          future: FirebaseFirestore.instance.collection('userCollection').get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {

              snapshot.data.docs.forEach((element)async{
                if (cntrCode.contains(element.data()['countryCode'])) {
                  final Uint8List markerIcon = await getBytesFromAsset(
                      'assets/flags/${element.data()['countryCode']}.png');
                  users.add(
                    Marker(
                      markerId: MarkerId(element.id),
                      infoWindow: InfoWindow(title: '${element.data()['name']}'),
                      position: LatLng(
                          element.data()['geoLoc'].latitude, element.data()['geoLoc'].longitude),
                      icon: BitmapDescriptor.fromBytes(markerIcon),
                      onTap: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => Wrap(children: [
                            Container(
                              height: MediaQuery.of(context).size.height,
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  height: Get.height * 0.8,
                                  child: Container(
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        );
                      },
                    ),
                  );
                }else{
                  final Uint8List markerIcon = await getBytesFromAsset(
                      'assets/flags/none.png');
                  users.add(
                    Marker(
                      markerId: MarkerId(element.id),
                      infoWindow: InfoWindow(title: '${element.data()['name']}'),
                      position: LatLng(
                          element.data()['geoLoc'].latitude, element.data()['geoLoc'].longitude),
                      icon: BitmapDescriptor.fromBytes(markerIcon),
                      onTap: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => Wrap(children: [
                            Container(
                              height: MediaQuery.of(context).size.height,
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  height: Get.height * 0.8,
                                  child: Container(
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        );
                      },
                    ),
                  );
                }
              });


              return GoogleMap(
                markers: users.isEmpty ? users : users,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                initialCameraPosition: CameraPosition(
                    target: _dataController.myLocation ?? myLoc ?? startLocationError, zoom: 12),
                mapType: MapType.normal,
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
