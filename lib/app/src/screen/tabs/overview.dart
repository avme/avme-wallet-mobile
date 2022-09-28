import 'dart:async';
import 'dart:math';

import 'package:avme_wallet/app/src/controller/db/app.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/helper/size.dart';
import 'package:avme_wallet/app/src/helper/utils.dart';
import 'package:avme_wallet/app/src/model/db/market_data.dart';
import 'package:avme_wallet/app/src/screen/widgets/hint.dart';
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
import '../widgets/overview/token_value.dart';

class Overview extends StatefulWidget {
  final TabController appScaffoldTabController;
  const Overview({Key? key, required this.appScaffoldTabController}) : super(key: key);
  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  bool initialPieAnimate = true;
  late StreamController<String> difference;
  @override
  void initState()
  {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initialPieAnimate = false;
    });
    difference = StreamController<String>();
    difference.add("0");
    updateDifference();
  }

  void updateDifference() async
  {
    AccountData current = Account.current();
    DateTime _now = DateTime.now();
    DateTime dateTimeNow = DateTime.utc(_now.year, _now.month, _now.day);
    int midNight = int.parse(dateTimeNow.millisecondsSinceEpoch.toString().substring(0, 10));

    String whereIn = current.balance
        .where((balanceInfo) => balanceInfo.qtd > 0)
        .map((balanceInfo) => "'${balanceInfo.name.toUpperCase()}'").join(", ");

    String andWhere = "and datetime between $midNight and ($midNight + 3500)";
    List<MarketData> data = await WalletDB().readAmountIn(whereIn, null, andWhere);
    double sumOfCurrent = 0;
    double sumOfMidnight = 0;
    double previousValue = 0;
    double updatedValue = 0;
    // Random random = Random();
    do {
    if (data.isNotEmpty)
    {
      for (MarketData row in data) {
        Token token = Coins.list.firstWhere((token) =>
        token.name.toUpperCase() == row.tokenName);
        sumOfMidnight += row.value.toDouble();
        sumOfCurrent += token.value;
      }

      updatedValue = (((sumOfCurrent - sumOfMidnight) / sumOfCurrent) * 100)/* + random.nextInt(10)*/;
      if (updatedValue != previousValue && !difference.isClosed) {
        difference.add("${updatedValue > 0 ? "+" : ""}${updatedValue.toStringAsFixed(2)}");
        previousValue = updatedValue;
        setState(() {});
      }
    }
      await Future.delayed(Duration(seconds: 10));
    }
    while(!difference.isClosed);
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
                      appColors.preColorList[account.selected][0],
                      appColors.preColorList[account.selected][1],
                    ]
                  )
                ),
                end: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      appColors.preColorList[account.selected][0],
                      appColors.preColorList[account.selected][1],
                    ]
                  )
                )
              ),
              totalBalance: _totalBalance(),
              address: account.currentSelected.address,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: account.currentSelected.address));
                AppHint.show("Address copied to clipboard");
              },
              onIconPressed: () async {
                await showDialog(
                  context: context,
                  builder: ((context) => receivePopup(account.currentSelected))
                );
              },
              onReceivePressed: () async {
                await showDialog(
                  context: context,
                  builder: ((context) => receivePopup(account.currentSelected))
                );
              },
              onSendPressed: () {
                widget.appScaffoldTabController.index = 3;
              },
              onBuyPressed: () {
                AppHint.show("Not implemented");
              },
              difference: StreamBuilder(
                stream: difference.stream,
                builder: (context, AsyncSnapshot<String> snapshot) {
                  String data = snapshot.data ?? "0";
                  return Text("$data%",
                    style: TextStyle(
                      fontSize: DeviceSize.fontSize,
                      // color: _styleColor.value
                    )
                  );
                },
              ),
            ),
            TokenDistribution(
              chartData: _tokenDistribution(),
              shouldAnimate: initialPieAnimate,
              appScaffoldTabController: widget.appScaffoldTabController,
            ),
          ]
          ..addAll(_tokenDetailsCard(account.currentSelected))
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

  StatefulBuilder receivePopup(AccountData account)
  {
    return StatefulBuilder(builder: (builder, setState) =>
      ReceivePopup(
        title: "Share QR Address",
        accountTitle: account.title,
        address: account.address,
        onQrPressed: () {
          AppHint.show(
            "text",
            onPressed:() async {
              await Clipboard.setData(ClipboardData(text: account.address));
            }
          );
        },
      )
    );
  }

  List<Widget> _tokenDetailsCard(AccountData account)
  {
    Map tokensWithBalance = {};
    for(int index = 0; index < account.balance.length; index ++)
    {
      ///Skipping first entry because its the platform's token
      if(index == 0) { continue; }
      tokensWithBalance[account.balance[index].name] = account.balance[index].inCurrency;
    }
    Widget platformLogo = Container();
    Token platformToken = Coins.getPlatformToken;
    ///Defining if is the default "Avalanche" or any other blockchain
    if(Coins.getPlatformToken.symbol == "AVAX")
    {
      platformLogo = Image.asset('assets/avax_logo.png', fit: BoxFit.fitHeight);
    }
    else
    {
      platformLogo = CircleAvatar(
        backgroundColor: AppColors.purpleDark1,
        child: Icon(
          Icons.language_rounded,
          color: Colors.white,
        ),
      );
    }

    List<TokenTracker> ret = [
      TokenTracker(
        name: Coins.getPlatformToken.name,
        symbol: Coins.getPlatformToken.symbol,
        image: platformLogo,
      ),
    ];

    if(tokensWithBalance.isNotEmpty)
    {
      ret..addAll(tokensWithBalance.entries.map((token) {
        Token coinData = Coins.list.firstWhere((_coinData) => _coinData.name == token.key);
        return TokenTracker(
          name: token.key,
          symbol: coinData.symbol,
          image: Utils.resolveImage(coinData.image),
        );
      }).toList());
    }
    return ret;
  }

  Map<String, List> _tokenDistribution()
  {
    AccountData account = Account.current();
    Map tokensWithBalance = {};

    ///Ignoring first because its the platform token
    // for(BalanceInfo balance in account.balance)
    for(int i = 0; i < account.balance.length; i ++)
    {
      if(i == 0) { continue; }
      tokensWithBalance[account.balance[i].symbol] = account.balance[i].inCurrency;
    }

    Map<String, List> ret = {
      "AVAX": [
        account.balance.first.inCurrency,
        Colors.redAccent
      ]
    };

    int pos = 0;

    ///Checking for any token
    if(account.balance.isNotEmpty) {
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
    // Print.warning(ret.toString());
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

  @override
  void dispose() {
    super.dispose();
    difference.close();
  }
}