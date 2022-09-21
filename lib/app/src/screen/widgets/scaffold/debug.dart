import 'dart:async';

import 'package:avme_wallet/app/src/controller/controller.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/balance.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/helper/utils.dart';
import 'package:avme_wallet/app/src/screen/widgets/hint.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../../../controller/ui/push_notification.dart';
import '../../../helper/size.dart';

class DebugOverlay extends StatefulWidget {
  final bool connected;
  final TabController tabController;
  final ConnectivityResult connectionType;
  const DebugOverlay(
    {Key? key,
      required this.connected,
      required this.connectionType,
      required this.tabController})
    : super(key: key);

  @override
  _DebugOverlayState createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  late StreamController<bool> toggleController;

  @override
  void initState() {
    super.initState();

    ///Registering an Stream to control when is displayed or not
    toggleController = StreamController<bool>();
    toggleController.add(false);
    // Future.delayed(Duration(seconds: 1), () {
    //   toggleController.add(true);
    // });
    // PushNotification.init();
    // listenNotifications();
    // super.initState();
    // tokens = Provider.of<ActiveContracts>(context, listen: false);
  }

  void listenNotifications() {
    // PushNotification.onNotifications.stream.listen((payload) {
    //   print(payload.toString());
    //   print(ModalRoute.of(context).settings.name);
    //   if (payload.toString() == "app/overview" &&
    //       widget.tabController.index != 1) {
    //     widget.tabController.index = 1;
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    // bool inDebugMode = Provider.of<AvmeWallet>(context).debugMode;
    bool inDebugMode = dotenv.env["DEBUG_MODE"] == "TRUE" ? true : false;
    if (inDebugMode) {
      // return Consumer<AvmeWallet>(builder: (context, app, _) {
      //   shouldDisplay = app.debugPanel;
      //   return GestureDetector(
      //       onTap: () {
      //         app.toggleDebugPanel();
      //       },
      //       child: _debugPanel(shouldDisplay, app));
      // });
      return StreamBuilder<bool>(
        stream: toggleController.stream,
        builder: (context, toggleState) {
          bool shouldBuild = toggleState.data ?? false;
          return GestureDetector(
            onTap: () {
              toggleController.add(!shouldBuild);
            },
            child: renderPanel(shouldBuild));
        }
      );
    } else {
      return Container();
    }
  }

  Column renderPanel(bool shouldDisplay)
  {
    TextStyle textBase = TextStyle(
      fontWeight: FontWeight.normal,
      color: Colors.white
    );

    TextStyle bold = textBase.copyWith(
      fontWeight: FontWeight.bold
    );

    MainAxisAlignment mStart = MainAxisAlignment.start;
    CrossAxisAlignment cStart = CrossAxisAlignment.start;

    if(shouldDisplay)
    {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ///Main Container / red bg
          Container(
            decoration: BoxDecoration(
              color: Colors.red
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // maxHeight: MediaQuery.of(context).size.height / 6
                  maxHeight: DeviceSize.screenHeight / 6,
                ),
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Column(
                      children: [
                        debugTitle("Status"),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            balanceTracker(),

                            // Expanded(
                            //   child: Column(
                            //     crossAxisAlignment: cStart,
                            //     children: [
                            //       Row(
                            //         children: [
                            //           GestureDetector(
                            //               onTap: () async {
                            //                 ActiveContracts token =
                            //                 Provider.of<ActiveContracts>(
                            //                     context,
                            //                     listen: false);
                            //                 token.removeToken("AVME");
                            //                 token.removeToken("AVME testnet");
                            //               },
                            //               child: Text("-TOKEN AVME"))
                            //         ],
                            //       ),
                            //       Row(
                            //         children: [
                            //           GestureDetector(
                            //               onTap: () async {
                            //                 ActiveContracts token =
                            //                 Provider.of<ActiveContracts>(
                            //                     context,
                            //                     listen: false);
                            //                 token.removeToken("Pangolin");
                            //               },
                            //               child: Text("-TOKEN PGL"))
                            //         ],
                            //       ),
                            //       Row(
                            //         children: [
                            //           GestureDetector(
                            //               onTap: () async {
                            //                 ActiveContracts token =
                            //                 Provider.of<ActiveContracts>(
                            //                     context,
                            //                     listen: false);
                            //                 token.removeToken("JoeToken");
                            //               },
                            //               child: Text("-TOKEN JOE"))
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      );
    }
    else
    {
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
                borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: Icon(Icons.bug_report_outlined),
            ),
          ),
        ],
      );
    }
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

  Widget balanceTracker() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Consumer<Account>(
                builder: (context, account, _) {
                  AccountData currentAccount = Account.current();
                  List<TextSpan> tokenData = currentAccount.balance.map((balanceInfo) =>
                      TextSpan(text:
'''${balanceInfo.name} (${balanceInfo.symbol})
QTD: ${balanceInfo.qtd}
VALUE: ${balanceInfo.inCurrency}\n'''
                      )).toList();
                  return RichText(
                    text: TextSpan(
                      children: tokenData
                    ),
                  );
                }
              ),
            ],
          )
        ],
      ),
    );
  }
}
