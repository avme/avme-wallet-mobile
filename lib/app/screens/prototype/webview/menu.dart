// @dart=2.12
import 'dart:convert';
import 'dart:typed_data';

import 'package:avme_wallet/app/controller/web/web_utils.dart';
import 'package:avme_wallet/app/controller/web/webview.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/app_hint.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
enum MenuOptions {
  devPage,
  injectJS,
  favoritePage,
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
  doPostRequest,
  loadLocalFile,
  loadFlutterAsset,
  loadHtmlString,
  transparentBackground,
  setCookie,
}

class WebMenu extends StatelessWidget {
  WebMenu(
    this.controller,
    CookieManager? cookieManager,
    this.appWebViewController
  ) : cookieManager = cookieManager ?? CookieManager();

  final AppWebViewController appWebViewController;
  final Future<WebViewController> controller;
  late final CookieManager cookieManager;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: controller,
        builder: (BuildContext context, AsyncSnapshot<WebViewController> controller) {
          bool favorited = false;
          if(controller.hasData)
          {
            Favorites _f = Favorites();
            _f.getSites().then((List sites) async{
              String title = await controller.data!.getTitle() ?? "";
              if(title.length == 0)
                return;
              sites.forEach((mapItem) {
                favorited = mapItem.containsKey(title);
              });
            });
          }
          return PopupMenuButton<MenuOptions>(
            key: const ValueKey<String>("ShowPopupMenu"),
            icon: Icon(
              Icons.menu_rounded,
              color: AppColors.labelDefaultColor,
              size: 26,
            ),
            onSelected: (MenuOptions value) {
              switch (value) {
                case MenuOptions.favoritePage:
                  _favoritePage(controller.data!, context);
                  break;
                case MenuOptions.devPage:
                  _onLoadLocalFileExample(controller.data!, context);
                  break;
                case MenuOptions.injectJS:
                  controller.data!.runJavascript('''
                (function(){
                  let c = confirm("Injecting...");
                  if(c)
                  {
                    alert("Result was: " + c);
                  }     
                })();
                ''');
                  break;
                case MenuOptions.showUserAgent:
                  _onShowUserAgent(controller.data!, context);
                  break;
                case MenuOptions.listCookies:
                  _onListCookies(controller.data!, context);
                  break;
                case MenuOptions.clearCookies:
                  _onClearCookies(context);
                  break;
                case MenuOptions.addToCache:
                  _onAddToCache(controller.data!, context);
                  break;
                case MenuOptions.listCache:
                  _onListCache(controller.data!, context);
                  break;
                case MenuOptions.clearCache:
                  _onClearCache(controller.data!, context);
                  break;
              // case MenuOptions.navigationDelegate:
              //   _onNavigationDelegateExample(controller.data!, context);
              //   break;
                case MenuOptions.doPostRequest:
                  _onDoPostRequest(controller.data!, context);
                  break;
                case MenuOptions.loadLocalFile:
                  _onLoadLocalFileExample(controller.data!, context);
                  break;
                case MenuOptions.loadFlutterAsset:
                  _onLoadFlutterAssetExample(controller.data!, context);
                  break;
              // case MenuOptions.loadHtmlString:
              //   _onLoadHtmlStringExample(controller.data!, context);
              //   break;
              // case MenuOptions.transparentBackground:
              //   _onTransparentBackground(controller.data!, context);
              //   break;
                case MenuOptions.setCookie:
                  _onSetCookie(controller.data!, context);
                  break;
                case MenuOptions.navigationDelegate:
                // TODO: Handle this case.
                  break;
                case MenuOptions.loadHtmlString:
                // TODO: Handle this case.
                  break;
                case MenuOptions.transparentBackground:
                // TODO: Handle this case.
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
              PopupMenuItem<MenuOptions>(
                value: MenuOptions.favoritePage,
                child: const Text('Favorite Page'),
                enabled: !favorited,
              ),
              PopupMenuItem<MenuOptions>(
                value: MenuOptions.devPage,
                child: const Text('Dev Page'),
                enabled: controller.hasData,
              ),
              PopupMenuItem<MenuOptions>(
                value: MenuOptions.injectJS,
                child: const Text('Inject JavaScript'),
                enabled: controller.hasData,
              ),
              PopupMenuItem<MenuOptions>(
                value: MenuOptions.showUserAgent,
                child: const Text('Show user agent'),
                enabled: controller.hasData,
              ),
              const PopupMenuItem<MenuOptions>(
                value: MenuOptions.listCookies,
                child: Text('List cookies'),
              ),
              const PopupMenuItem<MenuOptions>(
                value: MenuOptions.clearCookies,
                child: Text('Clear cookies'),
              ),
              const PopupMenuItem<MenuOptions>(
                value: MenuOptions.addToCache,
                child: Text('Add to cache'),
              ),
              const PopupMenuItem<MenuOptions>(
                value: MenuOptions.listCache,
                child: Text('List cache'),
              ),
              const PopupMenuItem<MenuOptions>(
                value: MenuOptions.clearCache,
                child: Text('Clear cache'),
              ),
              const PopupMenuItem<MenuOptions>(
                value: MenuOptions.navigationDelegate,
                child: Text('Navigation Delegate example'),
              ),
              const PopupMenuItem<MenuOptions>(
                value: MenuOptions.doPostRequest,
                child: Text('Post Request'),
              ),
              const PopupMenuItem<MenuOptions>(
                value: MenuOptions.loadHtmlString,
                child: Text('Load HTML string'),
              ),
              const PopupMenuItem<MenuOptions>(
                value: MenuOptions.loadLocalFile,
                child: Text('Load local file'),
              ),
              const PopupMenuItem<MenuOptions>(
                value: MenuOptions.loadFlutterAsset,
                child: Text('Load Flutter Asset'),
              ),
              const PopupMenuItem<MenuOptions>(
                key: ValueKey<String>('ShowTransparentBackgroundExample'),
                value: MenuOptions.transparentBackground,
                child: Text('Transparent background example'),
              ),
              const PopupMenuItem<MenuOptions>(
                value: MenuOptions.setCookie,
                child: Text('Set cookie'),
              ),
            ],
          );
        }
    );
  }

  Future<void> _onShowUserAgent(
      WebViewController controller, BuildContext context) async {
    // Send a message with the user agent string to the Toaster JavaScript channel we registered
    // with the WebView.
    await controller.runJavascript(
        'Toaster.postMessage("User Agent: " + navigator.userAgent);');
  }

  Future<void> _onListCookies(
      WebViewController controller, BuildContext context) async {
    final String cookies =
    await controller.runJavascriptReturningResult('document.cookie');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Cookies:'),
          _getCookieList(cookies),
        ],
      ),
    ));
  }

  Future<void> _onAddToCache(
      WebViewController controller, BuildContext context) async {
    await controller.runJavascript(
        'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  Future<void> _onListCache(
      WebViewController controller, BuildContext context) async {
    await controller.runJavascript('caches.keys()'
        '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
        '.then((caches) => Toaster.postMessage(caches))');
  }

  Future<void> _onClearCache(
      WebViewController controller, BuildContext context) async {
    await controller.clearCache();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Cache cleared.'),
    ));
  }

  Future<void> _onClearCookies(BuildContext context) async {
    final bool hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies.';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> _onSetCookie(
      WebViewController controller, BuildContext context) async {
    await cookieManager.setCookie(
      const WebViewCookie(
          name: 'foo', value: 'bar', domain: 'httpbin.org', path: '/anything'),
    );
    await controller.loadUrl('https://httpbin.org/anything');
  }

  Future<void> _onDoPostRequest(
      WebViewController controller, BuildContext context) async {
    final WebViewRequest request = WebViewRequest(
      uri: Uri.parse('https://httpbin.org/post'),
      method: WebViewRequestMethod.post,
      headers: <String, String>{'foo': 'bar', 'Content-Type': 'text/plain'},
      body: Uint8List.fromList('Test Body'.codeUnits),
    );
    await controller.loadRequest(request);
  }

  Future<void> _onLoadLocalFileExample(
      WebViewController controller, BuildContext context) async {
    String fileText = await rootBundle.loadString('assets/www/index.html');
    controller.loadUrl( Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  Future<void> _onLoadFlutterAssetExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadFlutterAsset('assets/www/index.html');
  }

  Widget _getCookieList(String cookies) {
    if (cookies == null || cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets =
    cookieList.map((String cookie) => Text(cookie));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
    );
  }

  Future<void> _favoritePage(
      WebViewController webViewController,
      BuildContext context
      ) async {

    String title = await webViewController.getTitle() ?? "Default Title";
    String url = await webViewController.currentUrl() ?? "www.google.com";

    Favorites _f = Favorites();
    await _f.add(title, url);
    appWebViewController.forceBrowserUpdateWidgets();
    await Future.delayed(const Duration(milliseconds: 50));
    AppHint.show("Added Site to Favorites!", position: AppHintPosition.TOP);
  }
}