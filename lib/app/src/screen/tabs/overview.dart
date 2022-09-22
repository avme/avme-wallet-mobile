import 'package:avme_wallet/app/src/controller/db/app.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/helper/size.dart';
import 'package:avme_wallet/app/src/helper/utils.dart';
import 'package:avme_wallet/app/src/model/db/market_data.dart';
import 'package:avme_wallet/app/src/screen/widgets/hint.dart';
import 'package:avme_wallet/app/src/screen/widgets/overview/token_value.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:avme_wallet/app/src/screen/widgets/theme.dart';

import 'package:avme_wallet/app/src/controller/wallet/account.dart';
import 'package:avme_wallet/app/src/screen/widgets/overview/export.dart';

import 'package:avme_wallet/app/src/controller/wallet/token/balance.dart';
import 'package:avme_wallet/app/src/screen/widgets/generic.dart';
import 'package:avme_wallet/app/src/screen/widgets/overview/pie_chart.dart';

import '../../controller/wallet/token/token.dart';

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
    // return Container(
    //   child: Column(
    //     children: [
    //       Text("watch length: ${context.watch<Account>().accounts.length}"),
    //       Text("singleton lenght: ${Account().accounts.length}"),
    //     ],
    //   ),
    // );
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
                      appColors.preColorList[Account.currentSelectedId()][0],
                      appColors.preColorList[Account.currentSelectedId()][1],
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
              totalBalance: _totalBalance(),
              address: Account().accounts[account.selected].address,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: Account().accounts[account.selected].address));
                AppHint.show("Address copied to clipboard");
              },
              onIconPressed: () async {
                // NotificationBar().show(context,text: "Show RECEIVE widgets");
                //TODO: Implent this back
                await showDialog(
                  context: context,
                  builder: receivePopup
                );
              },
              onReceivePressed: () async {
                await showDialog(
                  context: context,
                  builder: receivePopup
                );
              },
              onSendPressed: () {
                widget.appScaffoldTabController.index = 3;
              },
              onBuyPressed: () {
                AppHint.show("Not implemented");
              },
            ),
            TokenDistribution(
              chartData: _tokenDistribution(),
              shouldAnimate: initialPieAnimate,
              appScaffoldTabController: widget.appScaffoldTabController,
            ),
          ]
          ..addAll(_tokenDetailsCard())
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

  StatefulBuilder receivePopup(BuildContext? context)
  {
    return StatefulBuilder(builder: (builder, setState) =>
      ReceivePopup(
        title: "Share QR Address",
        accountTitle: Account.current().title,
        address: Account.current().address,
        onQrPressed: () {
          AppHint.show(
            "text",
            onPressed:() async {
              await Clipboard.setData(ClipboardData(text: Account.current().address));
            }
          );
        },
      )
    );
  }

  List<Widget> _tokenDetailsCard()
  {
    AccountData account = Account.current();
    Map tokensWithBalance = {};
    for(BalanceInfo balance in account.balance)
    {
      tokensWithBalance[balance.name] = balance.inCurrency;
    }
    return [
      Container(child: Text("FIX ME"),)
    ];
    /*
    List<Widget> ret = [
      TokenTracker(
        image:
        Image.asset(
          'assets/avax_logo.png',
          fit: BoxFit.fitHeight,),
        name: 'PLATFORM',
        // amount: "${Utils.shortReadable(account.platform.qtd.toString(),comma: true, length: 3)}",
        amount: "${account.platform.qtd}",
        marketValue: "${account.platform.inCurrency.toStringAsFixed(5)}",
        asNetworkToken: '',
      )
    ];
    ///Checking for any token recovered
    if(tokensWithBalance.length > 0) {
      return ret..addAll(tokensWithBalance.entries.map((entry) {
        CoinData coinData = Coins.list.firstWhere((_coinData) => _coinData.name == entry.key);
        Balance balance = account.balance.firstWhere((_balance) => _balance.name == entry.key);
        return TokenTracker(
          image: Utils.resolveImage(coinData.image),
          name: entry.key,
          amount: "${balance.qtd}",
          marketValue: "${Utils.shortReadable(balance.inCurrency.toString())}",
          asNetworkToken: "FIX THIS",
        );
      }).toList());
    }
    return ret;
    */

  }

  Map<String, List> _tokenDistribution()
  {
    AccountData account = Account.current();
    Map tokensWithBalance = {};
    for(BalanceInfo balance in account.balance)
    {
      tokensWithBalance[balance.name] = balance.inCurrency;
    }

    Map<String, List> ret = {};
    int pos = 0;

    ///Checking for any token
    if(account.balance.length > 0) {
      ret.addAll(
        tokensWithBalance.map((key, value) {
          pos++;
          return MapEntry(key, [
            tokensWithBalance[key],
            AppColors.availableColors[pos]
          ]);
        })
      );
    }
    Print.warning(ret.toString());
    return ret;
  }

  String _totalBalance()
  {
    double total = 0;
    for(BalanceInfo balanceInfo in Account.current().balance)
    {
      total += balanceInfo.inCurrency;
    }
    return "${Utils.shortReadable(total.toString(),comma: true, length: 7)}";
  }
}