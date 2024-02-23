import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/theming.dart';

class WebViewScreen extends StatefulWidget {
  final String webUrl;

  const WebViewScreen({Key? key, required this.webUrl}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
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
          ...AppToolbar(buildContext,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async => await webViewController!.canGoBack()
                      ? webViewController!.goBack()
                      : Get.back(),
                  child: const Icon(CupertinoIcons.back,
                      color: CupertinoColors.white, size: 37),
                ),
              ],
              showStatusBar: true),
          Expanded(
            child: Scaffold(
                backgroundColor: backgroundColor,
                body: Stack(
                  children: <Widget>[
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest:
                          URLRequest(url: Uri.parse(widget.webUrl)),
                      initialUserScripts: UnmodifiableListView<UserScript>([]),
                      initialOptions: options,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) {},
                      androidOnPermissionRequest:
                          (controller, origin, resources) async {
                        return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      onLoadError: (controller, url, code, message) {},
                      onProgressChanged: (controller, progress) {},
                      onUpdateVisitedHistory:
                          (controller, url, androidIsReload) {},
                      onConsoleMessage: (controller, consoleMessage) {
                      },
                    ),
                    isLoading
                        ? Center(
                            child: Platform.isIOS
                                ? const CupertinoActivityIndicator()
                                : const CircularProgressIndicator())
                        : Stack(),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
