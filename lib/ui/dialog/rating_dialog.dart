library rating_dialog;

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/ui/dialog/rating_bar.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../util/theming.dart';

class RatingDialog extends StatefulWidget {
  final String title, message;
  final Widget image;
  final Color ratingColor;
  final bool force;
  bool enableComment = false;
  int initialRating;
  final String submitButton;
  final Function(RatingDialogResponse) onSubmitted;

  final Function onCancelled;

  RatingDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.image,
    required this.submitButton,
    required this.onSubmitted,
    this.ratingColor = Colors.orange,
    required this.onCancelled,
    this.force = false,
    this.initialRating = 0,
  }) : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  @override
  Widget build(BuildContext context) {
    final _commentController = TextEditingController();
    final _response = RatingDialogResponse(rating: widget.initialRating);

    final _content = Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                widget.image != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: widget.image,
                      )
                    : Container(),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                widget.message != null
                    ? Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      )
                    : Container(),
                const SizedBox(height: 10),
                if (widget.enableComment)
                  Column(
                    children: [
                      TextField(
                        controller: _commentController,
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: resource.writeFeedback.tr,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 50),
                        child: GestureDetector(
                          onTap: () async {
                            if (!widget.force) Navigator.pop(context);
                            _response.comment = _commentController.text;
                            widget.onSubmitted.call(_response);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  btnEndColor,
                                  btnStartColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 1),
                                child: Text(
                                  widget.submitButton,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      letterSpacing: 2,
                                      fontFamily: narrowbold,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      /*TextButton(
                            child: Text(widget.submitButton,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: normalFontSize,
                              ),
                            ),
                            onPressed: () async {
                              if (!widget.force) Navigator.pop(context);
                              _response.comment = _commentController.text;
                              widget.onSubmitted.call(_response);
                            },
                          )*/
                    ],
                  )
                else
                  Column(
                    children: [
                      Center(
                        child: RatingBar.builder(
                          initialRating: widget.initialRating.toDouble(),
                          glowColor: widget.ratingColor,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemPadding: EdgeInsets.zero,
                          onRatingUpdate: (rating) {
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              setState(() {
                                Uri url = Uri.parse("https://buzzle.cc");
                                if (Platform.isIOS) {
                                  url = Uri.parse("https://apps.apple.com/app/id378458261");
                                } else if (Platform.isAndroid) {
                                  url = Uri.parse("https://play.google.com/store/apps/details?id=com.rating.buzzle");
                                }
                                launchUrl(url);
                                Navigator.of(context).pop();
                                // if (canLaunch(url)) {
                                //    launchUrl(url);
                                // } else {
                                //    throw "Could not launch $url";
                                // }
                                //Navigator.of(context).pop();

                                // NativeCall().launchStore();

                                widget.initialRating = rating.toInt();
                              });
                              _response.rating = widget.initialRating;
                            });
                          },
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            size: 20,
                            color: widget.ratingColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 10))
              ],
            ),
          ),
        ),
        if (!widget.force && widget.onCancelled != null) ...[
          IconButton(
            splashColor: Colors.black26,
            icon: const Icon(Icons.close, size: 30),
            onPressed: () {
              Navigator.pop(context);
              widget.onCancelled.call();
            },
          )
        ]
      ],
    );

    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        titlePadding: EdgeInsets.zero,
        scrollable: true,
        title: _content,
      ),
    );
  }
}

class RatingDialogResponse {
  String comment = '';
  int rating;

  RatingDialogResponse({required this.rating});
}
