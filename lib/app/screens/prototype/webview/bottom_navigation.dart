// @dart=2.12
import 'dart:async';

import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({
    required this.browserUtility,
    required this.index,
    required this.historyStream,
    required this.controller,
  });

  final int index;
  final StreamController<int> browserUtility;
  final Stream<Map> historyStream;
  final Future<WebViewController> controller;

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {

  late Future<bool> bottomNavigation;
  late WebViewController webViewController;
  @override
  void initState() {
    bottomNavigation = _bottomNavigation();
    super.initState();
  }

  Future<bool> _bottomNavigation()
  async {
    webViewController = await widget.controller;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Container(
        color: AppColors.darkBlue,
        child: FutureBuilder<bool>(
          future: bottomNavigation,
          builder: (context, snapWeb) {
            final bool webViewReady =
              snapWeb.connectionState == ConnectionState.done;
            // WebViewController? webViewController = snapWeb.data;
            return Container(
              child: StreamBuilder<Map>(
                  stream: widget.historyStream,
                  builder: (context, snapshot) {
                    List<Widget> navigation = [];
                    if(snapshot.data == null)
                      navigation.addAll([
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.arrow_back,
                              color: AppColors.labelDisabledColor,
                              size: SizeConfig.safeBlockHorizontal * 8,
                            )
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward,
                              color: AppColors.labelDisabledColor,
                              size: SizeConfig.safeBlockHorizontal * 8,
                            )
                          ),
                        ),
                      ]
                    );
                    else {
                      bool canGoBack = snapshot.data!["canGoBack"];
                      bool canGoForward = snapshot.data!["canGoForward"];
                      navigation.addAll([
                        Expanded(
                          child: Container(
                            // color: Colors.red,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: canGoBack ? () {
                                if(webViewReady) {
                                  NotificationBar().show(context, text: "Going back");
                                  webViewController.goBack();
                                }
                              } : null,
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back,
                                  color: canGoBack ? AppColors.violet : AppColors.labelDisabledColor,
                                  size: SizeConfig.safeBlockHorizontal * 8,
                                )
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            // color: Colors.blue,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: canGoForward ? () {
                                if(webViewReady) {
                                  NotificationBar().show(context, text: "Going forward");
                                  webViewController.goForward();
                                }
                              } : null,
                              child: Center(
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: canGoForward ? AppColors.violet : AppColors.labelDisabledColor,
                                  size: SizeConfig.safeBlockHorizontal * 8,
                                )
                              ),
                            ),
                          ),
                        ),
                      ]);
                    }
                    return Row(
                      children: navigation + [
                        Expanded(
                          flex: 3,
                          child: Container(
                            // color: Colors.green,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              NotificationBar().show(context, text: "Redirecting to the Dashboard");
                              if(widget.index != 0)
                                widget.browserUtility.add(0);
                            },
                            child: Center(
                                child: Icon(
                                  Icons.home,
                                  color: AppColors.violet,
                                  size: SizeConfig.safeBlockHorizontal * 8,
                                )
                            ),
                          ),
                        ),
                      ],
                    );
                  }
              ),
            );
          }
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Flexible(
  //     flex: 1,
  //     child: Container(
  //       color: AppColors.darkBlue,
  //       child: StreamBuilder<Map>(
  //         stream: widget.historyStream,
  //         builder: (context, snapshot) {
  //           return Row(
  //             children: [
  //               Expanded(
  //                 child: Container(
  //                   // color: Colors.red,
  //                   child: GestureDetector(
  //                     behavior: HitTestBehavior.translucent,
  //                     onTap:
  //                       snapshot.data!["canGoBack"] == true
  //                       ? () {
  //                         NotificationBar().show(context, text: "Going back");
  //                       }
  //                       : null,
  //                     child: Center(
  //                       child: Icon(
  //                         Icons.arrow_back,
  //                         color: AppColors.violet,
  //                         size: SizeConfig.safeBlockHorizontal * 8,
  //                       )
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Container(
  //                   // color: Colors.blue,
  //                   child: GestureDetector(
  //                     behavior: HitTestBehavior.translucent,
  //                     onTap: () {
  //                       NotificationBar().show(context, text: "Going forward");
  //                     },
  //                     child: Center(
  //                       child: Icon(
  //                         Icons.arrow_forward,
  //                         color: AppColors.violet,
  //                         size: SizeConfig.safeBlockHorizontal * 8,
  //                       )
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 3,
  //                 child: Container(
  //                   // color: Colors.green,
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 1,
  //                 child: GestureDetector(
  //                   behavior: HitTestBehavior.translucent,
  //                   onTap: () {
  //                     NotificationBar().show(context, text: "Redirecting to the Dashboard");
  //                     if(widget.index != 0)
  //                       widget.browserUtility.add(0);
  //                   },
  //                   child: Center(
  //                     child: Icon(
  //                       Icons.home,
  //                       color: AppColors.violet,
  //                       size: SizeConfig.safeBlockHorizontal * 8,
  //                     )
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           );
  //         }
  //       ),
  //     ),
  //   );
  // }
}
