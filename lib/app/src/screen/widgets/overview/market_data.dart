import 'package:avme_wallet/app/src/controller/db/app.dart';
import 'package:avme_wallet/app/src/controller/ui/market_info.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:avme_wallet/app/src/helper/extensions.dart';
import 'package:avme_wallet/app/src/helper/size.dart';
import 'package:avme_wallet/app/src/screen/widgets/generic.dart';
import 'package:avme_wallet/app/src/screen/widgets/overview/chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:avme_wallet/app/src/controller/wallet/account.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/balance.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/token.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';

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

  EdgeInsets containerPadding = const EdgeInsets.all(8.0);
  late List<ChartData> chartData;
  @override
  void initState() {
    super.initState();
    chartData = MarketInfo.chartData[widget.name.toUpperCase()] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (DeviceSize.screenHeight / 5) * 4,
      child: Column(
        children: [
          ///Basic Info
          Container(
            // color: Colors.white.withOpacity(0.2),
            child: Row(
              children: [
                Flexible(
                  // flex: 2,
                  child: Container(
                    // color: Colors.yellow.withOpacity(0.2),
                    padding: containerPadding.copyWith(bottom: 0),
                    child: Container(
                      // color: Colors.red,
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
                          : Container(
                            // color: Colors.blue,
                            child: Row(
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
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ///Graph
          Expanded(
            flex: 3,
            child: MarketChart(
              name: widget.name,
              symbol: widget.symbol,
              containerPadding: containerPadding,
              chartData: chartData,
            ),
          ),
          ///Rows
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.darkBlue,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ListView.builder(
                  itemCount: chartData.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (_, index) {
                    int invertedIndex = (chartData.length - 1) - index;
                    double _percentage = 0;
                    try
                    {
                      if(chartData[invertedIndex - 1].close! > 0)
                        _percentage = 100-((chartData[invertedIndex - 1].close! * 100)/chartData[invertedIndex].close!);
                      else
                        _percentage = 0;
                    }
                    catch(e)
                    {
                      if(e is RangeError)
                        _percentage = 0;
                      else throw e;
                    }
                    _percentage = _percentage.abs();
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          minLeadingWidth: DeviceSize.safeBlockHorizontal * 0.2,
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LabelText((index + 1).toString()),
                            ],
                          ),
                          title: Transform.translate(
                            offset: Offset(-2,0),
                            child: Text('\$${chartData[invertedIndex].close}',
                              style: TextStyle(
                                fontSize:DeviceSize.fontSize*1.3
                              ),
                            )
                          ),
                          trailing: Wrap(
                            children: [
                              Text('${chartData[invertedIndex].x!.month.toString().length==1 ? '0':''}${chartData[invertedIndex].x!.month.toString()}'
                                  '/${chartData[invertedIndex].x!.day.toString().length==1 ? '0':''}${chartData[invertedIndex].x!.day.toString()}'
                                  '/${chartData[invertedIndex].x!.year.toString().substring(2,4)}',
                                style: TextStyle(fontSize: DeviceSize.fontSize*1.3,overflow: TextOverflow.ellipsis),),
                            ]
                          ),
                          ///TODO: Implement percentages and arrows to indicate
                          // subtitle: _percentage > 0 ?
                          // Transform.translate(
                          //   offset: Offset(-5,0),
                          //   child: Wrap(
                          //       children: [
                          //         chartData[invertedIndex].segmentColor==Colors.green
                          //             ? upArrow
                          //             : downArrow,
                          //         SizedBox(
                          //           width: SizeConfig.safeBlockHorizontal / 2,
                          //         ),
                          //         Text("${_percentage.toString().substring(0,5)} %", style: TextStyle(fontSize: SizeConfig.fontSize),),
                          //       ]
                          //   ),
                          // )
                          //     : null,
                        ),
                        index != (chartData.length - 1)
                            ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child:
                          Divider(
                            thickness: 1,
                            height: 0,
                          ),
                        )
                            : Container(),
                      ],
                    );
                  },
                ),
              ),
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
      fractionDigits = 8;    }
    return "\$ ${value.toStringAsFixed(fractionDigits)}";
  }
}
