import 'dart:convert';

import 'package:avme_wallet/app/controller/services/contract.dart';
import 'package:avme_wallet/app/controller/services/push_notification.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class DebugOverlay extends StatefulWidget {

  final bool connected;
  final TabController tabController;
  final ConnectivityResult connectionType;
  const DebugOverlay({
    Key key,
    this.connected,
    this.connectionType,
    @required this.tabController
  }) : super(key: key);

  @override
  _DebugOverlayState createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {

  bool shouldDisplay = false;
  ActiveContracts tokens;
  @override
  void initState()
  {
    PushNotification.init();
    listenNotifications();
    super.initState();
    tokens = Provider.of<ActiveContracts>(context, listen: false);
  }

  void listenNotifications()
  {
    PushNotification.onNotifications.stream.listen((payload) {
      print(payload.toString());
      print(ModalRoute.of(context).settings.name);
      if(payload.toString() == "app/overview" && widget.tabController.index != 1)
      {
        widget.tabController.index = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool inDebugMode = Provider.of<AvmeWallet>(context).debugMode;
    if(inDebugMode)
      return Consumer<AvmeWallet>(builder: (context, app, _){
        shouldDisplay = app.debugPanel;
        return GestureDetector(
          onTap: (){
            app.toggleDebugPanel();
          },
          child: _debugPanel(shouldDisplay, app)
        );
      });
    else
      return Container();
  }

  Column _debugPanel(bool shouldDisplay, AvmeWallet app)
  {
    TextStyle textBase = TextStyle(
        fontWeight: FontWeight.normal,
        color: Colors.white
    );
    TextStyle bold = textBase.copyWith(
        fontWeight: FontWeight.bold
    );
    // AvmeWallet app = Provider.of<AvmeWallet>(context);
    MainAxisAlignment mStart = MainAxisAlignment.start;
    CrossAxisAlignment cStart = CrossAxisAlignment.start;

    if(shouldDisplay)
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 12),
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Column(
                      children: [
                        debugTitle("Menu"),
                        Row(
                          crossAxisAlignment: cStart,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(onTap: () async {
                                        AvmeWallet app = Provider.of<AvmeWallet>(context,listen: false);
                                        app.walletManager.requestBalanceFromNetwork(app);
                                      }, child: Text("REQUEST BALANCE (ALL)"))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(onTap: () async {
                                        tokens.addToken("AVME");
                                        tokens.addToken("AVME testnet");
                                      }, child: Text("+TOKEN AVME"))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(onTap: () async {
                                        tokens.addToken("Pangolin");
                                      }, child: Text("+TOKEN PGL"))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(onTap: () async {
                                        tokens.addToken("JoeToken");
                                      }, child: Text("+TOKEN JOE"))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(onTap: () async {
                                        ActiveContracts token = Provider.of<ActiveContracts>(context, listen: false);
                                        token.removeToken("AVME");
                                        token.removeToken("AVME testnet");
                                      }, child: Text("-TOKEN AVME"))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(onTap: () async {
                                        ActiveContracts token = Provider.of<ActiveContracts>(context, listen: false);
                                        token.removeToken("Pangolin");
                                      }, child: Text("-TOKEN PGL"))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(onTap: () async {
                                        ActiveContracts token = Provider.of<ActiveContracts>(context, listen: false);
                                        token.removeToken("JoeToken");
                                      }, child: Text("-TOKEN JOE"))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        debugTitle("Notifications"),
                        Row(
                          crossAxisAlignment: cStart,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(onTap: () async {
                                        await showAlertNotification();
                                      }, child: Text("Alert"))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(onTap: () async {
                                        await showAppNotification();
                                      }, child: Text("App"))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        debugTitle("Internet"),
                        Row(
                          crossAxisAlignment: cStart,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                              children: [
                                                TextSpan(
                                                    text: "connected:",
                                                    style: bold
                                                ),
                                                TextSpan(
                                                    text: " ${widget.connected}"
                                                )
                                              ]
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: "type: ",
                                                  style: bold
                                              ),
                                              textConnection(widget.connectionType)
                                            ]
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        debugTitle("Processes"),
                        Row(
                          crossAxisAlignment: cStart,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                              text: "Services: \n",
                                              style: bold,
                                              children: [
                                                TextSpan(
                                                    style: textBase,
                                                    children: app.services.entries.map((serviceName) => TextSpan(text: "\"${serviceName.key}\" ")).toList()
                                                )
                                              ]
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: "size: ",
                                                  style: bold
                                              ),
                                              TextSpan(
                                                  text: app.services.length.toString()
                                              )
                                            ]
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: cStart,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: cStart,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                              text: "Tokens: \n",
                                              style: bold,
                                              children: [
                                                TextSpan(
                                                    style: textBase,
                                                    children: tokens.sContracts.contracts.keys.map((key) {
                                                      if(key == tokens.sContracts.contracts.keys.last)
                                                        return TextSpan(text: "\"$key\"");
                                                      return TextSpan(text: "\"$key\", ");
                                                    }).toList()
                                                )
                                              ]
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      );
    else
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              // color: Colors.blue,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                // shape: BoxShape.rectangle,
                color: Colors.red,
                borderRadius: BorderRadius.all(
                  Radius.circular(8)
                )
              ),
            child: Icon(
              Icons.bug_report_outlined
            ),),
          ),
        ],
      );
  }

  Row debugTitle(String text) {
    TextStyle title = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.double,
        color: Colors.yellow
    );
    return Row(
      children: [
        Text(text, style: title,),
      ],
    );
  }

  TextSpan textConnection(ConnectivityResult type)
  {
    String text = "none";

    if(type == ConnectivityResult.wifi)
      text = "wifi";
    else if(type == ConnectivityResult.mobile)
      text = "mobile";
    return TextSpan(
        text: text
    );
  }

  Future<void> showAlertNotification() async
  {
    PushNotification.showNotification(
      title: "showAlertNotification",
      id: 1
    );
  }

  Future<void> showAppNotification() async
  {
    PushNotification.showNotification(
      title: 'New Notification',
      body: 'Yes',
      id: 0,
      payload: 'app/overview'
    );
  }
}