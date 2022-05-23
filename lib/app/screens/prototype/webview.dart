// @dart=2.12

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:avme_wallet/app/controller/web/web_utils.dart';
import 'package:avme_wallet/app/controller/web_requests.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

// import 'exemple.dart';

void initWebView(BuildContext context)
{
  Navigator.push(context, MaterialPageRoute(builder: (context) => AppWebView()));
  // // showDialog(context: context, builder:(_) =>
  // // StatefulBuilder(builder: (builder, setState) => AppWebView()));
  //
  // showGeneralDialog(
  //   context: context,
  //   pageBuilder: (context, anim1, anim2) {
  //     return StatefulBuilder(builder: (builder, setState) => AppWebView());
  //   },
  //   barrierDismissible: true,
  //   barrierLabel: '',
  //   barrierColor: Colors.black.withOpacity(0.4),
  //   transitionBuilder: (context, anim1, anim2, widget) {
  //
  //     const begin = Offset(0.0, 1.0);
  //     const end = Offset.zero;
  //     const curve = Curves.ease;
  //     var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  //     return SlideTransition(
  //       position: anim1.drive(tween),
  //       child: widget,
  //     );
  //   },
  //   transitionDuration: Duration(milliseconds: 200)
  // );

}

class AppWebView extends StatefulWidget {
  const AppWebView({this.cookieManager});
  final CookieManager? cookieManager;

  @override
  _AppWebViewState createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {

  TextEditingController _urlController = TextEditingController(
    text: "https://www.google.com.br"
  );

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  bool canGoBack = false;
  bool canGoFoward = false;
  late String jsContent;
  late JavascriptChannel ethereumProvider;
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    ethereumProvider = ethereumChannel(context);
  }

  Future preLoad() async
  {
    Future.wait([
      assignJsContent()
    ]);
  }

