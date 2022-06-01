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
  StreamController _onPageStartedController = StreamController.broadcast();
  StreamController<Map> _onHistoryController = StreamController.broadcast();
  StreamController<bool> forceUpdateController = StreamController.broadcast();
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
  get currentController => _internalController;

  Stream get onPageStarted => _onPageStartedController.stream.asBroadcastStream();
  Stream<Map> get onHistory => _onHistoryController.stream.asBroadcastStream();
  Stream<bool> get forceUpdateWidget => forceUpdateController.stream.asBroadcastStream();
  Stream<bool> get isLoading => loadingIndicatorController.stream.asBroadcastStream();

  void streamOnPageStarted(String url)
  {
    _onPageStartedController.add(url);
  }

  void streamIsPageLoading(bool isLoading)
  {
    loadingIndicatorController.add(isLoading);
  }

  void forceBrowserUpdateWidgets()
  {
    printMark("forceUpdateController.add(true);");
    forceUpdateController.add(true);
  }

  Future updateHistoryControls()
  async {
    try
    {
      WebViewController webViewController = _internalController!;
      bool canGoBack = await webViewController.canGoBack();
      bool canGoForward = await webViewController.canGoForward();
      Map data = {"canGoBack" : canGoBack, "canGoForward" : canGoForward};
      _onHistoryController.add(data);
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
    _onPageStartedController.close();
    _onPageStartedController = StreamController.broadcast();
    _onHistoryController.close();
    _onHistoryController = StreamController.broadcast();
    forceUpdateController.close();
    forceUpdateController = StreamController.broadcast();
    _controller = Completer<WebViewController>();
  }
}