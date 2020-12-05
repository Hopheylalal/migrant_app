import 'package:flutter/material.dart';

class AboutTExtWidget extends StatelessWidget {
  final text;

  const AboutTExtWidget({Key key, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(child: SingleChildScrollView(child: Text(text,style: TextStyle(fontSize: 16),)));
  }
}
