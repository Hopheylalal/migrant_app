import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class TinderContainer extends StatefulWidget {
  final imgUrl;
  final name;
  final age;
  final country;
  final countryCode;
  final id;
  final Function addFavor;
  final about;
  final Function tCardController;
  final Function tCardController2;

  const TinderContainer(
      {Key key,
      this.imgUrl,
      this.name,
      this.age,
      this.country,
      this.countryCode,
      this.id,
      this.addFavor,
      this.about,
      this.tCardController,
      this.tCardController2})
      : super(key: key);

  @override
  _TinderContainerState createState() => _TinderContainerState();
}

class _TinderContainerState extends State<TinderContainer> {

  YYDialog yYDialogDemo(BuildContext context) {
    return YYDialog().build(context)
      ..width = Get.height
      ..height = 330
      ..gravity = Gravity.top
      ..margin = Get.size.height >= 896
          ? EdgeInsets.symmetric(vertical: 100)
          : EdgeInsets.symmetric(vertical: 80)
      ..widget(
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text('О себе',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                Text('${widget.about?? 'Описание пока не добавлено'}',style: TextStyle(fontSize: 16),),
              ],
            ),
          ),
        ),
      )
      ..show();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xfff0f0f0),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: CachedNetworkImage(
              fit: BoxFit.fill,
              imageUrl: widget.imgUrl,
              placeholder: (context, url) => SizedBox(
                width: 120,
                height: 120,
                child: Center(
                  child: Shimmer.fromColors(
                      child: Image.asset('assets/img/imgplaseholder.png'),
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100]),
                ),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
            child: Text(
              '${widget.name}, ${widget.age}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              overflow: TextOverflow.fade,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: Flag(widget.countryCode),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  widget.country,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 20, top: 10, left: 20, bottom: 10),
              child: widget.about == null
                  ? SizedBox()
                  : GestureDetector(
                onTap: (){

                },
                    child: Text(
                        '${widget.about}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.fade,
                      ),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30,right: 20),
            child: Row(
mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 10,right: 15),
                  child: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Color(0xff8536a0),
                      size: 60,
                    ),
                    onPressed: () {
                      widget.tCardController2();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                        onTap: (){
                          yYDialogDemo(context);
                        },
                        child: Image.asset('assets/img/ib.png',scale: 5.5,)),
                  ),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.solidHeart,
                      color: Color(0xfff2255d), size: 45),
                  onPressed: () {
                    widget.tCardController();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
