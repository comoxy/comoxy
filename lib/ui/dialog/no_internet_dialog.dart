import 'package:flutter/material.dart';

import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';

class NoInternetDialog extends StatefulWidget {
  final Function? onCloseTap;
  const NoInternetDialog({Key? key, this.onCloseTap}) : super(key: key);

  @override
  _NoInternetDialogState createState() => _NoInternetDialogState();
}

class _NoInternetDialogState extends State<NoInternetDialog> {

  ImageProvider noInternetImage = const AssetImage("assets/images/no_internet.png");

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
              Image(image: noInternetImage, height: 200, width: 200,),

              // Text(
              //   /*internetConnectionTitle*/'No Internet',
              //   style: TextStyle(
              //     fontSize: 20,
              //     color: Colors.black,
              //     fontWeight: FontWeight.bold,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              Text('check_internet_connection'.tr, //'Please check your connection status and try again',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  // fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),


              Container(
                margin: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onCloseTap != null) widget.onCloseTap!();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    // onPrimary: Colors.blueAccent[500],
                    primary: Colors.transparent,
                    // minimumSize: Size(88, 36),
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [primaryColor, primaryColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 200.0, minHeight: 40.0),
                      alignment: Alignment.center,
                      child: Text(
                        resource.close.toUpperCase().tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
