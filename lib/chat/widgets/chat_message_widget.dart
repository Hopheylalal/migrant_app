import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:migrant_app/chat/models/message.dart';
import 'package:migrant_app/controllers/data_controller.dart';
import 'package:migrant_app/screens/image_viewer.dart';

class ChatMessageWidget extends StatefulWidget {
  final message;
  final resiverUrl;
  final senderUrl;
  final bool isMe;

  const ChatMessageWidget({
    @required this.message,
    @required this.isMe, this.resiverUrl, this.senderUrl,
  });

  @override
  _ChatMessageWidgetState createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {



  @override
  Widget build(BuildContext context) {

    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        // if (!widget.isMe)
        //   Padding(
        //     padding: const EdgeInsets.only(left: 10,right: 0, top: 10,bottom: 10),
        //     child:
        //        CircleAvatar(
        //           radius: 24, backgroundImage: NetworkImage(widget.resiverUrl)),
        //   ),
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: 250),
          decoration: BoxDecoration(
            color: widget.isMe ? Colors.grey[100] : Color(0xffdba7b5),
            borderRadius: widget.isMe
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
    widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: <Widget>[
      widget.message.toString().length > 4  ?
      widget.message.toString().substring(0,4) == 'http' ?
      Container(

        child: GestureDetector(
          onTap: (){
            List img = [];
            img.add(widget.message);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageViewerWidget(
                  photos: img,
                  type: 'message',
                ),
              ),
            );
          },
          child: CachedNetworkImage(
            imageUrl: "${widget.message}",
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ) :
      Text(
        widget.message,
        style: TextStyle(color: widget.isMe ? Colors.black : Colors.black),
        textAlign: widget.isMe ? TextAlign.end : TextAlign.start,
      ): Text(
        '${widget.message}',
        style: TextStyle(fontSize: 18),
      )

    ],
  );
}