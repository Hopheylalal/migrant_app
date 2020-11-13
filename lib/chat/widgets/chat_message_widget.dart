import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:migrant_app/chat/models/message.dart';
import 'package:migrant_app/controllers/data_controller.dart';

class ChatMessageWidget extends StatelessWidget {
  final message;
  final resiverUrl;
  final senderUrl;
  final bool isMe;

  const ChatMessageWidget({
    @required this.message,
    @required this.isMe, this.resiverUrl, this.senderUrl,
  });

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isMe)
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 0, top: 10,bottom: 10),
            child: Obx(()=>
               CircleAvatar(
                  radius: 24, backgroundImage: NetworkImage(Get.find<DataController>().urlAvatar.value)),
            ),
          ),
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: 250),
          decoration: BoxDecoration(
            color: isMe ? Colors.grey[100] : Theme.of(context).accentColor,
            borderRadius: isMe
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(),
        ),
      ],
    );
  }

  Widget buildMessage() => Column(
    crossAxisAlignment:
    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: <Widget>[
      message.toString().length > 4  ?
      message.toString().substring(0,4) == 'http' ?
      Container(

        child: CachedNetworkImage(
          imageUrl: "$message",
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ) :
      Text(
        message,
        style: TextStyle(color: isMe ? Colors.black : Colors.white),
        textAlign: isMe ? TextAlign.end : TextAlign.start,
      ): Text(
        '$message',
        style: TextStyle(fontSize: 18),
      )

    ],
  );
}