  Future assignJsContent() async {
    String content =  await rootBundle.loadString("assets/www/js/index.js");
    jsContent = '''
      try
      {
        var avme = $content;
        let script = document.createElement('script');
        script.setAttribute('type', 'text/javascript');
        script.innerText = avme;
        script.onload = function (){ this.remove() };
        document.head ? document.head.prepend(script) : document.documentElement.prepend(script);      
      }
      catch (e) {console.error('[AVME Extension] Error: ', e)}
    ''';
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius _borderR = BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16)
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: FutureBuilder(
        future: preLoad(),
        builder: (context, snapshot) {
          return Container(
            child: Column(
              children: [
                Colored(flex: 1, color: Colors.black45,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                ///WebView Area
                Expanded(flex: 14,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue,
                      borderRadius: _borderR
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0,
                              // bottom: 8.0,
                              left: 8.0,
                              right: 8.0
                            ),
                            child: Container(
                              // color: Colors.white10,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:
                                  <Widget>[] +
                                  [ NavigationControls(_controller.future, canGoBack: canGoBack, canGoFoward: canGoFoward) ] +
                                  getURLBar() +
                                  [ ReloadPage(_controller.future) ] +
                                  [ WebMenu(_controller.future, widget.cookieManager) ]
                                // ..add(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: _borderR,
                                color: Colors.black12
                              ),
                              child: appWebView(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  WebView appWebView()
  {

    return WebView(
      initialUrl: _urlController.text,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController)
      {
        _controller.complete(webViewController);
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
        canGoBack = await controller.canGoBack();
        canGoFoward = await controller.canGoForward();
        setState(() {});
        controller.runJavascript(jsContent);
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

  List<Widget> getURLBar()
  {
    return [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: TextFormField(
            controller: _urlController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black12,
              // fillColor: AppColors.purpleDark2,
              contentPadding: EdgeInsets.all(4),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ),
      )
    ];
  }

  List<Widget> reloadPage()
  {
    return [
      GestureDetector(
        onTap: () {
          NotificationBar().show(context, text: "Reload Page");
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            // color: Colors.red.withAlpha(60),
            child: SizedBox(
              // width: 32,
              height: 32,
              child: Icon(
                Icons.replay_rounded,
                color: AppColors.labelDefaultColor,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

class ReloadPage extends StatelessWidget {
  const ReloadPage(this._webViewControllerFuture);
  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _webViewControllerFuture,
      builder: (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController? controller = snapshot.data;
        return GestureDetector(
          onTap: !webViewReady ? null : () {
            controller!.reload();
            // controller!.runJavascript('window.postMessage({"type":"eth:emit", "emit":"eth_accounts", "payload":{"jsonrpc":"2.0","result":[]}})');
          },

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              // color: Colors.red.withAlpha(60),
              child: SizedBox(
                // width: 32,
                height: 32,
                child: Icon(
                  Icons.replay_rounded,
                  color: AppColors.labelDefaultColor,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture, {required this.canGoBack, required this.canGoFoward});

  final Future<WebViewController> _webViewControllerFuture;
  final bool canGoBack;
  final bool canGoFoward;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder: (BuildContext context, AsyncSnapshot<WebViewController> snapshot)
      {
        final bool webViewReady =
          snapshot.connectionState == ConnectionState.done;
        final WebViewController? controller = snapshot.data;
        return Row(
          children: <Widget>[
            GestureDetector(
              onTap: !webViewReady ? null : () async {
                if (await controller!.canGoBack()) {
                  await controller.goBack();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No back history item')),
                  );
                  return;
                }
              },
              child: Container(
                // color: Colors.red.withAlpha(60),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: SizedBox(
                    width: 20,
                    height: 32,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: canGoBack ? AppColors.labelDefaultColor : AppColors.labelDisabledColor,
                      size: 20,
                    )
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: !webViewReady ? null : () async {
                if (await controller!.canGoForward()) {
                  await controller.goForward();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('No forward history item')),
                  );
                  return;
                }
              },
              child: Container(
                // color: Colors.blue.withAlpha(60),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: SizedBox(
                    // width: 32,
                    height: 32,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: canGoFoward ? AppColors.labelDefaultColor : AppColors.labelDisabledColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}

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
  WebMenu(this.controller, CookieManager? cookieManager)
      : cookieManager = cookieManager ?? CookieManager();

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

  // Future<void> _onNavigationDelegateExample(
  //     WebViewController controller, BuildContext context) async {
  //   final String contentBase64 =
  //   base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
  //   await controller.loadUrl('data:text/html;base64,$contentBase64');
  // }

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

  // Future<void> _onLoadDevPage(
  //     WebViewController controller, BuildContext context) async {
  //   final String pathToIndex = await _prepareLocalFile();
  //   printApprove(pathToIndex);
  //   await controller.loadFile(pathToIndex);
  // }

  Future<void> _onLoadFlutterAssetExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadFlutterAsset('assets/www/index.html');
  }

  // Future<void> _onLoadHtmlStringExample(
  //     WebViewController controller, BuildContext context) async {
  //   await controller.loadHtmlString(kLocalExamplePage);
  // }
  //
  // Future<void> _onTransparentBackground(
  //     WebViewController controller, BuildContext context) async {
  //   await controller.loadHtmlString(kTransparentBackgroundPage);
  // }

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
    _f.add(title, url);
    // Map favoritesList = await _f.getSites();
    // if(favoritesList.containsKey(title)) {
    //   NotificationBar().show(context, text: );
    //   return;
    // }
  }

  // static Future<String> _prepareLocalFile() async {
  //   final String tmpDir = (await getTemporaryDirectory()).path;
  //   final File indexFile = File(
  //       <String>{tmpDir, 'www', 'index.html'}.join(Platform.pathSeparator));
  //
  //   await indexFile.create(recursive: true);
  //   await indexFile.writeAsString(kLocalExamplePage);
  //
  //   return indexFile.path;
  // }
}


class Colored extends StatelessWidget {
  final flex;
  final Color color;
  final Widget? child;
  const Colored({Key? key, required this.flex, required this.color, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: this.flex,
      child: Container(
        color: this.color,
        child: this.child ?? Container(),
      ),
    );
  }
}