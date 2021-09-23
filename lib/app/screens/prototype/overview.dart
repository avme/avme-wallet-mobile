import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/receive_popup.dart';
import 'package:avme_wallet/app/screens/send.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'widgets/balance.dart';
import 'widgets/token_distribution.dart';
import 'widgets/token_value.dart';
import 'package:flutter/material.dart';
import 'widgets/history_snippet.dart';


class Overview extends StatefulWidget {

  final TabController appScaffoldTabController;
  const Overview({Key key, @required this.appScaffoldTabController}) : super(key: key);
  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {

  AvmeWallet appState;

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AvmeWallet>(context);
    appState.walletManager.startBalanceSubscription(appState);
    appState.displayTokenChart();
    appState.services.keys.forEach((key) {
      print("KEYS:$key");
    });
    return ListView(
      children: [
        Selector<AvmeWallet,AccountObject>(
          selector: (context, model) => model.currentAccount,
          builder: (context, data, child){
            appState.watchBalanceUpdates();
            return OverviewAndButtons(
              totalBalance:
                appState.currentAccount.currencyBalance == null || appState.currentAccount.currencyTokenBalance == null ? "0,0000000" :
                "${shortAmount((appState.currentAccount.currencyBalance +
                  appState.currentAccount.currencyTokenBalance).toString(),comma: true, length: 7)}",
              address: appState.currentAccount.address,
              onPressed: () {
                NotificationBar().show(
                  context,
                  text: "Address copied to clipboard",
                  onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: appState.currentAccount.address));
                  }
                );
              },
              onIconPressed: () async {
                // NotificationBar().show(context,text: "Show RECEIVE widgets");
                await showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(builder: (builder, setState){
                      return ReceivePopup(
                        title: "Share QR Address",
                        address: appState.currentAccount.address,
                        onQrPressed: () {
                          NotificationBar().show(
                            context,
                            text: "Address copied to clipboard",
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: appState.currentAccount.address));
                            }
                          );
                        },
                      );
                    });
                  }
                );
              },
              onReceivePressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (builder, setState){
                        return ReceivePopup(
                          title: "Share QR Address",
                          address: appState.currentAccount.address,
                          onQrPressed: () {
                            NotificationBar().show(
                                context,
                                text: "Address copied to clipboard",
                                onPressed: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: appState.currentAccount.address));
                                }
                            );
                          },
                        );
                      });
                    }
                );
              },
              onSendPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (builder) => Send()));
              },
              onBuyPressed: () {
                NotificationBar().show(
                  context,
                  text: "Not implemented"
                );
              },
            );
          },
        ),
        // OverviewAndButtons(),
        TokenDistribution(
          chartData: {
            "AVAX": [
              appState.currentAccount.currencyBalance == null ? 0 :
                appState.currentAccount.currencyBalance,
              AppColors.purple
            ],
            "AVME": [
              appState.currentAccount.currencyTokenBalance == null ? 0 :
                appState.currentAccount.currencyTokenBalance,
              AppColors.lightBlue
            ]
          }
        ),

        ///AVAX Token Card
        Selector<AvmeWallet,AccountObject>(
          selector: (context, model) => model.currentAccount,
          builder: (context, data, child){
            appState.watchBalanceUpdates();
            return TokenValue(
              image:
              Image.asset(
                'assets/avax_logo.png',
                fit: BoxFit.fitHeight,),
              name: 'AVAX',
              amount: "${shortAmount(appState.currentAccount.balance)}",
              marketValue: "${shortAmount(appState.currentAccount.currencyBalance.toString(),comma: true, length: 3)}",
              valueDifference: "2,013",
            );
          },
        ),
        ///AVME Token Card
        Selector<AvmeWallet,AccountObject>(
          selector: (context, model) => model.currentAccount,
          builder: (context, data, child){
            appState.watchBalanceUpdates();
            return TokenValue(
              image:
              Image.asset(
                'assets/resized-newlogo02-trans.png',
                fit: BoxFit.fitHeight,),
              name: 'AVME',
              amount: "${shortAmount(appState.currentAccount.tokenBalance)}",
              marketValue: "${shortAmount(appState.currentAccount.currencyTokenBalance.toString(),comma: true, length: 3)}",
              valueDifference: "8,669",
            );
          },
        ),
        HistorySnippet(appScaffoldTabController: widget.appScaffoldTabController)
      ],
    );
  }
}