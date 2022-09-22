import 'dart:async';
import 'dart:math';

import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/model/db/market_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:avme_wallet/app/src/helper/size.dart';

import 'package:avme_wallet/app/src/screen/widgets/widgets.dart';
import 'package:avme_wallet/app/src/controller/wallet/account.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';

import 'package:avme_wallet/app/src/controller/db/app.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/balance.dart';

import '../../../controller/wallet/token/token.dart';

class OverviewAndButtons extends StatefulWidget {
  final String totalBalance;
  final String address;
  final VoidCallback onPressed;
  final VoidCallback onIconPressed;
  final VoidCallback onSendPressed;
  final VoidCallback onReceivePressed;
  final VoidCallback onBuyPressed;
  final DecorationTween balanceTween;

  OverviewAndButtons({
    Key? key,
    required this.totalBalance,
    required this.address,
    required this.onPressed,
    required this.onIconPressed,
    required this.onSendPressed,
    required this.onReceivePressed,
    required this.onBuyPressed,
    required this.balanceTween,
  }) : super(key: key);

  @override
  _OverviewAndButtonsState createState() => _OverviewAndButtonsState();
}

class _OverviewAndButtonsState extends State<OverviewAndButtons> {

  late StreamController<String> difference;

  @override
  void initState() {
    super.initState();
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

    List a = current.balance
        .where((balanceInfo) => balanceInfo.qtd > 0).toList();
    String andWhere = "and datetime between $midNight and ($midNight + 3500)";
    List<MarketData> data = await WalletDB().readAmountIn(whereIn, null, andWhere);
    double sumOfCurrent = 0;
    double sumOfMidnight = 0;
    double previousValue = 0;
    double updatedValue = 0;

    Print.warning("{a?} $a");
    Print.warning("{wherein?} $whereIn");
    Print.warning("{futa?} $data");
    Print.warning("{subdom?} ${current.balance}");
    do {
      if (data.isNotEmpty)
      {
        for (MarketData row in data) {
          Token token = Coins.list.firstWhere((token) =>
          token.name.toUpperCase() == row.tokenName);
          Print.approve("${token.name}: ${token.value}");
          sumOfMidnight += row.value.toDouble();
          sumOfCurrent += token.value;
        }

        updatedValue = (((sumOfCurrent - sumOfMidnight) / sumOfCurrent) * 100);

        if (updatedValue != previousValue) {
          difference.add(updatedValue.toStringAsFixed(2));
          previousValue = updatedValue;
          setState(() {});
        }
      }
      await Future.delayed(Duration(seconds: 5));
    }
    while(true);
  }

