
import 'package:cloud_firestore/cloud_firestore.dart';

class LatLngModel {

  final QueryDocumentSnapshot doc;
  final double distance;

  LatLngModel({this.doc, this.distance});


}