// @dart=2.12

import 'dart:async';

import 'package:avme_wallet/app/lib/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebViewController{

  static final AppWebViewController _appWebViewController = AppWebViewController._internal();

  AppWebViewController._internal();
  String _initialUrl = 'https://www.google.com';
  Completer<WebViewController> _controller = Completer<WebViewController>();
  CookieManager? _cookieManager;
  StreamController onPageStartedController = StreamController.broadcast();
  StreamController<Map> onHistoryController = StreamController.broadcast();
  StreamController<bool> loadingIndicatorController = StreamController.broadcast();
  WebViewController? _internalController;

  static AppWebViewController getInstance()
  {
    return _appWebViewController;
  }

  void initialize(WebViewController controller, CookieManager? cookieManager)
  {
    if(!_controller.isCompleted) {
      _controller.complete(controller);
      _internalController = controller;
    } else {
      _controller = Completer<WebViewController>()..complete(controller);
    }
  }

  Completer<WebViewController> get controller => _controller;

  get cookieManager => _cookieManager;
  get initialUrl => _initialUrl;

  Stream get onPageStarted => onPageStartedController.stream.asBroadcastStream();
  Stream<Map> get onHistory => onHistoryController.stream.asBroadcastStream();
  Stream<bool> get isLoading => loadingIndicatorController.stream.asBroadcastStream();

  void streamOnPageStarted(String url)
  {
    onPageStartedController.add(url);
  }

  void streamIsPageLoading(bool isLoading)
  {
    loadingIndicatorController.add(isLoading);
  }

  Future updateHistoryControls()
  async {
    try
    {
      WebViewController webViewController = _internalController!;
      bool canGoBack = await webViewController.canGoBack();
      bool canGoForward = await webViewController.canGoForward();
      Map data = {"canGoBack" : canGoBack, "canGoForward" : canGoForward};
      onHistoryController.add(data);
    }
    catch(e)
    {
      printError("$e");
    }
  }

  void updateController(Completer<WebViewController> newController) {
    _controller = newController;
  }

  void dispose()
  {
    onPageStartedController.close();
    onPageStartedController = StreamController.broadcast();
    onHistoryController.close();
    onHistoryController = StreamController.broadcast();
    _controller = Completer<WebViewController>();
  }
}