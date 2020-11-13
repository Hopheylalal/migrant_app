import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TinderContainer extends StatelessWidget {
  final imgUrl;
  final name;
  final age;
  final country;
  final countryCode;
  final id;
  final Function addFavor;

  const TinderContainer({Key key, this.imgUrl, this.name, this.age, this.country, this.countryCode, this.id,this.addFavor}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: CachedNetworkImage(
              imageUrl: imgUrl,
              placeholder: (context, url) => SizedBox(
                width: 60,
                height: 60,
                child: Shimmer.fromColors(
                    child: Image.asset(
                        'assets/img/imgplaseholder.png'),
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100]),

              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(country,style: TextStyle(fontSize: 20,),),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: Flag(countryCode),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('$name, $age',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),overflow: TextOverflow.fade,),
            ),
          )

        ],
      ),
    );
  }
}
