import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_picker/country.dart';
import 'package:get/get.dart';
import 'package:migrant_app/common_profile/coomon_profile.dart';

class UserWidget extends StatelessWidget {
  final imgAvatar;
  final name;
  final age;
  final country;
  final countryCode;
  final userId;

  const UserWidget({Key key, this.imgAvatar, this.name, this.age, this.country, this.countryCode, this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Get.to(ProfileCommon(reciverName: name,),arguments: userId);
      },
      child: Card(
        color: Color(0xfff0f0f0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircleAvatar(
                radius: 40,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imgAvatar,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                        CircularProgressIndicator(
                            value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name, ${age.round()}',
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child:
                            Flag('$countryCode'),
                          ),
                        ),
                        country.length > 24
                            ? Expanded(
                          child: Text(
                            '${country}',
                            overflow: TextOverflow.fade,
                          ),
                        )
                            : Text(
                          '${country}',
                          overflow: TextOverflow.fade,
                        ),

                      ],
                    ),


                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
