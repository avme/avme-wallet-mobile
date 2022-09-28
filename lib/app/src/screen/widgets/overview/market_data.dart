import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:avme_wallet/app/src/helper/extensions.dart';
import 'package:avme_wallet/app/src/helper/size.dart';
import 'package:avme_wallet/app/src/screen/widgets/generic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controller/wallet/account.dart';
import '../../../controller/wallet/token/balance.dart';
import '../../../controller/wallet/token/token.dart';
import '../../../helper/print.dart';

class MarketData extends StatefulWidget {

  final String name;
  final String symbol;
  final Widget image;
  final BalanceInfo Function(BuildContext, Account) accountSelectorWidget;
  final double Function(BuildContext, Coins) tokenSelectorWidget;
  const MarketData({
    Key? key,
    required this.name,
    required this.symbol,
    required this.image,
    required this.accountSelectorWidget,
    required this.tokenSelectorWidget,
  }) : super(key: key);

  @override
  State<MarketData> createState() => _MarketDataState();
}

class _MarketDataState extends State<MarketData> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (DeviceSize.screenHeight / 5) * 4,
      child: Column(
        children: [
          ///Basic Info
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white.withOpacity(0.2),
              child: Row(
                children: [
                  Flexible(
                    // flex: 2,
                    child: Container(
                      color: Colors.yellow.withOpacity(0.2),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: SizedBox(
                                  width: DeviceSize.safeBlockVertical * 4.66,
                                  height: DeviceSize.safeBlockVertical * 4.66,
                                  child: widget.image
                                ),
                              ),
                              Text("${widget.name.capitalize()} (${widget.symbol})",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                          SpaceGap(),
                          Row(
                            children: [
                              Selector<Coins, double>(
                                selector: widget.tokenSelectorWidget,
                                builder: (_, value, __) {
                                  return Text(tokenValue(value),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: DeviceSize.fontSizeHuge
                                    ),
                                  );
                                }
                              ),
                            ],
                          ),
                          SpaceGap(),
                          widget.name == Coins.getPlatformToken.name.toUpperCase()
                          ? Container()
                          // : Text("${widget.}")
                          : Row(
                            children: [
                              Selector<Account, BalanceInfo>(
                                selector: widget.accountSelectorWidget,
                                builder: (_, balanceInfo, __) {
                                  Token platform = Coins.getPlatformToken;
                                  return Text("${(balanceInfo.token.value / platform.value).toStringAsFixed(8)} ${platform.symbol}",
                                      style: TextStyle(
                                      fontSize: DeviceSize.fontSize
                                    ),
                                  );
                                }
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  // Flexible(
                  //   flex: 1,
                  //   child: Container(
                  //     color: Colors.green.withOpacity(0.2),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          ///Graph
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          ///Rows
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.yellow.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  String tokenValue(double value)
  {
    //"\$ ${value > 10 ? value.toStringAsFixed(5) : value.toStringAsFixed(8)}"
    int fractionDigits = 2;
    if(value < 10)
    {
      fractionDigits = 6;
    }
    if(value < 1.0)
    {
      fractionDigits = 8;
    }
    return "\$ ${value.toStringAsFixed(fractionDigits)}";
  }
}
