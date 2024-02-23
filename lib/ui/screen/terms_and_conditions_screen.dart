import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/theming.dart';
import 'package:rate_review/util/string_resource.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  _TermsAndConditionsScreenState createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  bool isLoading = true;


  @override
  Widget build(BuildContext buildContext) {
    return Material(
      child: Column(
        children: [
          ... AppToolbar(context,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Get.back(),
                  child: const Icon(
                    CupertinoIcons.clear,
                    color: CupertinoColors.white,
                  ),
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          resource.termsAndConditionTitle.tr.toUpperCase(),
                          style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              letterSpacing: 4.0),
                        ))),
              ],
              showStatusBar: true),
          Expanded(
            child: Scaffold(
                backgroundColor: backgroundColor,
                body: Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(url: Uri.parse(resource.termsAndCondition.tr)),
                      // TODO TC Url
                      initialUserScripts: UnmodifiableListView<UserScript>([]),
                      initialOptions: options,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) {
                        /*setState(() {
                                          this.url = url.toString();
                                          urlController.text = this.url;
                                        });*/
                      },
                      androidOnPermissionRequest: (controller, origin, resources) async {
                        return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      onLoadError: (controller, url, code, message) {
                        /*pullToRefreshController.endRefreshing();*/
                      },
                      onProgressChanged: (controller, progress) {
                        /*if (progress == 100) {
                                          pullToRefreshController.endRefreshing();
                                        }
                                        setState(() {
                                          this.progress = progress / 100;
                                          urlController.text = this.url;
                                        });*/
                      },
                      onUpdateVisitedHistory: (controller, url, androidIsReload) {
                        /*setState(() {
                                          this.url = url.toString();
                                          urlController.text = this.url;
                                        });*/
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        log('consoleMessage $consoleMessage');
                      },
                    ),


                    isLoading ? Center(child: Platform.isIOS? const CupertinoActivityIndicator(): const CircularProgressIndicator()) : Stack(),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
