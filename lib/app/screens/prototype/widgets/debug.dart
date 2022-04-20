import 'dart:convert';

import 'package:avme_wallet/app/controller/services/contract.dart';
import 'package:avme_wallet/app/controller/services/push_notification.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/auth_setup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/authentication.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class DebugOverlay extends StatefulWidget {
  final bool connected;
  final TabController tabController;
  final ConnectivityResult connectionType;
  const DebugOverlay(
      {Key key,
      this.connected,
      this.connectionType,
      @required this.tabController})
      : super(key: key);

  @override
  _DebugOverlayState createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  bool shouldDisplay = false;
  ActiveContracts tokens;
  @override
  void initState() {
    PushNotification.init();
    listenNotifications();
    super.initState();
    tokens = Provider.of<ActiveContracts>(context, listen: false);
  }

  void listenNotifications() {
    PushNotification.onNotifications.stream.listen((payload) {
      print(payload.toString());
      print(ModalRoute.of(context).settings.name);
      if (payload.toString() == "app/overview" &&
          widget.tabController.index != 1) {
        widget.tabController.index = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool inDebugMode = Provider.of<AvmeWallet>(context).debugMode;
    if (inDebugMode)
      return Consumer<AvmeWallet>(builder: (context, app, _) {
        shouldDisplay = app.debugPanel;
        return GestureDetector(
            onTap: () {
              app.toggleDebugPanel();
            },
            child: _debugPanel(shouldDisplay, app));
      });
    else
      return Container();
  }

  Column _debugPanel(bool shouldDisplay, AvmeWallet app) {
    TextStyle textBase =
        TextStyle(fontWeight: FontWeight.normal, color: Colors.white);
    TextStyle bold = textBase.copyWith(fontWeight: FontWeight.bold);
    // AvmeWallet app = Provider.of<AvmeWallet>(context);
    MainAxisAlignment mStart = MainAxisAlignment.start;
    CrossAxisAlignment cStart = CrossAxisAlignment.start;

    if (shouldDisplay)
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 6),
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
                                      GestureDetector(
                                          onTap: () async {
                                            tokens.addToken("AVME");
                                            tokens.addToken("AVME testnet");
                                          },
                                          child: Text("+TOKEN AVME"))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () async {
                                            tokens.addToken("Pangolin");
                                          },
                                          child: Text("+TOKEN PGL"))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () async {
                                            tokens.addToken("JoeToken");
                                          },
                                          child: Text("+TOKEN JOE"))
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
                                      GestureDetector(
                                          onTap: () async {
                                            ActiveContracts token =
                                                Provider.of<ActiveContracts>(
                                                    context,
                                                    listen: false);
                                            token.removeToken("AVME");
                                            token.removeToken("AVME testnet");
                                          },
                                          child: Text("-TOKEN AVME"))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () async {
                                            ActiveContracts token =
                                                Provider.of<ActiveContracts>(
                                                    context,
                                                    listen: false);
                                            token.removeToken("Pangolin");
                                          },
                                          child: Text("-TOKEN PGL"))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () async {
                                            ActiveContracts token =
                                                Provider.of<ActiveContracts>(
                                                    context,
                                                    listen: false);
                                            token.removeToken("JoeToken");
                                          },
                                          child: Text("-TOKEN JOE"))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        debugTitle("Authentication"),
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: cStart,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: cStart,
                                    children: [
                                      Row(
                                        children: [
                                          GestureDetector(
                                              onTap: () async {
                                                // final isAuthenticated = await LocalAuthApi.authenticate(context);
                                                // if (isAuthenticated){
                                                //   NotificationBar().show(
                                                //       context,
                                                //       text: "Biometrics success"
                                                //   );
                                                // }
                                                Authentication authApi =
                                                    Authentication();
                                                bool canAuthenticate =
                                                    await authApi
                                                        .canAuthenticate();
                                                dynamic secret = await authApi
                                                    .retrieveSecret();
                                                if (secret is String) {
                                                  await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AppPopupWidget(
                                                          title: 'Fingerprint',
                                                          canClose: true,
                                                          margin:
                                                              EdgeInsets.all(
                                                                  16),
                                                          cancelable: false,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 16,
                                                                  horizontal:
                                                                      32),
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    'Can authenticate: $canAuthenticate'),
                                                                Text(secret),
                                                              ],
                                                            )
                                                          ],
                                                        );
                                                      });
                                                } else {
                                                  String temp =
                                                      secret.toString();
                                                  if (temp.contains('create') ||
                                                      temp.contains('found')) {
                                                    NotificationBar().show(
                                                        context,
                                                        text:
                                                            "Fingerprints are not configured within AVME app or phone",
                                                        onPressed: () {});
                                                  } else {
                                                    NotificationBar().show(
                                                        context,
                                                        text:
                                                            "No fingerprints enrolled in this phone, please setup fingerprints before continuing... (Unknown error)",
                                                        onPressed: () {});
                                                  }
                                                }
                                              },
                                              child: Text("Retrieve Secret"))
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
                                          GestureDetector(
                                              onTap: () async {
                                                Authentication authApi =
                                                    Authentication();
                                                bool canAuthenticate =
                                                    await authApi
                                                        .canAuthenticate();
                                                if (canAuthenticate == true) {
                                                  TextEditingController
                                                      controller =
                                                      TextEditingController();
                                                  await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AppPopupWidget(
                                                          title: 'New Secret',
                                                          canClose: true,
                                                          margin:
                                                              EdgeInsets.all(
                                                                  16),
                                                          cancelable: false,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 16,
                                                                  horizontal:
                                                                      32),
                                                          children: [
                                                            AppTextFormField(
                                                              controller:
                                                                  controller,
                                                              hintText:
                                                                  "Secret...",
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                      vertical:
                                                                          12,
                                                                      horizontal:
                                                                          8),
                                                              isDense: true,
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                AppNeonButton(
                                                                    expanded:
                                                                        false,
                                                                    textStyle: TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(),
                                                                    text:
                                                                        "Cancel"),
                                                                AppNeonButton(
                                                                    expanded:
                                                                        false,
                                                                    textStyle: TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                    onPressed:
                                                                        () async {
                                                                      await authApi
                                                                          .saveSecret(
                                                                              controller.text);
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    text:
                                                                        "Save"),
                                                              ],
                                                            )
                                                          ],
                                                        );
                                                      });
                                                } else {
                                                  NotificationBar().show(
                                                      context,
                                                      text:
                                                          "No fingerprint available",
                                                      onPressed: () {});
                                                }
                                              },
                                              child: Text("Save secret"))
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
                                          GestureDetector(
                                              onTap: () async {
                                                Authentication authApi =
                                                    Authentication();
                                                bool canAuthenticate =
                                                    await authApi
                                                        .canAuthenticate();
                                                dynamic secret = await authApi
                                                    .retrieveSecret();
                                                if (canAuthenticate &&
                                                    secret is String) {
                                                  await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AppPopupWidget(
                                                          title:
                                                              'Delete Secret?',
                                                          canClose: true,
                                                          margin:
                                                              EdgeInsets.all(
                                                                  16),
                                                          cancelable: false,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 16,
                                                                  horizontal:
                                                                      32),
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                AppNeonButton(
                                                                    expanded:
                                                                        false,
                                                                    textStyle: TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(),
                                                                    text:
                                                                        "Cancel"),
                                                                AppNeonButton(
                                                                    expanded:
                                                                        false,
                                                                    textStyle: TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                    onPressed:
                                                                        () async {
                                                                      String
                                                                          result =
                                                                          await authApi
                                                                              .deleteSecret();
                                                                      Navigator.pop(
                                                                          context);
                                                                      NotificationBar().show(
                                                                          context,
                                                                          text:
                                                                              result,
                                                                          onPressed:
                                                                              () {});
                                                                    },
                                                                    text:
                                                                        "Continue"),
                                                              ],
                                                            )
                                                          ],
                                                        );
                                                      });
                                                } else {
                                                  NotificationBar().show(
                                                      context,
                                                      text: 'No saved secrets',
                                                      onPressed: () {});
                                                }
                                              },
                                              child: Text("Delete Secret"))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: cStart,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                        onTap: () async {
                                          Authentication authApi =
                                              Authentication();
                                          if (await authApi.canAuthenticate()) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AuthSetupScreen()));
                                          } else {
                                            NotificationBar().show(context,
                                                text:
                                                    'No fingerprints enrolled in device, please configure fingerprints in your phone before continuing',
                                                onPressed: () {});
                                          }
                                        },
                                        child: Text("Auth Screen"))
                                  ],
                                ),
                              ],
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
                                      GestureDetector(
                                          onTap: () async {
                                            await showAlertNotification();
                                          },
                                          child: Text("Alert"))
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
                                      GestureDetector(
                                          onTap: () async {
                                            await showAppNotification();
                                          },
                                          child: Text("App"))
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
                                          text: TextSpan(children: [
                                            TextSpan(
                                                text: "connected:",
                                                style: bold),
                                            TextSpan(
                                                text: " ${widget.connected}")
                                          ]),
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
                                        text: TextSpan(children: [
                                          TextSpan(text: "type: ", style: bold),
                                          textConnection(widget.connectionType)
                                        ]),
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
                                                    children: app
                                                        .services.entries
                                                        .map((serviceName) =>
                                                            TextSpan(
                                                                text:
                                                                    "\"${serviceName.key}\" "))
                                                        .toList())
                                              ]),
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
                                        text: TextSpan(children: [
                                          TextSpan(text: "size: ", style: bold),
                                          TextSpan(
                                              text: app.services.length
                                                  .toString())
                                        ]),
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
                                                    children: tokens.sContracts
                                                        .contracts.keys
                                                        .map((key) {
                                                      if (key ==
                                                          tokens
                                                              .sContracts
                                                              .contracts
                                                              .keys
                                                              .last)
                                                        return TextSpan(
                                                            text: "\"$key\"");
                                                      return TextSpan(
                                                          text: "\"$key\", ");
                                                    }).toList())
                                              ]),
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
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Icon(Icons.bug_report_outlined),
            ),
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
        color: Colors.yellow);
    return Row(
      children: [
        Text(
          text,
          style: title,
        ),
      ],
    );
  }

  TextSpan textConnection(ConnectivityResult type) {
    String text = "none";

    if (type == ConnectivityResult.wifi)
      text = "wifi";
    else if (type == ConnectivityResult.mobile) text = "mobile";
    return TextSpan(text: text);
  }

  Future<void> showAlertNotification() async {
    PushNotification.showNotification(title: "showAlertNotification", id: 1);
  }

  Future<void> showAppNotification() async {
    PushNotification.showNotification(
        title: 'New Notification', body: 'Yes', id: 0, payload: 'app/overview');
  }
}
