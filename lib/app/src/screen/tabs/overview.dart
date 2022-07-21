import 'package:avme_wallet/app/src/screen/widgets/hint.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:avme_wallet/app/src/screen/widgets/theme.dart';

import 'package:avme_wallet/app/src/controller/wallet/account.dart';
import 'package:avme_wallet/app/src/helper/utils.dart';
import 'package:avme_wallet/app/src/screen/widgets/overview/export.dart';

class Overview extends StatefulWidget {

  final TabController appScaffoldTabController;
  const Overview({Key? key, required this.appScaffoldTabController}) : super(key: key);
  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  bool initialPieAnimate = true;

  @override
  void initState()
  {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initialPieAnimate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    return Consumer<Account>(
      builder: (context, account, _){
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
                        // appColors.preColorList[app.currentWalletId][0],
                        // appColors.preColorList[app.currentWalletId][1],
                        //TODO: Get the current wallet id
                        appColors.preColorList[0][0],
                        appColors.preColorList[0][1],
                      ]
                    )
                  ),
                  end: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[
                        //TODO: Get the current wallet id
                        appColors.preColorList[0][0],
                        appColors.preColorList[0][1],
                      ]
                    )
                  )
                ),
                // totalBalance: _totalBalance(app),
                totalBalance: _totalBalance(),
                address: Account.accounts[account.selected].address!,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: Account.accounts[account.selected].address!));
                  AppHint.show("Address copied to clipboard");

                },
                onIconPressed: () async {
                  // NotificationBar().show(context,text: "Show RECEIVE widgets");
                  //TODO: Implent this back
                  // await showDialog(
                  //     context: context,
                  //     builder: (context) {
                  //       return StatefulBuilder(builder: (builder, setState){
                  //         return ReceivePopup(
                  //           title: "Share QR Address",
                  //           accountTitle: app.currentAccount.title,
                  //           address: app.currentAccount.address,
                  //           onQrPressed: () {
                  //             NotificationBar().show(
                  //                 context,
                  //                 text: "Address copied to clipboard",
                  //                 onPressed: () async {
                  //                   await Clipboard.setData(
                  //                       ClipboardData(text: app.currentAccount.address));
                  //                 }
                  //             );
                  //           },
                  //         );
                  //       });
                  //     }
                  // );
                },
                onReceivePressed: () async {
                  // await showDialog(
                  //     context: context,
                  //     builder: (context) {
                  //       return StatefulBuilder(builder: (builder, setState){
                  //         return ReceivePopup(
                  //           title: "Share QR Address",
                  //           address: app.currentAccount.address,
                  //           accountTitle: app.currentAccount.title,
                  //           onQrPressed: () {
                  //             NotificationBar().show(
                  //                 context,
                  //                 text: "Address copied to clipboard",
                  //                 onPressed: () async {
                  //                   await Clipboard.setData(
                  //                       ClipboardData(text: app.currentAccount.address));
                  //                 }
                  //             );
                  //           },
                  //         );
                  //       });
                  //     }
                  // );
                },
                onSendPressed: () {
                  widget.appScaffoldTabController.index = 3;
                },
                onBuyPressed: () {
                  AppHint.show("Not implemented");
                },
              ),
              //TODO: Implement PIE
              // TokenDistribution(
              //   chartData: _tokenDistribution(app),
              //   shouldAnimate: initialPieAnimate,
              //   appScaffoldTabController: widget.appScaffoldTabController,
              // ),
            ]
              // ..addAll(_tokenDetailsCard(app))
              // ..addAll([
              //   HistorySnippet(
              //     appScaffoldTabController: widget.appScaffoldTabController,
              //     app: app,
              //   )
              // ])
        );
      },
    );
  }

  // List<Widget> _tokenDetailsCard(AvmeWallet app)
  // {
  //   Map tokensWithBalance = app.currentAccount.tokensBalanceList;
  //   List<Widget> ret = [
  //     TokenTracker(
  //       image:
  //       Image.asset(
  //         'assets/avax_logo.png',
  //         fit: BoxFit.fitHeight,),
  //       name: 'AVAX',
  //       amount: "${shortAmount(app.currentAccount.balance)}",
  //       marketValue: "${shortAmount(app.currentAccount.networkBalance.toString(),comma: true, length: 3)}",
  //       asNetworkToken: '',
  //     )
  //   ];
  //   ///Checking for any token recovered
  //   if(tokensWithBalance.length > 0)
  //     return ret..addAll(tokensWithBalance.entries.map((entry) {
  //       return TokenTracker(
  //         image: resolveImage(app.activeContracts.sContracts.contractsRaw[entry.key]["logo"]),
  //         name: entry.key,
  //         amount: "${shortAmount(app.currentAccount.tokenWei(name: entry.key))}",
  //         marketValue: shortAmount(app.currentAccount.tokenBalance(name: entry.key),comma: false, length: 3),
  //         asNetworkToken: (app.currentAccount.tokensBalanceList[entry.key]["balance"] / app.networkToken.decimal.toDouble()).toString(),
  //       );
  //     }).toList());
  //   return ret;
  // }

  // Map _tokenDistribution(AvmeWallet app)
  // {
  //   Map tokensWithBalance = app.currentAccount.tokensBalanceList;
  //   Map<String, List> ret = {
  //     "AVAX": [
  //       app.currentAccount.networkBalance,
  //       Colors.red
  //     ]
  //   };
  //   int pos = 0;
  //
  //   ///Checking for any token
  //   if(app.currentAccount.tokensBalanceList.length > 0)
  //     ret.addAll(
  //         tokensWithBalance.map((key, value) {
  //           pos++;
  //           return MapEntry(key, [
  //             tokensWithBalance[key]["balance"],
  //             AppColors.availableColors[pos]
  //           ]);
  //         }
  //         )
  //     );
  //
  //   return ret;
  // }
  String _totalBalance()
  {
    // List tokensValue = app.currentAccount.tokensBalanceList.entries.map((e) =>
    // e.value["balance"]).toList();
    AccountData currentAccount = Account.current();
    List<double> tokensValue = currentAccount.balance.map((e) => e.total).toList();
    double platformValue = currentAccount.platform.total;

    tokensValue.forEach((value) => platformValue += value);

    print(tokensValue);
    return "${Utils.shortReadable(platformValue.toString(),comma: true, length: 7)}";
  }
  // String _totalBalance(AvmeWallet app)
  // {
  //   List tokensValue = app.currentAccount.tokensBalanceList.entries.map((e) =>
  //   e.value["balance"]).toList();
  //
  //   double totalValue = app.currentAccount.networkBalance;
  //
  //   tokensValue.forEach((value) => totalValue += value);
  //
  //   print(tokensValue);
  //   return "${shortAmount(totalValue.toString(),comma: true, length: 7)}";
  // }
}