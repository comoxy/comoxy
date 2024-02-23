import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rate_review/util/theming.dart';

import '../../util/common.dart';

class ErrorDialog extends StatefulWidget {
  final Function? onCloseTap;
  final String btnName;
  final String title;
  final String message;
  const ErrorDialog({Key? key, this.onCloseTap, required this.title, required this.message, required this.btnName}) : super(key: key);

  @override
  _ErrorDialogState createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {


  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [

              Center(
                child: Text(
                  widget.title,
                  style: TextStyle(fontFamily: narrowbold,height: 1.2,fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(widget.message,
                    style: TextStyle(fontFamily: narrowbook,height: 1.2,fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (widget.onCloseTap != null) widget.onCloseTap!();
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Container(
                    margin: const EdgeInsets.only(left: 10,right: 10,bottom: 15,top: 15),
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
                            vertical: 20.0, horizontal: 1),
                        child:  Text(
                          widget.btnName.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 4,
                              fontFamily: narrowbold,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ));
  }
}
