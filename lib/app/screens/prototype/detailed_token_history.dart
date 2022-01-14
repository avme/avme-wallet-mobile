// @dart=2.12
import 'dart:io';

import 'package:avme_wallet/app/controller/database/value_history.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
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
  BoxDecoration _boxDecoration = BoxDecoration(
    /*
    gradient: LinearGradient(
        begin: Alignment.centerLeft, 
        end: Alignment.bottomRight, 
        colors: <Color>[ 
          Color(0xFF521380),
          Color(0xFF35174F),
        ]
    ),
     */
    //color: Color(0xFF521380),
    //border: Border.all(color: AppColors.purple, width: 3.0),
    //border: Border.all(color: AppColors.cardDefaultColor, width: 3.0),
    color: AppColors.cardDefaultColor,
    //borderRadius: BorderRadius.circular(10),
  );

  @override
  void initState() {

    initializeDateFormatting();
    _crosshairBehavior = CrosshairBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        shouldAlwaysShow: true
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AvmeWallet app = Provider.of<AvmeWallet>(context, listen:false);
    List<String> availableTokens = ["AVAX"];
    availableTokens.addAll(app.currentAccount.tokensBalanceList.keys);
    print('availableTokens: $availableTokens');
    //TODO: Add a list with all avaliable tokens, user can tap a token and switch graph
    /*
    For the list to work, best thing to do is to change most of the code so it
    will load based on the current variable and not a set parameter like it currently is.
    Maybe add a new method in the database interface so it loads absolutely everything
    and do a manual filter when loading info here based off the current token name given?
    List can be just a setState that changes the name variable
     */

    valueList(){

      List<Widget> rows = [];

      availableTokens.forEach((tokenName) {
        if (tokenName == 'AVAX')
        {
          rows.add(
            Container(
                margin: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right:SizeConfig.safeBlockVertical * 1.5),
                      child: resolveImage('assets/avax_logo.png', width: SizeConfig.safeBlockVertical * 3.5),
                    ),
                    Text(tokenName, style: AppTextStyles.label,),
                  ],
                ),
              ),
          );
        }
        if(tokenName != availableTokens.first)
        {
          rows.add(
              Container(
                margin: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right:SizeConfig.safeBlockVertical * 1.5),
                      child: resolveImage(app.activeContracts.sContracts.contractsRaw[tokenName]!["logo"], width: SizeConfig.safeBlockVertical * 3.5),
                    ),
                    Text("$tokenName (${app.activeContracts.sContracts
                        .contractsRaw[tokenName]!["symbol"]})", style: AppTextStyles.label,),
                  ],
                ),
              ),
          );
        }
      });
      rows.add(
        Container(
          margin: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right:SizeConfig.safeBlockVertical * 1.5),
                child: resolveImage('assets/avax_logo.png', width: SizeConfig.safeBlockVertical * 3.5),
              ),
              Text("change this to a list of date - value", style: AppTextStyles.label,),
            ],
          ),
        ),
      );
      print('rows: $rows');

      return Expanded(
        flex: 1,
        child: Container(
          color: AppColors.darkBlue,
          margin: EdgeInsets.only(
            left: SizeConfig.safeBlockHorizontal*4,
            right: SizeConfig.safeBlockHorizontal*4,
          ),
          padding: EdgeInsets.only(
            left: SizeConfig.safeBlockHorizontal*4,
            right: SizeConfig.safeBlockHorizontal*4,
          ),
          child: ListView(
            children: rows,
          ),
        ),
      );
    }

    graph(AsyncSnapshot snapshot){
      final Map<String,dynamic> _chartInfo = snapshot.data as Map<String,dynamic>;
      final List<ChartSampleData> _chartData = _chartInfo['chartData'];
      final variation = ((_chartInfo['maxVal'] - _chartInfo['minVal'])/0.8)/8;
      final minVal = _chartInfo['minVal'] - variation;
      final maxVal = _chartInfo['maxVal'] + variation;
      print('minVal ${_chartInfo['minVal']}, maxVal ${_chartInfo['maxVal']}');
      print('INFO: variation $variation, minVal $minVal, maxVal $maxVal');
      return Scaffold(
        //backgroundColor: AppColors.cardDefaultColor,
        body: AppCard(
          child: Container(
            //color: AppColors.cardDefaultColor,
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal*2,top: SizeConfig.safeBlockVertical),
                    //margin: EdgeInsets.only(top: SizeConfig.safeBlockVertical),
                    child: SfCartesianChart(
                      crosshairBehavior: _crosshairBehavior,
                      //borderColor: AppColors.purple,
                      borderWidth: 2,
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
                          minimum: minVal,
                          maximum: maxVal,
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

                Expanded(
                  flex: 1,
                  child: Container(
                      width: double.maxFinite,
                      //color: Colors.lightGreenAccent[100],
                      child: Row(
                        children: [
                          Expanded(flex: 1,
                              child: Container(
                                padding: EdgeInsets.all(SizeConfig.safeBlockVertical*4),
                                child: Image.asset(
                                    'assets/avax_logo.png',
                                    fit: BoxFit.contain),
                              )
                          ),
                          Expanded(flex: 1,
                              child: Container(
                                padding: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal*2),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('still under progress', style: TextStyle(fontSize: SizeConfig.fontSize*2)),
                                    Text('23.412778', style: TextStyle(fontSize: SizeConfig.fontSize*2)),
                                    Text('\$1861.64646',style: AppTextStyles.span.copyWith(fontSize: SizeConfig.fontSize*2)),
                                  ],
                                ),
                              )
                          ),
                        ],
                      )
                  ),
                ),
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
        future: readFromDatabase(widget.tokenName,app),
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

