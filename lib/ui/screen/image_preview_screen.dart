import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rate_review/ui/component/pinch_zoom/pinch_zoom_image.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imageUrl;

  const ImagePreviewScreen({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  @override
  Widget build(BuildContext buildContext) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          ...AppToolbar(buildContext,
              children: [
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Image(
                        image: ImageRes.backIcon, height: 25, width: 25)),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 25),
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            resource.preview.tr.toUpperCase(),
                            style: TextStyle(
                                color: CupertinoColors.white,
                                fontFamily: narrowmedium,
                                fontSize: 20,
                                letterSpacing: 4.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                    )),
              ],
              showStatusBar: true),
          Expanded(
            child: Center(
              child: PinchZoomImage(
                  onZoomEnd: () {},
                  onZoomStart: () {},
                  image: Image.network(
                    widget.imageUrl,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Image(
                        image: ImageRes.noImageFound,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 2.5,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return SizedBox(
                          width: 50,
                          height: 50,
                          child: const Center(
                              child: CupertinoActivityIndicator()));
                    },
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
