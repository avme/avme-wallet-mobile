import 'dart:io';
import 'package:avme_wallet/app/src/controller/wallet/account.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/model/db/market_data.dart' as model;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart';

import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart' as Coins;
import 'package:avme_wallet/app/src/helper/size.dart';
import 'package:avme_wallet/app/src/helper/utils.dart';
import 'package:avme_wallet/app/src/screen/widgets/card.dart';
import 'package:avme_wallet/app/src/screen/widgets/generic.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';
import 'package:avme_wallet/app/src/controller/db/app.dart';
import 'package:avme_wallet/app/src/controller/wallet/balance.dart';

class MarketData extends StatefulWidget {
  final String tokenName;

  const MarketData({Key? key,required this.tokenName}) : super(key: key);

  @override
  _MarketDataState createState() => _MarketDataState();
}

class _MarketDataState extends State<MarketData> {

  late intl.DateFormat dateFormat;
  late CrosshairBehavior _crosshairBehavior;
  List<ChartSampleData> _chartData = [];
  double _minVal = 0;
  double _maxVal = 0;
  double _chartMinVal = 0;
  double _chartMaxVal = 0;

  Icon upArrow = Icon(Icons.arrow_upward, color: Colors.green, size: DeviceSize.fontSize * 1.3, textDirection: TextDirection.ltr,);
  Icon downArrow = Icon(Icons.arrow_downward, color: Colors.red, size: DeviceSize.fontSize * 1.3, textDirection: TextDirection.ltr,);
  Icon line = Icon(Icons.horizontal_rule, color: Colors.white, size: DeviceSize.fontSize * 1.3, textDirection: TextDirection.ltr,);
  late Future pending;
  late String name;
  @override
  void initState() {
    initializeDateFormatting();
    _crosshairBehavior = CrosshairBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      shouldAlwaysShow: true,
      lineDashArray: [5,5]
    );
    pending = queryDays(widget.tokenName);
    name = widget.tokenName == "PLATFORM" ? dotenv.env["PLATFORM_SYMBOL"]! : widget.tokenName;
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: AppCard(
        child: FutureBuilder(
          future: pending,
          builder: (BuildContext context,snapshot) {
            if(snapshot.data != null) {
              Map pendingData = snapshot.data as Map<String, dynamic>;
              Print.mark("pendingData $pendingData");
              if(widget.tokenName.toUpperCase() == "PLATFORM") {
                return Container(
                  child:
                  Consumer<Coins.Coins>(
                    builder: (_, coins, __) {
                      ///Getting the current date at each build/state
                      Map currentTokenInfo = updateCurrentData(
                        minVal: pendingData['aux'][1],
                        maxVal: pendingData['aux'][2],
                        aux: pendingData['aux'][0],
                        currentValue: coins.getPlatform().value
                      );
                      double variation = ((pendingData['aux'][2] - pendingData['aux'][1])/0.8)/8;
                      _chartMinVal = currentTokenInfo['minVal'];
                      _chartMaxVal = currentTokenInfo['maxVal'];
                      _minVal = currentTokenInfo['minVal'] - variation;
                      _maxVal = currentTokenInfo['maxVal'] + variation;
                      // print('minVal ${currentTokenInfo['minVal']}, maxVal ${currentTokenInfo['maxVal']}');
                      // print('INFO: variation $variation, minVal $_minVal, maxVal $_maxVal');
                      Map data = {
                        "symbol": dotenv.env["PLATFORM_SYMBOL"],
                        "name": dotenv.env["PLATFORM_NAME"],
                        "balance": Account.current().platform.inCurrency,
                        "res": dotenv.env["PLATFORM_IMAGE"]
                      };
                      // return Center(
                      //   child: Text("Get Coins ${coins.getPlatform().value}"),
                      // );
                      return Column(
                        children: [
                          tokenCard(data),
                          FutureBuilder(
                            future: Future.delayed(Duration(milliseconds: 400), () =>generateChart(variation: variation)),
                            builder: (_, AsyncSnapshot<Widget> snapshot){
                              if(snapshot.data == null) {
                                return Expanded(
                                  flex: 6,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        color: AppColors.purple,
                                        strokeWidth: 6,
                                      ),
                                    )
                                  ),
                                );
                              }
                              return snapshot.data!;
                            },
                          ),
                          valueList()
                        ],
                      );
                    },
                  )
                );
              }
              else {
                return Container(
                  child:
                  Consumer<Coins.Coins>(
                    builder: (_, coins, __) {
                      Coins.CoinData coin = coins.getCoins().firstWhere((_coin) => _coin.name == widget.tokenName);
                      Balance balance = Account.current().balance.firstWhere((_balance) => _balance.name == coin.name);
                      ///Getting the current date at each build/state
                      Map currentTokenInfo = updateCurrentData(
                        minVal: pendingData['aux'][1],
                        maxVal: pendingData['aux'][2],
                        aux: pendingData['aux'][0],
                        currentValue: coin.value
                      );
                      // Map contractInfo = iWallet.wallet.activeContracts.sContracts.contractsRaw[widget.tokenName]!;
                      double variation = ((pendingData['aux'][2] - pendingData['aux'][1])/0.8)/8;
                      _chartMinVal = currentTokenInfo['minVal'];
                      _chartMaxVal = currentTokenInfo['maxVal'];
                      _minVal = currentTokenInfo['minVal'] - variation;
                      _maxVal = currentTokenInfo['maxVal'] + variation;
                      // print('minVal ${currentTokenInfo['minVal']}, maxVal ${currentTokenInfo['maxVal']}');
                      // print('INFO: variation $variation, minVal $_minVal, maxVal $_maxVal');
                      Map data = {
                        "symbol": coin.symbol,
                        "name": coin.name,
                        "balance": balance.inCurrency,
                        "res": coin.image
                      };
                      return Column(
                        children: [
                          tokenCard(data),
                          FutureBuilder(
                            future: generateChart(variation: variation),
                            builder: (_, AsyncSnapshot<Widget> snapshot){
                              if(snapshot.data != null) {
                                return snapshot.data!;
                              } else {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                      color: AppColors.purple,
                                      strokeWidth: 6,
                                    ),
                                  )
                              );
                              }
                            },
                          ),
                          valueList()
                        ],
                      );
                    },
                  ),
                );
              }
            } else {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: AppColors.purple,
                    strokeWidth: 6,
                  ),
                )
              );
            }
          }
        )
      )
    );
  }

  Widget tokenCard(Map tokenData){

    List<Widget> _image = [], _textList = [];
    List<Widget> _floatValue = [Text('Value: ${_chartData.last.close.toStringAsFixed(4)} ',style: TextStyle(fontSize: DeviceSize.fontSize*1.3))];
    late double _percentage;

    _percentage = 100-((_chartData.last.close*100)/_chartData.last.open);
    _percentage = _percentage.abs();
    if (_chartData.last.close>_chartData.last.open) {
      _floatValue..add(
        Row(
          children: [
            Transform.translate(offset: Offset(-3,0),child: upArrow),
            Text('${_percentage.toString().substring(0,5)}%',style: TextStyle(fontSize: DeviceSize.fontSize*1.1,color: Colors.green),)
          ],
        )
      );
    }
    else if (_chartData.last.close<_chartData.last.open)
      _floatValue..add(
        Row(
          children: [
            Transform.translate(offset: Offset(-3,0),child: downArrow),
            Text('${_percentage.toString().substring(0,5)}%',style: TextStyle(fontSize: DeviceSize.fontSize*1.1,color: Colors.red),)
          ],
        )
      );
    else {
      _floatValue..add(
        Row(
          children: [
            Transform.translate(offset: Offset(-3,0),child: line),
            Text('${_percentage.toString().substring(0,5)}%',style: TextStyle(fontSize: DeviceSize.fontSize*1.1,color: Colors.white),)
          ],
        )
      );
    }

    _image..add(Text('Balance:',style: TextStyle(fontSize: DeviceSize.fontSize*2),))
      ..add(Text(Utils.shortReadable(tokenData['balance'].toStringAsFixed(6)),style: TextStyle(fontSize: DeviceSize.fontSize),))
      ..add(Utils.resolveImage(tokenData['res'], width: DeviceSize.safeBlockVertical * 10));

    _textList..add(Text('Token Info:',style: TextStyle(fontSize: DeviceSize.fontSize*1.8)))
      ..add(SizedBox(height: DeviceSize.safeBlockVertical,))
      ..add(Text('Name: ${tokenData['name']}',style: TextStyle(fontSize: DeviceSize.fontSize*1.3)))
      ..add(Text('Symbol: ${tokenData['symbol']}',style: TextStyle(fontSize: DeviceSize.fontSize*1.3)))
      ..add(Wrap(children: _floatValue))
      ..add(Text('Highest: ${_chartMaxVal.toStringAsFixed(4)}',style: TextStyle(fontSize: DeviceSize.fontSize*1.3,color: AppColors.labelDisabledColor)))
      ..add(Text('Lowest: ${_chartMinVal.toStringAsFixed(4)}',style: TextStyle(fontSize: DeviceSize.fontSize*1.3,color: AppColors.labelDisabledColor)));

    return Expanded(
      flex: 3,
      child: Container(
        width: double.maxFinite,
        //color: Colors.lightGreenAccent[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(flex: 6,
              child: Container(
                padding: EdgeInsets.only(left: DeviceSize.safeBlockHorizontal*2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _textList,
                ),
              )
            ),
            Expanded(flex: 4,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _image,
                )
              )
            ),
          ],
        )
      ),
    );
  }

  Widget valueList(){
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.darkBlue,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ListView.builder(
            itemCount: this._chartData.length,
            padding: EdgeInsets.zero,
            itemBuilder: (_, index) {
              int invertedIndex = (this._chartData.length - 1) - index;
              double _percentage = 0;
              try
              {
                if(_chartData[invertedIndex - 1].close > 0)
                  _percentage = 100-((_chartData[invertedIndex - 1].close*100)/_chartData[invertedIndex].close);
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
                      child: Text('\$${this._chartData[invertedIndex].close.toStringAsPrecision(8)}',style: TextStyle(fontSize: DeviceSize.fontSize*1.3),)
                    ),
                    trailing: Wrap(
                        children: [
                          Text('${this._chartData[invertedIndex].x.month.toString().length==1 ? '0':''}${this._chartData[invertedIndex].x.month.toString()}'
                            '/${this._chartData[invertedIndex].x.day.toString().length==1 ? '0':''}${this._chartData[invertedIndex].x.day.toString()}'
                            '/${this._chartData[invertedIndex].x.year.toString().substring(2,4)}',
                            style: TextStyle(fontSize: DeviceSize.fontSize*1.3,overflow: TextOverflow.ellipsis),),
                        ]
                    ),
                    subtitle:
                      _percentage > 0
                      ? Transform.translate(
                          offset: Offset(-5,0),
                          child: Wrap(
                            children: [
                              this._chartData[invertedIndex].segmentColor==Colors.green
                                ? upArrow
                                : downArrow,
                              SizedBox(
                                width: DeviceSize.safeBlockHorizontal / 2,
                              ),
                              Text("${_percentage.toString().substring(0,5)} %", style: TextStyle(fontSize: DeviceSize.fontSize),),
                            ]
                          ),
                        )
                      : null,
                  ),
                  index != (this._chartData.length - 1)
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
    );
  }

  Future<Widget> generateChart({
    double variation = 0
  }) async {
    return Expanded(
      flex: 6,
      child: Container(
        // width: double.maxFinite,
        margin: EdgeInsets.only(top: DeviceSize.safeBlockVertical),
        padding: EdgeInsets.only(right: DeviceSize.safeBlockHorizontal*2,bottom: DeviceSize.safeBlockVertical),
        //margin: EdgeInsets.only(top: DeviceSize.safeBlockVertical),
        child: SfCartesianChart(
          crosshairBehavior: _crosshairBehavior,
          //borderColor: AppColors.purple,
          //borderWidth: 2,
          //plotAreaBorderColor: Colors.green,
          plotAreaBackgroundColor: AppColors.darkBlue,
          zoomPanBehavior: ZoomPanBehavior(
            zoomMode: ZoomMode.x,
            enablePinching: true,
            enablePanning: true,
            maximumZoomLevel: 0.2
          ),
          series: <CandleSeries>[
            CandleSeries<ChartSampleData,DateTime>(
              //borderWidth: 5,
              //bearColor: Colors.green,
              //bullColor: Colors.pinkAccent,
              enableSolidCandles: true,
              dataSource: _chartData,
              xValueMapper: (ChartSampleData sales, _) => sales.x,
              lowValueMapper: (ChartSampleData sales, _) => sales.low,
              highValueMapper: (ChartSampleData sales, _) => sales.high,
              closeValueMapper: (ChartSampleData sales, _) => sales.close,
              openValueMapper: (ChartSampleData sales, _) => sales.open,
              pointColorMapper: (ChartSampleData sales, _) => sales.segmentColor,
            )
          ],
          primaryXAxis: DateTimeAxis(
            labelStyle: TextStyle(fontSize: DeviceSize.fontSize),
            dateFormat: intl.DateFormat.MMMd(Platform.localeName),
            majorGridLines: MajorGridLines(width: 1,dashArray: [1,5]),
            interval: 5,
            minimum: DateTime(_chartData.first.x.year,_chartData.first.x.month,_chartData.first.x.day-1),
            maximum: DateTime(_chartData.last.x.year,_chartData.last.x.month,_chartData.last.x.day+1),
            //rangePadding: ChartRangePadding.additional,
            interactiveTooltip: InteractiveTooltip(
              enable: true,
              canShowMarker: false
            )
          ),
          primaryYAxis: NumericAxis(
            labelStyle: TextStyle(fontSize: DeviceSize.fontSize),
            minimum: _minVal,
            maximum: _maxVal,
            interval: variation,
            numberFormat: intl.NumberFormat.simpleCurrency(decimalDigits: 3),
            interactiveTooltip: InteractiveTooltip(
              enable: true,
              //canShowMarker: false
            )
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> queryDays(String tokenName)
  async {
    List<ChartSampleData> days = [];
    bool isFirst = true;
    double _aux = 0, _minVal = 0, _maxVal = 0;
    List<model.MarketData> tokenHistory = await WalletDB.viewMarketDataMonth(tokenName, offset: 1);
    tokenHistory.reversed.forEach((element) {
      if (isFirst)
      {
        _aux = element.value.toDouble();
        _maxVal = _minVal = _aux;
        isFirst = false;
      } else {
        days.add(ChartSampleData(
          DateTime.fromMillisecondsSinceEpoch(int.tryParse(element.dateTime.toString()+'000')!,isUtc: true),
          _aux,
          element.value.toDouble()));
        _aux = element.value.toDouble();
        if (element.value.toDouble()>_maxVal) _maxVal = element.value.toDouble();
        if (element.value.toDouble()<_minVal) _minVal = element.value.toDouble();
      }
    });
    _chartData = days;
    return {"chartSampleData": days, "aux": [_aux, _minVal, _maxVal]};
  }

  Map<String,dynamic>updateCurrentData({
    // List<ChartSampleData> chartSampleData = const [],
    required double aux,
    required double minVal,
    required double maxVal,
    required double currentValue
  }) {

    Map<String,dynamic> _chartInfo;
    if(this._minVal > 0) {
      this._chartData.last =
        ChartSampleData(
          DateTime(
            this._chartData.last.x.year,
            this._chartData.last.x.month,
            this._chartData.last.x.day
          ),
        aux,
        currentValue
      );
    } else {
      this._chartData.add(
        ChartSampleData(
          DateTime(
            this._chartData.last.x.year,
            this._chartData.last.x.month,
            this._chartData.last.x.day + 1
          ),
          aux,
          currentValue
        )
      );
    }
    //this._chartData.forEach((element) => print(element));
    _chartInfo = {
      'chartData' : this._chartData,
      'minVal' : minVal,
      'maxVal' : maxVal,
    };
    return _chartInfo;
  }
}

class ChartSampleData{
  final DateTime x;
  final num open, close;
  final low, high;
  final Color segmentColor;

  ChartSampleData(this.x,this.open,this.close) :
    this.low = close,
    this.high = open,
    this.segmentColor = (close >= open) ? Colors.green : Colors.red;

  @override
  String toString() {
    return 'ChartSampleData{x: $x, open: $open, close: $close}';
  }
}

