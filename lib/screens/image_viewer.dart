import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:extended_image/extended_image.dart';
import 'package:gallery_saver/gallery_saver.dart';


class ImageViewerWidget extends StatefulWidget {
  final url;
  final List photos;
  final type;
  final startPage;

  const ImageViewerWidget({Key key, this.url, this.photos, this.type, this.startPage}) : super(key: key);

  @override
  _ImageViewerWidgetState createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends State<ImageViewerWidget> {
  @override
  Widget build(BuildContext context) {
    print(widget.url);
    print(widget.startPage);

    return Scaffold(
      appBar: AppBar(
        title: Text('Фото'),
        actions: [
          if(widget.type == 'message')
          IconButton(
            icon: Icon(Icons.download_sharp),
            onPressed: (){
              String path =
                  '${widget.photos.first}';
              GallerySaver.saveImage('$path.png').then((bool success) {
                setState(() {
                  print('Image is saved');
                });
                Get.snackbar('Оповещение', 'Фото сохранено в галерею',backgroundColor: Colors.green,colorText: Colors.white);
              }).catchError((err){
                GallerySaver.saveImage('$path.jpg').then((bool success){
                  setState(() {
                    print('Image is saved');
                  });
                });
                Get.snackbar('Оповещение', 'Фото сохранено в галерею',backgroundColor: Colors.green,colorText: Colors.white);
              });
            },
          )
        ],
      ),
      body: Container(
        child: ExtendedImageGesturePageView.builder(
          itemCount: widget.photos.length,
          controller: PageController(
            initialPage: widget.startPage == null ? 0 : widget.startPage,
            keepPage: true
          ),
          itemBuilder: (BuildContext context, int index) {
            return ExtendedImage.network(
              widget.photos[index],
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,

              initGestureConfigHandler: (ExtendedImageState state) {
                return GestureConfig(
                  //you must set inPageView true if you want to use ExtendedImageGesturePageView
                  inPageView: true,
                  initialScale: 1.0,
                  maxScale: 5.0,
                  animationMaxScale: 6.0,
                  initialAlignment: InitialAlignment.center,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
