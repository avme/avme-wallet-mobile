import 'package:avme_wallet/app/src/controller/wallet/account.dart';
import 'package:avme_wallet/app/src/helper/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../controller/db/coin.dart';
import '../../../controller/wallet/balance.dart';
import '../buttons.dart';
import '../hint.dart';
import '../painted.dart';
import '../theme.dart';
import 'market_data.dart';

class TokenValue extends StatefulWidget {
  final Image image;
  final String amount;
  final String marketValue;
  final String valueDifference;
  final String name;

  const TokenValue({Key? key, required this.image, this.amount = "0", this.marketValue = "0", this.valueDifference = "0", required this.name}) : super(key: key);
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
                    "\$${widget.marketValue}",
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
  final Image image;
  final String amount;
  final String marketValue;
  final String name;
  final String asNetworkToken;

  const TokenTracker(
      {Key? key, required this.image, required this.amount, required this.marketValue, required this.asNetworkToken, required this.name})
      : super(key: key);
  @override
  _TokenTrackerState createState() => _TokenTrackerState();
}

class _TokenTrackerState extends State<TokenTracker> {
  @override
  Widget build(BuildContext context) {
    String name = widget.name == "PLATFORM" ? dotenv.env["PLATFORM_SYMBOL"]! : widget.name;
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
                            child: widget.image),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: DeviceSize.safeBlockHorizontal * 2),
                          child: Text(
                            name,
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
                    Text(
                      widget.amount,
                      style: TextStyle(
                        fontSize: DeviceSize.fontSizeLarge * 1.2,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text("\$${widget.marketValue}", style: AppTextStyles.span.copyWith(fontSize: DeviceSize.fontSizeLarge))
                  ]
                  ..addAll(
                    widget.asNetworkToken.length > 0
                    ? [ SizedBox(height: 8),
                      Text(widget.asNetworkToken, style: AppTextStyles.span.copyWith(fontSize: DeviceSize.fontSizeLarge)),]
                    : [])
                ),
              ),
              Expanded(
                flex: 3,
                child: FutureBuilder(
                  //future: requestLastFourBalance(widget.name),
                  future: lastFiveBalance(widget.name),
                  builder: (context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.data != null) {
                      final List tokenValues = snapshot.data!;
                      return Stack(
                        children: [
                          PaintedChart(
                            width: double.maxFinite,
                            height: DeviceSize.screenHeight / 7,
                            name: widget.name,
                            chartData: [
                              tokenValues.elementAt(4),
                              tokenValues.elementAt(3),
                              tokenValues.elementAt(2),
                              tokenValues.elementAt(1),
                              tokenValues.elementAt(0),
                              // 150,
                              // 95,
                              // 82,
                              // 80,
                              // 79,
                              // 75,
                              // 77,
                              // 78,
                              // 50,
                              // 62,
                              // 40,
                              // 80
                            ],
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MarketData(tokenName: widget.name)));
                                // TODO: Implement this page
                                // AppHint.show("Implement MarketData");
                              },
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
    );
  }
}

Future<List> lastFiveBalance(String name) async {
  List tokenValues = [];
  AccountData current = Account.current();
  if (name == 'PLATFORM') {
    // tokenValues.add(double.tryParse(appState.networkToken.value));
    tokenValues.add(current.platform.inCurrency);
  } else {
    Balance balance = current.balance.firstWhere((_balance) => _balance.name == name);
    tokenValues.add(balance.inCurrency);
  }

  await ValueHistoryTable.instance.readAmount(name, 4).then((value) => {
    value.forEach((element) {
      tokenValues.add(element.value.toDouble());
    })
  });

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
