import 'package:avme_wallet/app/controller/database/value_history.dart';
import 'package:avme_wallet/app/controller/services/database_token_value.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/detailed_token_history.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'button.dart';
import 'notification_bar.dart';
import 'painted_chart.dart';

class TokenValue extends StatefulWidget {
  final Image image;
  final String amount;
  final String marketValue;
  final String valueDifference;
  final String name;

  const TokenValue({Key key, @required this.image, this.amount = "0", this.marketValue = "0", this.valueDifference = "0", @required this.name})
      : super(key: key);
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
                    padding: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal),
                    child: AppButton(
                      onPressed: () {
                        NotificationBar().show(context, text: "Not implemented");
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
      {Key key, @required this.image, @required this.amount, @required this.marketValue, @required this.asNetworkToken, @required this.name})
      : super(key: key);
  @override
  _TokenTrackerState createState() => _TokenTrackerState();
}

class _TokenTrackerState extends State<TokenTracker> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: SizeConfig.screenHeight / 5
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
            ])),
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 3),
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
                            padding: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 2),
                            child: Text(
                              widget.name,
                              style: TextStyle(
                                fontSize: SizeConfig.fontSizeLarge * 1.2,
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
                          fontSize: SizeConfig.fontSizeLarge * 1.2,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text("\$${widget.marketValue}", style: AppTextStyles.span.copyWith(fontSize: SizeConfig.fontSizeLarge))
                    ]..addAll(widget.asNetworkToken.length > 0
                        ? [
                            SizedBox(
                              height: 8,
                            ),
                            Text(widget.asNetworkToken, style: AppTextStyles.span.copyWith(fontSize: SizeConfig.fontSizeLarge)),
                          ]
                        : [])),
              ),
              Expanded(
                  flex: 3,
                  child: FutureBuilder(
                      //future: requestLastFourBalance(widget.name),
                      future: lastFiveBalance(widget.name, app),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          final List tokenValues = snapshot.data;
                          return Stack(
                            children: [
                              PaintedChart(
                                width: double.maxFinite,
                                height: SizeConfig.screenHeight / 7,
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
                                  onTap: () =>
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => SyncFusionChart(tokenName: widget.name))),
                                  child: Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                    size: SizeConfig.screenWidth * 0.1,
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
                        ));
                      }))
            ],
          ),
        ),
      ),
    );
  }
}

Future<List> lastFiveBalance(String name, AvmeWallet appState) async {
  List tokenValues = [];
  if (name == 'AVAX') {
    tokenValues.add(double.tryParse(appState.networkToken.value));
  } else
    tokenValues.add(double.tryParse(appState.activeContracts.token.tokenValue(name)));
  await ValueHistoryTable.instance.readAmount(name, 4).then((value) => {
        value.forEach((element) {
          tokenValues.add(element.value.toDouble());
        })
      });
  if (tokenValues.length > 2) return tokenValues;
  return [
    5.0,
    5.0,
    5.0,
    5.0,
    5.0,
    5.0,
  ];
  return tokenValues;
}
