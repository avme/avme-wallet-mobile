// @dart=2.12
import 'dart:async';

import 'package:avme_wallet/app/screens/prototype/widgets/app_hint.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

import 'package:webview_flutter/webview_flutter.dart';

class Discover extends StatefulWidget {

  const Discover({
    required this.verticalButtons,
    required this.horizontalButtons,
    required this.browserUtility,
    required this.browserIndexController,
    required this.browserController
  });

  final double verticalButtons;
  final double horizontalButtons;
  final StreamController<int> browserUtility;
  final StreamController browserIndexController;
  final Future<WebViewController> browserController;

  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {

  late Future<bool> discover;
  late WebViewController webViewController;

  @override
  void initState() {
    discover = _discover();
    super.initState();
  }

  Future<bool> _discover()
  async {
    webViewController = await widget.browserController;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      // shrinkWrap: true,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: 32.0,
              right: 32.0,
              top: widget.horizontalButtons
            // top: 64,
          ),
          child: FutureBuilder<bool>(
            future: discover,
            builder: (context, snapshot) {
              bool ready = snapshot.connectionState == ConnectionState.done;
              return Container(
                // color: Colors.red,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: AppDarkIconButton(
                        onPressed: ready ? () {
                          widget.browserIndexController.add(1);
                          webViewController.loadUrl('https://app.pangolin.exchange/#/swap?outputCurrency=0x1ECd47FF4d9598f89721A2866BFEb99505a413Ed');
                        } : null,
                        text: Text("BUY \$AVME",style: TextStyle(color: AppColors.labelDefaultColor),),
                        icon: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Icon(Icons.shopping_cart, color: AppColors.labelDefaultColor)
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        AppDarkIconButton(
                          onPressed: ready ? () {
                            widget.browserIndexController.add(1);
                            webViewController.loadUrl('https://app.pangolin.exchange/');
                          } : null,
                          alignment: Alignment.centerLeft,
                          text: Text("PANGOLIN",style: TextStyle(color: AppColors.labelDefaultColor),),
                          icon: FaIcon(FontAwesomeIcons.globeEurope, color: AppColors.labelDefaultColor, size: 18,),
                        ),
                        AppDarkIconButton(
                          onPressed: ready ? () {
                            widget.browserIndexController.add(1);
                            webViewController.loadUrl('https://www.snowball.network/');
                          } : null,
                          alignment: Alignment.centerLeft,
                          text: FittedBox(child: Text("SNOWBALL\nFINANCE",style: TextStyle(color: AppColors.labelDefaultColor),)),
                          icon: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: FaIcon(FontAwesomeIcons.exchangeAlt, color: AppColors.labelDefaultColor, size: 18,)
                          ),
                        ),
                      ].asMap().map((int key, Widget element) {
                        if(key == 0)
                          return MapEntry(
                            key,
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.only(right: widget.verticalButtons),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: element,
                                ),
                              ),
                            )
                          );
                        return MapEntry(
                          key,
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(left: widget.verticalButtons),
                              child: SizedBox(
                                width: double.infinity,
                                child: element,
                              ),
                            ),
                          )
                        );
                      }).values.toList(),
                    ),
                    Row(
                      children: [
                        AppDarkIconButton(
                          onPressed: ready ? () {
                            widget.browserIndexController.add(1);
                            webViewController.loadUrl('https://traderjoexyz.com/');
                          } : null,
                          alignment: Alignment.centerLeft,
                          text: Text("TRADER JOE",style: TextStyle(color: AppColors.labelDefaultColor),),
                          icon: FaIcon(FontAwesomeIcons.solidHandshake, color: AppColors.labelDefaultColor, size: 18,),
                        ),
                        AppDarkIconButton(
                          onPressed: ready ? () {
                            widget.browserIndexController.add(1);
                            webViewController.loadUrl('https://yieldyak.com/');
                          } : null,
                          alignment: Alignment.centerLeft,
                          text: FittedBox(child: Text("YIELD YAC",style: TextStyle(color: AppColors.labelDefaultColor),)),
                          icon: FaIcon(FontAwesomeIcons.moneyBillWave,  color: AppColors.labelDefaultColor, size: 18,),
                        ),
                      ].asMap().map((int key, Widget element) {
                        if(key == 0)
                          return MapEntry(
                            key,
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.only(right: widget.verticalButtons),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: element,
                                ),
                              ),
                            )
                          );
                        return MapEntry(
                          key,
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(left: widget.verticalButtons),
                              child: SizedBox(
                                width: double.infinity,
                                child: element,
                              ),
                            ),
                          )
                        );
                      }).values.toList(),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: AppDarkIconButton(
                        onPressed: () {
                          NotificationBar().show(context, text: "Not implemented");
                        },
                        text: Text("HOW DOES THIS WORK?",style: TextStyle(color: AppColors.labelDefaultColor),),
                        icon: FaIcon(FontAwesomeIcons.solidQuestionCircle, color: AppColors.labelDefaultColor, size: 18,),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        onPressed: () {  },
                        child: Text("gay"),
                      ),
                    ),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: AppDarkIconButton(
                    //     onPressed: () {
                    //       AppHint.show("app hint 1");
                    //     },
                    //     text: Text("app hint 1",style: TextStyle(color: AppColors.labelDefaultColor),),
                    //     icon: FaIcon(FontAwesomeIcons.solidQuestionCircle, color: AppColors.labelDefaultColor, size: 18,),
                    //   ),
                    // ),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: AppDarkIconButton(
                    //     onPressed: () {
                    //       AppHint.show("app hint 2", position: AppHintPosition.TOP);
                    //     },
                    //     text: Text("app hint 2",style: TextStyle(color: AppColors.labelDefaultColor),),
                    //     icon: FaIcon(FontAwesomeIcons.solidQuestionCircle, color: AppColors.labelDefaultColor, size: 18,),
                    //   ),
                    // ),
                  ].map((Widget element) =>
                    Padding(
                      child: element,
                      padding: EdgeInsets.only(bottom: widget.horizontalButtons),
                    )
                  ).toList(),
                ),
              );
            }
          ),
        ),
      ],
    );
  }
}