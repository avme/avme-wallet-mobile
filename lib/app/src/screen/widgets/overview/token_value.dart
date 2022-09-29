import 'package:avme_wallet/app/src/controller/ui/market_info.dart';
import 'package:avme_wallet/app/src/controller/wallet/account.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/balance.dart';
import 'package:avme_wallet/app/src/helper/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:avme_wallet/app/src/controller/db/app.dart';
import 'package:avme_wallet/app/src/screen/widgets/buttons.dart';
import 'package:avme_wallet/app/src/screen/widgets/hint.dart';
import 'package:avme_wallet/app/src/screen/widgets/painted.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';
import 'package:avme_wallet/app/src/screen/widgets/overview/market_data.dart';
import 'package:avme_wallet/app/src/model/db/market_data.dart' as db;
import 'package:provider/provider.dart';

import '../../../controller/wallet/token/coins.dart';
import '../../../controller/wallet/token/token.dart';
import '../../../helper/print.dart';
import '../../../helper/utils.dart';

class TokenValue extends StatefulWidget {
  final Widget image;
  final String amount;
  final String balance;
  final String valueDifference;
  final String name;

  const TokenValue({Key? key, required this.image, this.amount = "0", this.balance = "0", this.valueDifference = "0", required this.name}) : super(key: key);
  @override
  _TokenValueState createState() => _TokenValueState();
}