  @override
  Widget build(BuildContext context) {
    double cardpad = DeviceSize.safeBlockHorizontal * 3.5;
    return AppCard(
      child: Column(
        children: [
          GradientContainer(
            decorationTween: widget.balanceTween,
            onPressed: () {},
            child: Padding(
              padding: EdgeInsets.only(top: cardpad, left: cardpad, bottom: cardpad),
              child: Row(
                children: [
                  ///Fist Column with Data.
                  Flexible(
                    child: GestureDetector(
                      onTap: widget.onPressed,
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Balance",
                              style: TextStyle(fontSize: DeviceSize.labelSize * 0.6),
                            ),
                            SizedBox(
                              height: DeviceSize.safeBlockVertical,
                            ),
                            Text(
                              "\$${widget.totalBalance}",
                              style: TextStyle(
                                fontSize: DeviceSize.labelSize,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            StreamBuilder(
                              stream: difference.stream,
                              builder: (context, AsyncSnapshot<String> snapshot) {
                                String data = snapshot.data ?? "0";
                                return Text("+$data%",
                                  style: TextStyle(
                                    fontSize: DeviceSize.fontSize,
                                    // color: _styleColor.value
                                  )
                                );
                              },
                            ),
                            SizedBox(
                              height: 18,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Icon(
                                    Icons.copy,
                                    size: DeviceSize.labelSize,
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Flexible(
                                  child: Column(
                                    children: [
                                      Text(
                                        "${widget.address}",
                                        style: TextStyle(fontSize: DeviceSize.fontSize),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  ///This is the second column, icon only
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: widget.onIconPressed,
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: EdgeInsets.only(left: cardpad / 2, right: cardpad),
                            child: Icon(
                              Icons.qr_code_scanner,
                              size: 58,
                              color: Colors.white,
                            ),
                          )
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppNeonButton(
                  onPressed: widget.onSendPressed,
                  text: "SEND",
                  iconData: Icons.upload_sharp,
                ),
              ),
              SizedBox(
                width: DeviceSize.safeBlockHorizontal * 1.6,
              ),
              Expanded(
                child: AppNeonButton(
                  onPressed: widget.onReceivePressed,
                  text: "RECEIVE",
                  iconData: Icons.download_sharp,
                ),
              ),

              ///Uncomment this to display the "buy" button referenced
              ///inside the design
              // SizedBox(
              //   width: DeviceSize.safeBlockHorizontal * 1.6,
              // ),
              // Expanded(
              //   child: AppNeonButton(
              //     onPressed: widget.onBuyPressed,
              //     text: "BUY",
              //     iconData: Icons.shopping_cart,
              //   ),
              // ),
            ],
          )
        ],
      ),
    );
  }
  @override
  void dispose() {
    // diffUpdatedController.dispose();
    difference.close();
    super.dispose();
  }
}
// Future<String> difference() async {
//   return "FIX_ME%";
// }
// Future<String> difference() async {
//   int counter = 0;
//   double difference = 0, sum = 0, tokenValueToday, tempCalc = 0;
//   List<double> tokenValuesYesterday = [], percentages = [];
//   // List<String> tokenNames = app.activeContracts.tokens;
//   List<String> tokenNames = Coins.list.map((e) => e.name).toList();
//   bool isThereBalance = false;
//   // //AVAX
//   // if (Account.current().platform.inCurrency > 0.0) {
//   //   isThereBalance = true;
//   //   tokenValueToday = Account.current().platform.inCurrency;
//   //   List<MarketData> value = await WalletDB().readAmount('PLATFORM', 1);
//   //   percentages.add((tokenValueToday / value.first.value.toDouble()) - 1);
//   //   sum += (value.first.value.toDouble());
//   //   tokenValuesYesterday.add(value.first.value.toDouble());
//   // }
//   //Other
//   // tokenNames.forEach((element) async { //Doesn't work, since it will work and wait for the .forEach but won't wait for the await inside
//   // for (String element in tokenNames) {
//   await Future.forEach(tokenNames, (String element) async {
//     late BalanceInfo tokenBalance;
//     try
//     {
//       tokenBalance = Account.current().balance.firstWhere((_b) => _b.name == element);
//     }
//     catch (e)
//     {
//       if (e is StateError) {
//         Print.error("[Widget -> Overview\\Balance] Error finding token named $element");
//         return;
//       }
//       else {
//         throw e;
//       }
//     }
//     if (tokenBalance.inCurrency > 0)
//     {
//       isThereBalance = true;
//       double tokenValueToday = tokenBalance.token.value;
//       await WalletDB().readAmount(element, 1).then((value) {
//         percentages.add((tokenValueToday / value.first.value.toDouble()) - 1);
//         sum += (value.first.value.toDouble());
//         tokenValuesYesterday.add(value.first.value.toDouble());
//       });
//     }
//   });
//   //Processing
//   String warning = "FIX THIS -> ";
//   if (!isThereBalance) return warning + '0%';
//
//   for (double value in percentages) {
//     tempCalc += value * tokenValuesYesterday.elementAt(counter);
//     ++counter;
//   }
//
//   difference = (tempCalc / sum) * 100;
//
//   return '$warning ${difference.toStringAsFixed(2)}%';
// }
