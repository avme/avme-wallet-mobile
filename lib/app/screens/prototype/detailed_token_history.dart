// @dart=2.12
import 'dart:io';

import 'package:avme_wallet/app/controller/database/value_history.dart';
import 'package:avme_wallet/app/controller/services/contract.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/network_token.dart';
import 'package:avme_wallet/app/model/token.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart';
import 'package:tuple/tuple.dart';

class SyncFusionChart extends StatefulWidget {
  final String tokenName;

  const SyncFusionChart({Key? key,required this.tokenName}) : super(key: key);

  @override
  _SyncFusionChartState createState() => _SyncFusionChartState();
}

class _SyncFusionChartState extends State<SyncFusionChart> {

  late intl.DateFormat dateFormat;
  late CrosshairBehavior _crosshairBehavior;
  List<ChartSampleData> _chartData = [];
  late AvmeWallet app;
  double _minVal = 0;
  double _maxVal = 0;
  double _chartMinVal = 0;
  double _chartMaxVal = 0;

  Icon upArrow = Icon(Icons.arrow_upward,color: Colors.green, size: SizeConfig.fontSize*1.3,textDirection: TextDirection.ltr,);
  Icon downArrow = Icon(Icons.arrow_downward,color: Colors.red, size: SizeConfig.fontSize*1.3,textDirection: TextDirection.ltr,);
  Icon line = Icon(Icons.horizontal_rule,color: Colors.white, size: SizeConfig.fontSize*1.3, textDirection: TextDirection.ltr,);
  late WalletInterface iWallet;
  late Future pending;

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
    iWallet = WalletInterface(listen: true);
    app = iWallet.wallet;
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
            Map pendingData = snapshot.data as Map<String, dynamic>;
            if(snapshot.data != null)
              if(widget.tokenName.toUpperCase() == "AVAX") {
                return Container(
                  child:
                    Selector<AvmeWallet, NetworkToken>(
                      selector: (context, app) =>
                      app.networkToken,
                      builder: (_, networkToken, __) {
                        ///Getting the current date at each build/state
                        Map currentTokenInfo = updateCurrentData(
                          minVal: pendingData['aux'][1],
                          maxVal: pendingData['aux'][2],
                          aux: pendingData['aux'][0],
                          currentValue: networkToken.decimal.toDouble()
                        );
                        double variation = ((pendingData['aux'][2] - pendingData['aux'][1])/0.8)/8;
                        _chartMinVal = currentTokenInfo['minVal'];
                        _chartMaxVal = currentTokenInfo['maxVal'];
                        _minVal = currentTokenInfo['minVal'] - variation;
                        _maxVal = currentTokenInfo['maxVal'] + variation;
                        // print('minVal ${currentTokenInfo['minVal']}, maxVal ${currentTokenInfo['maxVal']}');
                        // print('INFO: variation $variation, minVal $_minVal, maxVal $_maxVal');
                        Map data = {
                          "symbol": "AVAX",
                          "name": "Avalanche",
                          "balance": iWallet.wallet.currentAccount.balance,
                          "res": 'assets/avax_logo.png'
                        };
                        return Column(
                          children: [
                            tokenCard(data),
                            FutureBuilder(
                              future: Future.delayed(Duration(milliseconds: 400), () =>generateChart(variation: variation)),
                              builder: (_, AsyncSnapshot<Widget> snapshot){
                                if(snapshot.data != null)
                                  return snapshot.data!;
                                else return Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        color: AppColors.purple,
                                        strokeWidth: 6,
                                      ),
                                    )
                                );
                              },
                            ),
                            valueList()
                          ],
                        );
                      },
                    )

                );
              }
              else return Container(
                child:
                  Selector<ActiveContracts, Token>(
                    selector: (context, activeContracts) =>
                    activeContracts.token,
                    builder: (_, tokenList, __) {
                      ///Getting the current date at each build/state
                      Map currentTokenInfo = updateCurrentData(
                          minVal: pendingData['aux'][1],
                          maxVal: pendingData['aux'][2],
                          aux: pendingData['aux'][0],
                          currentValue: tokenList.decimal(widget.tokenName).toDouble()
                      );
                      Map contractInfo = iWallet.wallet.activeContracts.sContracts.contractsRaw[widget.tokenName]!;
                      double variation = ((pendingData['aux'][2] - pendingData['aux'][1])/0.8)/8;
                      _chartMinVal = currentTokenInfo['minVal'];
                      _chartMaxVal = currentTokenInfo['maxVal'];
                      _minVal = currentTokenInfo['minVal'] - variation;
                      _maxVal = currentTokenInfo['maxVal'] + variation;
                      // print('minVal ${currentTokenInfo['minVal']}, maxVal ${currentTokenInfo['maxVal']}');
                      // print('INFO: variation $variation, minVal $_minVal, maxVal $_maxVal');
                      Map data = {
                        "symbol": contractInfo["symbol"],
                        "name": widget.tokenName,
                        "balance": iWallet.wallet.currentAccount.tokenBalance(name: widget.tokenName),
                        "res": contractInfo['logo']
                      };
                      return Column(
                        children: [
                          tokenCard(data),
                          FutureBuilder(
                            future: generateChart(variation: variation),
                            builder: (_, AsyncSnapshot<Widget> snapshot){
                              if(snapshot.data != null)
                                return snapshot.data!;
                              else return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                      color: AppColors.purple,
                                      strokeWidth: 6,
                                    ),
                                  )
                              );
                            },
                          ),
                          valueList()
                        ],
                      );
                    },
                  ),
              );
            else
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
        )
      )
    );
  }

  Widget tokenCard(Map tokenData){

    List<Widget> _image = [], _textList = [];
    List<Widget> _floatValue = [Text('Value: ${_chartData.last.close.toStringAsFixed(4)} ',style: TextStyle(fontSize: SizeConfig.fontSize*1.3))];
    double _percentage;

    Tooltip tooltip(String message, String title, double size){
      return Tooltip(
        decoration: BoxDecoration(
            color: AppColors.blue2,
            borderRadius: BorderRadius.circular(4)
        ),
        message: message,
        textStyle: TextStyle(color: Colors.white),
        preferBelow: false,
        child: Text(title,style: TextStyle(fontSize: SizeConfig.fontSize*size),),
      );
    }
    _percentage = 100-((_chartData.last.close*100)/_chartData.last.open);
    _percentage = _percentage.abs();
    if (_chartData.last.close>_chartData.last.open)
      _floatValue..add(Row(
        children: [
          Transform.translate(offset: Offset(-3,0),child: upArrow),
          Text('${_percentage.toString().substring(0,5)}%',style: TextStyle(fontSize: SizeConfig.fontSize*1.1,color: Colors.green),)
        ],
      ));
        // ..add();
    else if (_chartData.last.close<_chartData.last.open)
      _floatValue..add(Row(
        children: [
          Transform.translate(offset: Offset(-3,0),child: downArrow),
          Text('${_percentage.toString().substring(0,5)}%',style: TextStyle(fontSize: SizeConfig.fontSize*1.1,color: Colors.red),)
        ],
      ));
    else
      _floatValue..add(Row(
        children: [
          Transform.translate(offset: Offset(-3,0),child: line),
          Text('${_percentage.toString().substring(0,5)}%',style: TextStyle(fontSize: SizeConfig.fontSize*1.1,color: Colors.white),)
        ],
      ));

    _image..add(Text('Balance:',style: TextStyle(fontSize: SizeConfig.fontSize*2),))
      ..add(Text(shortAmount(tokenData['balance']),style: TextStyle(fontSize: SizeConfig.fontSize),))
      ..add(resolveImage(tokenData['res'], width: SizeConfig.safeBlockVertical * 10));

    _textList..add(Text('Token Info:',style: TextStyle(fontSize: SizeConfig.fontSize*1.8)))
      ..add(SizedBox(height: SizeConfig.safeBlockVertical,))
      ..add(Text('Name: ${tokenData['name']}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3)))
      ..add(Text('Symbol: ${tokenData['symbol']}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3)))
      ..add(Wrap(
        children:
          _floatValue
        )
      )
      ..add(Text('Highest: ${_chartMaxVal.toStringAsFixed(4)}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3,color: AppColors.labelDisabledColor)))
      ..add(Text('Lowest: ${_chartMinVal.toStringAsFixed(4)}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3,color: AppColors.labelDisabledColor)));

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
                  padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal*2),
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
                    minLeadingWidth: SizeConfig.safeBlockHorizontal * 0.2,
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LabelText((index + 1).toString()),
                      ],
                    ),
                    title: Transform.translate(
                      offset: Offset(-2,0),
                      child: Text('\$${shortAmount(this._chartData[invertedIndex].close.toString(), length: 12)}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3),)
                    ),
                    trailing: Wrap(
                      children: [
                        Text('${this._chartData[invertedIndex].x.month.toString().length==1 ? '0':''}${this._chartData[invertedIndex].x.month.toString()}'
                            '/${this._chartData[invertedIndex].x.day.toString().length==1 ? '0':''}${this._chartData[invertedIndex].x.day.toString()}'
                            '/${this._chartData[invertedIndex].x.year.toString().substring(2,4)}',
                          style: TextStyle(fontSize: SizeConfig.fontSize*1.3,overflow: TextOverflow.ellipsis),),
                      ]
                    ),
                    subtitle: _percentage > 0 ?
                      Transform.translate(
                        offset: Offset(-5,0),
                        child: Wrap(
                          children: [
                            this._chartData[invertedIndex].segmentColor==Colors.green
                                ? upArrow
                                : downArrow,
                            SizedBox(
                              width: SizeConfig.safeBlockHorizontal / 2,
                            ),
                            Text("${_percentage.toString().substring(0,5)} %"),
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
        margin: EdgeInsets.only(top: SizeConfig.safeBlockVertical),
        padding: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal*2,bottom: SizeConfig.safeBlockVertical),
        //margin: EdgeInsets.only(top: SizeConfig.safeBlockVertical),
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
            labelStyle: TextStyle(fontSize: SizeConfig.fontSize),
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
            labelStyle: TextStyle(fontSize: SizeConfig.fontSize),
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
    await ValueHistoryTable.instance.readAmount(tokenName, 30).then((value) =>
    {
      value.reversed.forEach((element) {
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
      })
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

    if(this._minVal > 0)
      this._chartData.last =
        ChartSampleData(
          DateTime(this._chartData.last.x.year,this._chartData.last.x.month,this._chartData.last.x.day)
          ,aux,
          currentValue);
    else
      this._chartData.add(
        ChartSampleData(
          DateTime(this._chartData.last.x.year,this._chartData.last.x.month,this._chartData.last.x.day+1)
          ,aux,
          currentValue)
      );
    this._chartData.forEach((element) => print(element));
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

