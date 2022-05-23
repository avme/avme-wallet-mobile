// @dart=2.12
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:avme_wallet/app/controller/web/webview.dart';
import 'package:avme_wallet/app/controller/web_requests.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppBrowser extends StatefulWidget {
  const AppBrowser({Key? key}) : super(key: key);

  @override
  _AppBrowserState createState() => _AppBrowserState();
}

class _AppBrowserState extends State<AppBrowser> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  late JavascriptChannel ethereumProvider;

  TextEditingController _urlController = TextEditingController(
    text: "https://www.google.com.br"
  );

  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    ethereumProvider = ethereumChannel(context);
  }

  @override
  Widget build(BuildContext context) {
    return  WebView(
      initialUrl: _urlController.text,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController)
      {
        AppWebViewController cWeb = AppWebViewController.getInstance();
        ///Checking if the controller was initialized
        _controller.complete(webViewController);
        cWeb.initialize(webViewController);

        // setState(() async {
        //   canGoBack = await webViewController.canGoBack();
        //   canGoFoward = await webViewController.canGoForward();
        // });
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
        _urlController.text = url;
        WebViewController controller = await _controller.future;
        // canGoBack = await controller.canGoBack();
        // canGoFoward = await controller.canGoForward();
        // setState(() {});
        // controller.runJavascript(jsContent);
      },
      onPageFinished: (String url) async {
        print('Page finished loading: $url');
        // printMark(jsContent);
        // WebViewController webViewController = await _controller.future;
        // webViewController.runJavascript(jsContent);
      },
      gestureNavigationEnabled: true,
      backgroundColor: Colors.white,
    );
  }

  JavascriptChannel ethereumChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Mobile',
      onMessageReceived: (JavascriptMessage message) {
        printWarning("[ethereumProvider.Mobile] ${message.message}");
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

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(message.message)),
        // );
      });
  }
}
