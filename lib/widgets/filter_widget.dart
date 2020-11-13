import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:google_maps_utils/google_maps_utils.dart';

import '../home.dart';

class FilterWidget extends StatefulWidget {
  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  DataController _dataController = Get.put(DataController());
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

                      _dataController
                          .setDistance(_dataController.distanceUser.value);

                      _dataController.setDistanceSliderToDistanceUser(
                          _dataController.distanceSlider.value);

                      Get.offAll(Home(), transition: Transition.topLevel);
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
                      Text('Девушки'),
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
                Row(
                  children: [
                    Text('Дистанция'),
                    Expanded(
                      child: Obx(
                        () => Slider(
                            divisions: 5,
                            min: 1,
                            max: 5,
                            label: _dataController.distanceSlider.value == 1
                                ? '500м'
                                : _dataController.distanceSlider.value == 1.8
                                    ? '1км'
                                    : _dataController.distanceSlider.value ==
                                            2.6
                                        ? '2,5км'
                                        : _dataController
                                                    .distanceSlider.value ==
                                                3.4
                                            ? '5км'
                                            : _dataController
                                                        .distanceSlider.value ==
                                                    4.2
                                                ? '10км'
                                                : '∞',
                            value: _dataController.distanceSlider.value,
                            onChanged: (newValue) {
                              _dataController.distanceSlider.value = newValue;
                            }),
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