class _TokenValueState extends State<TokenValue> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.purple, width: 2),
          gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.bottomRight, colors: <Color>[
            Color(0xFF521380),
            Color(0xFF35174F),
          ])),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ///Fist Column with Data.
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      // color: Colors.red,
                        width: 38,
                        height: 38,
                        child: widget.image),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.amount + " " + widget.name,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "\$${widget.balance}",
                    style: TextStyle(fontSize: 12, color: AppColors.labelDisabledTransparent),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "+${widget.valueDifference}%",
                    style: TextStyle(fontSize: 12, color: AppColors.lightBlue),
                  ),
                ],
              ),
            ),

            ///This is the second column, icon only
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: DeviceSize.safeBlockHorizontal),
                    child: AppButton(
                      onPressed: () {
                        AppHint.show("Not implemented");
                      },
                      text: "BUY",
                      iconData: Icons.shopping_cart,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TokenTracker extends StatefulWidget {
  final Widget image;
  final String name;
  final String symbol;
  // final Function tokenSelector;
  // final String amount;
  // final String balance;
  // final String name;
  // final String symbol;
  // final String tokenValue;
  // final String? inPlatformToken;

  const TokenTracker({
    Key? key,
    required this.image,
    required this.name,
    required this.symbol,
    // required this.tokenSelector,
    // required this.token,
    // required this.balance,
      // required this.amount,
      // required this.balance,
      // required this.name,
      // required this.symbol,
      // required this.tokenValue,
      // this.inPlatformToken
    }) : super(key: key);
  @override
  _TokenTrackerState createState() => _TokenTrackerState();
}

class _TokenTrackerState extends State<TokenTracker> {
  // late Token _token;
  // late BalanceInfo _balanceInfo;
  bool synced = false;
  @override
  void initState() {
    super.initState();
    // _token = Coins.list.firstWhere((token) => token.name == widget.name);
    Token _token = Coins.list.firstWhere((token) => token.name == widget.name);
    // _balanceInfo = Account.current().balance.firstWhere((element) => element.name == widget.name);
    if(_token.value > 0)
    {
      synced = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: DeviceSize.screenHeight / 5
        // minHeight: SizeConfig.screenHeight / 2
      ),
      child: Container(
        margin: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.purple, width: 2),
          gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.bottomRight, colors: <Color>[
            // Color(0xFF521380),
            Color(0xFF521380),
            Color(0xFF35174F),
          ])
        ),
        child: Padding(
          padding: EdgeInsets.all(DeviceSize.safeBlockHorizontal * 3),
          child: ChangeNotifierProvider(
            create: (_) => Coins.list.firstWhere((element) => element.name == widget.name),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ///Fist Column with Data.
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Container(
                                // color: Colors.red,
                                width: 38,
                                height: 38,
                                child: widget.image
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: DeviceSize.safeBlockHorizontal * 2),
                              child: Text(
                                widget.symbol,
                                style: TextStyle(
                                  fontSize: DeviceSize.fontSizeLarge * 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Selector<Account, BalanceInfo>(
                          selector: accountSelectorWidget,
                          builder: (_, balanceInfo, __) {
                            return Text(
                              "${balanceInfo.qtd}",
                              style: TextStyle(
                                fontSize: DeviceSize.fontSizeLarge * 1.2,
                              ),
                            );
                          }
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Selector<Account, BalanceInfo>(
                          selector: accountSelectorWidget,
                          builder: (_, balanceInfo, __) {
                            return Text(
                              "\$${Utils.shortReadable(balanceInfo.inCurrency.toString())}",
                              style: AppTextStyles.span.copyWith(fontSize: DeviceSize.fontSizeLarge)
                            );
                          }
                        ),
                      ]
                      ..addAll([
                        SizedBox(height: 8),
                        // Selector<Coins, Token>(
                        //   selector: tokenSelectorWidget,
                        //   builder: (_, token, __) {
                        //     return Text("\$${token.value.toStringAsFixed(8)}", style: AppTextStyles.span.copyWith(fontSize: DeviceSize.fontSizeLarge));
                        //   }
                        // ),
                        Selector<Coins, double>(
                          selector: tokenSelectorWidget,
                          builder: (_, token, __) {
                            return Text("\$${token.toStringAsFixed(8)}", style: AppTextStyles.span.copyWith(fontSize: DeviceSize.fontSizeLarge));
                          }
                        ),
                      ])
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: FutureBuilder(
                    future: lastFiveBalance(),
                    builder: (context, AsyncSnapshot<List<double>> snapshot) {
                      if (snapshot.data != null) {
                        final List<double> tokenValues = snapshot.data!;
                        return Stack(
                          children: [
                            PaintedChart(
                              width: double.maxFinite,
                              height: DeviceSize.screenHeight / 7.5,
                              name: widget.name,
                              chartData: tokenValues,
                            ),
                            !synced
                            ? Positioned(
                              right: 8,
                              top: 6,
                              child: GestureDetector(
                                onTap: () {
                                  AppHint.show("This data is not synced.");
                                },
                                child: Icon(
                                  Icons.warning,
                                  color: Colors.yellow,
                                  size: DeviceSize.safeBlockHorizontal * 6,
                                ),
                              ),
                            )
                            : Container(),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: showDetailedMarketInfo,
                                child: Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                  size: DeviceSize.screenWidth * 0.1,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: AppColors.purple,
                            strokeWidth: 6,
                          ),
                        )
                      );
                    })
                  )
                ],
              ),
          ),
        ),
      ),
    );
  }

  BalanceInfo accountSelectorWidget(BuildContext context, Account account) {
    return Account.current().balance.firstWhere((element) => element.name == widget.name);
  }

  double tokenSelectorWidget(BuildContext context, Coins coins)
  {
    return coins.getCoins().firstWhere((element) => element.name == widget.name).value;
  }

  void showDetailedMarketInfo()
  {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext builder) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: DeviceSize.safeBlockHorizontal * 2),
          child: MarketData(
            name: widget.name,
            symbol: widget.symbol,
            image: widget.image,
            accountSelectorWidget: accountSelectorWidget,
            tokenSelectorWidget: tokenSelectorWidget,
          ),
        );
      }
    );
  }

  Future<List<double>> lastFiveBalance() async {
    List<double> tokenValues = [];
    List<db.MarketData> marketData = MarketInfo.previewWeek[widget.name.toUpperCase()]!;
    for(db.MarketData data in marketData)
    {
      tokenValues.add(data.value.toDouble());
    }

    if (tokenValues.length > 2) {
      return tokenValues;
    }
    return [
      5.0,
      5.0,
      5.0,
      5.0,
      5.0,
      5.0,
    ];
  }
}
