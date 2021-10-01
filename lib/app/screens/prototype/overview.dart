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

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    return Consumer<AvmeWallet>(
      builder: (context, app, _){
        return ListView(
          children: [
            OverviewAndButtons(
              balanceTween: DecorationTween(
                  begin: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: <Color>[
                            appColors.preColorList[app.currentWalletId][0],
                            appColors.preColorList[app.currentWalletId][1],
                          ]
                      )
                  ),
                  end: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: <Color>[
                            appColors.preColorList[app.currentWalletId][2],
                            appColors.preColorList[app.currentWalletId][3],
                          ]
                      )
                  )
              ),
              totalBalance:
              app.currentAccount.currencyBalance == null || app.currentAccount.currencyTokenBalance == null ? "0,0000000" :
              "${shortAmount((app.currentAccount.currencyBalance +
                  app.currentAccount.currencyTokenBalance).toString(),comma: true, length: 7)}",
              address: app.currentAccount.address,
              onPressed: () {
                NotificationBar().show(
                    context,
                    text: "Address copied to clipboard",
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: app.currentAccount.address));
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
                          accountTitle: app.currentAccount.address,
                          address: app.currentAccount.address,
                          onQrPressed: () {
                            NotificationBar().show(
                                context,
                                text: "Address copied to clipboard",
                                onPressed: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: app.currentAccount.address));
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
                          address: app.currentAccount.address,
                          onQrPressed: () {
                            NotificationBar().show(
                                context,
                                text: "Address copied to clipboard",
                                onPressed: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: app.currentAccount.address));
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
            ),

            TokenDistribution(
                chartData: {
                  "AVAX": [
                    app.currentAccount.currencyBalance == null ? 0 :
                    app.currentAccount.currencyBalance,
                    AppColors.purple
                  ],
                  "AVME": [
                    app.currentAccount.currencyTokenBalance == null ? 0 :
                    app.currentAccount.currencyTokenBalance,
                    AppColors.lightBlue
                  ]
                }
            ),

            ///AVAX Token Card
            TokenValue(
              image:
              Image.asset(
                'assets/avax_logo.png',
                fit: BoxFit.fitHeight,),
              name: 'AVAX',
              amount: "${shortAmount(app.currentAccount.balance)}",
              marketValue: "${shortAmount(app.currentAccount.currencyBalance.toString(),comma: true, length: 3)}",
              valueDifference: "2,013",
            ),
            ///AVME Token Card
            TokenValue(
              image:
              Image.asset(
                'assets/resized-newlogo02-trans.png',
                fit: BoxFit.fitHeight,),
              name: 'AVME',
              amount: "${shortAmount(app.currentAccount.tokenBalance)}",
              marketValue: "${shortAmount(app.currentAccount.currencyTokenBalance.toString(),comma: true, length: 3)}",
              valueDifference: "8,669",
            ),
            HistorySnippet(appScaffoldTabController: widget.appScaffoldTabController)
          ],
        );
      },
    );
  }
}