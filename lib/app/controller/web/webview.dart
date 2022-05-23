// @dart=2.12

import 'package:webview_flutter/webview_flutter.dart';

class AppWebViewController{
  static final AppWebViewController _appWebViewController = AppWebViewController._internal();

  AppWebViewController._internal();
  WebViewController? _controller;

  static AppWebViewController getInstance()
  {
    return _appWebViewController;
  }

  void initialize(WebViewController controller)
  {
    _controller = controller;
  }

  get controller => _controller;
  void updateController(WebViewController newController) {
    _controller = newController;
  }

  Future<void> reload() async
  {
    if(ready())
      await _controller!.reload();
  }

  bool ready()
  {
    return _controller != null ? true : false;
  }

  Future<bool> canGoBack() async
  {
    if(ready())
      return await _controller!.canGoBack();
    return false;
  }

  Future<bool> canGoForward() async
  {
    if(ready())
      return await _controller!.canGoForward();
    return false;
  }

  Future<void> loadUrl(String url) async
  {
    if(ready())
      return _controller!.loadUrl(url);
  }
}