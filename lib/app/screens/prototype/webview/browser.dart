// @dart=2.12
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:avme_wallet/app/controller/web/webview.dart';
import 'package:avme_wallet/app/controller/web_requests.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'navigation.dart';

class AppBrowser extends StatefulWidget {
  const AppBrowser({
    required this.navigation,
    required this.borderRadius,
    required this.jsContent,
    this.cookieManager,
  });

  final CookieManager? cookieManager;
  final Navigation navigation;
  final BorderRadius borderRadius;

  final String jsContent;

  @override
  _AppBrowserState createState() => _AppBrowserState();
}

class _AppBrowserState extends State<AppBrowser> {

  final Completer<WebViewController> _controller = Completer<WebViewController>();
  late JavascriptChannel ethereumProvider;
  late AppWebViewController appWebViewController;

  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    appWebViewController = AppWebViewController.getInstance();
    ethereumProvider = ethereumChannel(context);
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        widget.navigation,
        Expanded(
          flex: 10,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              color: Colors.black12
            ),
            child: WebView(
              initialUrl: appWebViewController.initialUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController)
              {
                ///Checking if the controller was initialized
                appWebViewController.initialize(webViewController, widget.cookieManager);
                _controller.complete(webViewController);
              },
              onProgress: (int progress) {
                print('WebView is loading (progress : $progress%)');
              },
              javascriptChannels: <JavascriptChannel>{
                ethereumProvider,
              },
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  print('blocking navigation to $request}');
                  return NavigationDecision.prevent;
                }
                print('allowing navigation to $request');
                return NavigationDecision.navigate;
              },
              onPageStarted: (String url) async {
                print('Page started loading: $url');
                appWebViewController.streamOnPageStarted(url);
                await appWebViewController.updateHistoryControls();
                appWebViewController.loadingIndicatorController.add(true);
                WebViewController controller = await _controller.future;
                controller.runJavascript(widget.jsContent);
              },
              onPageFinished: (String url) async {
                print('Page finished loading: $url');
                appWebViewController.loadingIndicatorController.add(false);
              },
              gestureNavigationEnabled: true,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  JavascriptChannel ethereumChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Mobile',
      onMessageReceived: (JavascriptMessage message) {
        printWarning("[ethereumProvider.Mobile] ${message.message}\n");
        try
        {
          Map request = jsonDecode(message.message);
          if(request.length == 0)
            throw "Empty request sent by the EthereumProvider";
          if(request["type"] == "eth:send")
            handleServer(_controller, request["payload"], request["origin"]);
        }
        catch(e) {
          printError("[ethereumProvider.Mobile] Error: $e");
        }
      });
  }
}
