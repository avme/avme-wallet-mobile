import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/receive_popup.dart';
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
              totalBalance: _totalBalance(app),
              address: app.currentAccount.address,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: app.currentAccount.address));
                NotificationBar().show(
                    context,
                    text: "Address copied to clipboard",
                    onPressed: ()  {
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
                          accountTitle: app.currentAccount.title,
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
                          accountTitle: app.currentAccount.title,
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
                widget.appScaffoldTabController.index = 3;
              },
              onBuyPressed: () {
                NotificationBar().show(
                    context,
                    text: "Not implemented"
                );
              },
            ),
            TokenDistribution(
                chartData: _tokenDistribution(app)
            ),
            ]
            ..addAll(_tokenDetailsCard(app))
            ..addAll([
              HistorySnippet(
                appScaffoldTabController: widget.appScaffoldTabController,
                app: app,
              )
            ])
        );
      },
    );
  }

  List<Widget> _tokenDetailsCard(AvmeWallet app)
  {
    Map tokensWithBalance = app.currentAccount.tokensBalanceList;
    List<Widget> ret = [
      TokenTracker(
        image:
        Image.asset(
          'assets/avax_logo.png',
          fit: BoxFit.fitHeight,),
        name: 'AVAX',
        amount: "${shortAmount(app.currentAccount.balance)}",
        marketValue: "${shortAmount(app.currentAccount.networkBalance.toString(),comma: true, length: 3)}",
        asNetworkToken: '',
      )
    ];
    ///Checking for any token recovered
    if(tokensWithBalance.length > 0)
      return ret..addAll(tokensWithBalance.entries.map((entry) {
        return TokenTracker(
          image: resolveImage(app.activeContracts.sContracts.contractsRaw[entry.key]["logo"]),
          name: entry.key,
          amount: "${shortAmount(app.currentAccount.tokenWei(name: entry.key))}",
           marketValue: shortAmount(app.currentAccount.tokenBalance(name: entry.key),comma: false, length: 3),
          valueDifference: "2,013",
        );
      }).toList());
    return ret;
  }

  Map _tokenDistribution(AvmeWallet app)
  {
    Map tokensWithBalance = app.currentAccount.tokensBalanceList;
    Map<String, List> ret = {
      "AVAX": [
        app.currentAccount.networkBalance,
        Colors.red
      ]
    };
    int pos = 0;

    ///Checking for any token
    if(app.currentAccount.tokensBalanceList.length > 0)
      ret.addAll(
          tokensWithBalance.map((key, value) {
          pos++;
          return MapEntry(key, [
            tokensWithBalance[key]["balance"],
            AppColors.availableColors[pos]
          ]);
          }
        )
      );

    return ret;
  }

  String _totalBalance(AvmeWallet app)
  {
    List tokensValue = app.currentAccount.tokensBalanceList.entries.map((e) =>
      e.value["balance"]).toList();

    double totalValue = app.currentAccount.networkBalance;

    tokensValue.forEach((value) => totalValue += value);

    print(tokensValue);
    return "${shortAmount(totalValue.toString(),comma: true, length: 7)}";
  }
}