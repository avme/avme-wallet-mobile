// @dart=2.12
import 'dart:io';

import 'package:avme_wallet/app/controller/database/value_history.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class SyncFusionChart extends StatefulWidget {
  final String tokenName;

  const SyncFusionChart({Key? key,required this.tokenName}) : super(key: key);

  @override
  _SyncFusionChartState createState() => _SyncFusionChartState();
}

class _SyncFusionChartState extends State<SyncFusionChart> {

  late DateFormat dateFormat;
  late CrosshairBehavior _crosshairBehavior;
  late List<ChartSampleData> _chartData;
  late double _minVal ,_maxVal ,_chartMinVal ,_chartMaxVal;

  Icon uparrow = Icon(Icons.arrow_upward,color: Colors.green);
  Icon downarrow = Icon(Icons.arrow_downward,color: Colors.red);
  Icon line = Icon(Icons.horizontal_rule,color: Colors.white);

  @override
  void initState() {
    //Maybe remove this, this would make so the date axis would display as
    //the user's phone locale, but leaving could also be used to force an US style
    initializeDateFormatting();
    _crosshairBehavior = CrosshairBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        shouldAlwaysShow: true,
        lineDashArray: [5,5]
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AvmeWallet app = Provider.of<AvmeWallet>(context, listen:false);
    /*
    For the list to work, best thing to do is to change most of the code so it
    will load based on the current variable and not a set parameter like it currently is.
    Maybe add a new method in the database interface so it loads absolutely everything
    and do a manual filter when loading info here based off the current token name given?
    List can be just a setState that changes the name variable
     */

    tokenCard(){

      List<Widget> _image = [], _textList = [];
      List<Widget> _floatValue = [Text('Value: ${_chartData.last.close.toStringAsFixed(4)}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3))];
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

      if (_chartData.last.close>_chartData.last.open)
      {
        _floatValue..add(uparrow)
          ..add(Text('\$${_chartData.last.close.toString().substring(0,8)}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3,color: Colors.green),));
      } if (_chartData.last.close<_chartData.last.open) {
        _floatValue..add(downarrow)
          //..add(Text('\$${_chartData.last.close.toString().substring(0,8)}',style: TextStyle(fontSize: SizeConfig.fontSize*1.6,color: Colors.red),));
          ..add(Text('${_percentage.toString().substring(0,4)}%',style: TextStyle(fontSize: SizeConfig.fontSize*1.3,color: Colors.red),));
      } else {
        _floatValue..add(line)
          ..add(Text('\$${_chartData.last.close.toString().substring(0,8)}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3,color: Colors.white),));
      }

      if(widget.tokenName=='AVAX')
      {

        _image..add(Text('Balance:',style: TextStyle(fontSize: SizeConfig.fontSize*2),))
          ..add(Text(shortAmount(app.currentAccount.balance),style: TextStyle(fontSize: SizeConfig.fontSize),))
          ..add(resolveImage('assets/avax_logo.png', width: SizeConfig.safeBlockVertical * 10));

        _textList..add(Text('Token Info:',style: TextStyle(fontSize: SizeConfig.fontSize*1.8)))
          ..add(SizedBox(height: SizeConfig.safeBlockVertical,))
          ..add(Text('Name: Avalanche',style: TextStyle(fontSize: SizeConfig.fontSize*1.3)))
          ..add(Text('Symbol: ${widget.tokenName}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3)))
          ..add(Row(children: _floatValue))
          ..add(Text('Highest: ${_chartMaxVal.toStringAsFixed(4)}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3,color: AppColors.labelDisabledColor)))
          ..add(Text('Lowest: ${_chartMinVal.toStringAsFixed(4)}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3,color: AppColors.labelDisabledColor)));

      } else {

        _image..add(Text('Balance:',style: TextStyle(fontSize: SizeConfig.fontSize*1.8),))
          ..add(Text(shortAmount(shortAmount(app.currentAccount.tokenWei(name: widget.tokenName))),style: TextStyle(fontSize: SizeConfig.fontSize),))
          ..add(resolveImage(app.activeContracts.sContracts.contractsRaw[widget.tokenName]!["logo"], width: SizeConfig.safeBlockVertical * 10));

        _textList..add(Text('Token Info:',style: TextStyle(fontSize: SizeConfig.fontSize*2)))
          ..add(SizedBox(height: SizeConfig.safeBlockVertical,))
          ..add(Text(
              'Name: ${app.activeContracts.sContracts.contractsRaw.keys.firstWhere(
                      (element) => app.activeContracts.sContracts.contractsRaw[element]!['symbol']==widget.tokenName)}',
              style: TextStyle(fontSize: SizeConfig.fontSize*1.3)))
          ..add(Text('Symbol: ${widget.tokenName}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3)))
          ..add(Row(children: _floatValue))
          ..add(Text('Highest: ${_chartMaxVal.toStringAsFixed(4)}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3,color: AppColors.labelDisabledColor)))
          ..add(Text('Lowest: ${_chartMinVal.toStringAsFixed(4)}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3,color: AppColors.labelDisabledColor)));

        /*
        _image..add(resolveImage(app.activeContracts.sContracts.contractsRaw[widget.tokenName]!["logo"], width: SizeConfig.safeBlockVertical * 7))
          ..add(tooltip('Token name', widget.tokenName, 1.6));

          _textList..add(tooltip('Token amount', shortAmount(app.currentAccount.tokenWei(name: widget.tokenName)),2))
          ..add(tooltip('Market value', shortAmount(app.currentAccount.tokenBalance(name: widget.tokenName),comma: false, length: 3), 1.6))
          ..add(Tooltip(
            decoration: BoxDecoration(
                color: AppColors.blue2,
                borderRadius: BorderRadius.circular(4)
            ),
            message: 'Last day difference',
            textStyle: TextStyle(color: Colors.white),
            preferBelow: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _floatValue,
            ),
          ));
         */

         }

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
                        //color: Colors.yellow,
                        //padding: EdgeInsets.all(SizeConfig.safeBlockVertical*3),
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

    valueList(){

      List<Widget> rows = [];

      _chartData.forEach((element) {
        rows.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    (element.segmentColor==Colors.green) ? uparrow : downarrow,
                    //'${element.x.month}/${element.x.day.toString().length==1 ? '0'+element.x.day.toString() : element.x.day.toString()}'
                    Text('${element.x.month.toString().length==1 ? '0':''}${element.x.month.toString()}'
                        '/${element.x.day.toString().length==1 ? '0':''}${element.x.day.toString()}'
                        '/${element.x.year.toString().substring(2,4)}',
                      style: TextStyle(fontSize: SizeConfig.fontSize*1.3,overflow: TextOverflow.ellipsis),),
                  ]
                ),
                Text('\$${element.close}',style: TextStyle(fontSize: SizeConfig.fontSize*1.3),)
              ],
            )
        );
      });

      return Expanded(
        flex: 3,
        child: Container(
          color: AppColors.darkBlue,
          margin: EdgeInsets.only(
            left: SizeConfig.safeBlockHorizontal*4,
            right: SizeConfig.safeBlockHorizontal*4,
          ),
          child: ListView.separated(
            itemCount: _chartData.length,
            separatorBuilder: (BuildContext context, int index) => Divider(height: 0),
            itemBuilder: (BuildContext context, int index)
            {
              return ListTile(
                title: rows.reversed.elementAt(index),
              );
            },
          ),
        ),
      );
    }

    graph(AsyncSnapshot snapshot){
      final Map<String,dynamic> _chartInfo = snapshot.data as Map<String,dynamic>;
      _chartData = _chartInfo['chartData'];
      final variation = ((_chartInfo['maxVal'] - _chartInfo['minVal'])/0.8)/8;
      _chartMinVal = _chartInfo['minVal'];
      _chartMaxVal = _chartInfo['maxVal'];
      _minVal = _chartInfo['minVal'] - variation;
      _maxVal = _chartInfo['maxVal'] + variation;
      print('minVal ${_chartInfo['minVal']}, maxVal ${_chartInfo['maxVal']}');
      print('INFO: variation $variation, minVal $_minVal, maxVal $_maxVal');
      return Scaffold(
        //backgroundColor: AppColors.cardDefaultColor,
        body: AppCard(
          child: Container(
            //color: AppColors.cardDefaultColor,
            child: Column(
              children: [
                //Token Details such as name and value
                tokenCard(),
                Expanded(
                  flex: 6,
                  child: Container(
                    width: double.maxFinite,
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
                          dateFormat: DateFormat.MMMd(Platform.localeName),
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
                          numberFormat: NumberFormat.simpleCurrency(decimalDigits: 3),
                          interactiveTooltip: InteractiveTooltip(
                            enable: true,
                            //canShowMarker: false
                          )
                      ),
                    ),
                  ),
                ),
                //List showing each date and value
                valueList(),
              ],
            ),
          ),
        ),
      );
    }

    //Prepare the info and load the graph with it
    return SafeArea(
      child: FutureBuilder(
        future: Future.delayed(Duration(milliseconds: 400)).then((value) => readFromDatabase(widget.tokenName,app)),
        //future: readFromDatabase(widget.tokenName,app),
        builder: (BuildContext context,snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return graph(snapshot);
          } else if (snapshot.hasError){
            NotificationBar().show(context, text: "Something went wrong");
            Navigator.pop(context);
          }
          return Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              color: AppColors.purple,
              strokeWidth: 6,
            ),
          ));
        }
      ),
    );
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

Future<Map<String,dynamic>> readFromDatabase(String tokenName, AvmeWallet appState) async {
  Map<String,dynamic> _chartInfo;
  List<ChartSampleData> _chartData = [];
  double _aux = 0, _minVal = 0, _maxVal = 0;
  bool isFirst=true;
  //String datetime = DateTime.now().millisecondsSinceEpoch.toString();
  /*
  //For adding the current date and value to the graph, currently disabled.
  //to enable, the datetime must be fixed to always show as in "the next day"
  //or the current day flat in UTC.  May break depending on UTC time of user
  if (tokenName=='AVAX')
  {
    _chartData.add(
        ChartSampleData(DateTime.fromMillisecondsSinceEpoch(int.tryParse(datetime)!,isUtc: true), _aux, double.tryParse(appState.networkToken.value)!)
    );
  } else {
    _chartData.add(
        ChartSampleData(DateTime.fromMillisecondsSinceEpoch(int.tryParse(datetime)!,isUtc: true), _aux, double.tryParse(appState.activeContracts.token.tokenValue(tokenName))!)
    );
  }
   */
  await ValueHistoryTable.instance.readAmount(tokenName, 30).then((value) =>
  {
    value.reversed.forEach((element) {
      if (isFirst)
      {
        _aux = element.value.toDouble();
        _maxVal = _minVal = _aux;
        isFirst = false;
      } else {
        _chartData.add(ChartSampleData(
            DateTime.fromMillisecondsSinceEpoch(int.tryParse(element.dateTime.toString()+'000')!,isUtc: true),
            _aux,
            element.value.toDouble()));
        _aux = element.value.toDouble();
        if (element.value.toDouble()>_maxVal) _maxVal = element.value.toDouble();
        if (element.value.toDouble()<_minVal) _minVal = element.value.toDouble();
      }
    })
  });
  if (tokenName=='AVAX')
  {
    _chartData.add(
        ChartSampleData(
            DateTime(_chartData.last.x.year,_chartData.last.x.month,_chartData.last.x.day+1),
            _aux,
            double.tryParse(appState.networkToken.value)!)
    );
  } else {
    _chartData.add(
        ChartSampleData(
            DateTime(_chartData.last.x.year,_chartData.last.x.month,_chartData.last.x.day+1)
            , _aux,
            double.tryParse(appState.activeContracts.token.tokenValue(tokenName))!)
    );
  }
  _chartData.forEach((element) => print(element));
  _chartInfo = {
    'chartData' : _chartData,
    'minVal' : _minVal,
    'maxVal' : _maxVal,
  };
  return _chartInfo;
}

