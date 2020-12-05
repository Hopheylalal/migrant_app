import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:google_maps_utils/google_maps_utils.dart';
import 'package:migrant_app/controllers/data_controller2.dart';
import 'package:migrant_app/screens/map_screen.dart';

import '../home.dart';

class FilterWidgetMap extends StatefulWidget {
  @override
  _FilterWidgetMapState createState() => _FilterWidgetMapState();
}

class _FilterWidgetMapState extends State<FilterWidgetMap> {
  DataController2 _dataController = Get.put(DataController2());
  GetStorage filterSave = GetStorage();

  var yyDialog = YYDialog();

  int radioGroup = 3;
  RangeValues _age = RangeValues(18, 100);
  RangeValues _radius = RangeValues(0.3, 0.7);

  double ageMax = 100;
  double ageMin = 18;
  double radiusMax = 0;
  double radiusMin = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      _dataController
                          .setMinAge(_dataController.ageControl.value.start);
                      _dataController
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
                          groupValue: _dataController.gender.value,
                          onChanged: ((val) {
                            _dataController.setGender(val);
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
                      Text('Женщины'),
                      Obx(
                            () => Radio(
                          activeColor: Colors.pinkAccent,
                          value: 2,
                          groupValue: _dataController.gender.value,
                          onChanged: ((val) {
                            _dataController.setGender(val);
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
                          groupValue: _dataController.gender.value,
                          onChanged: ((val) {
                            _dataController.setGender(val);
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
                              '${_dataController.ageControl.value.start.round()}',
                              '${_dataController.ageControl.value.end.round()}'),
                          values: _dataController.ageControl.value,
                          onChanged: (RangeValues values) {
                            _dataController.ageControl.value = values;
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
    );
  }
}
