// @dart=2.12
import 'package:avme_wallet/app/controller/database/value_history.dart';
import 'package:avme_wallet/app/model/app.dart';
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
    return FutureBuilder(
      future: readFromDatabase(widget.tokenName,app),
      builder: (context,snapshot){
        if(snapshot.data!=null){
          final List<ChartSampleData> chartData = snapshot.data as List<ChartSampleData>;
          print('chartData $chartData');
          return SafeArea(
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.maxFinite,
                      child: SfCartesianChart(
                        crosshairBehavior: _crosshairBehavior,
                        borderColor: Colors.red,
                        borderWidth: 5,
                        //plotAreaBorderColor: Colors.green,
                        plotAreaBackgroundColor: Colors.lightBlueAccent,
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
                            dataSource: chartData,
                            xValueMapper: (ChartSampleData sales, _) => sales.x,
                            lowValueMapper: (ChartSampleData sales, _) => sales.low,
                            highValueMapper: (ChartSampleData sales, _) => sales.high,
                            closeValueMapper: (ChartSampleData sales, _) => sales.close,
                            openValueMapper: (ChartSampleData sales, _) => sales.open,
                            pointColorMapper: (ChartSampleData sales, _) => sales.segmentColor,
                          )
                        ],
                        primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat.MMMd('pt'),
                            majorGridLines: MajorGridLines(width: 1,dashArray: [1,5]),
                            //minimum: DateTime(2015, 12, 31),
                            //maximum: DateTime(2016, 01, 29),
                            //rangePadding: ChartRangePadding.additional,
                            interactiveTooltip: InteractiveTooltip(
                                enable: true,
                                canShowMarker: false
                            )
                        ),
                        primaryYAxis: NumericAxis(
                          //name: 'money',
                            //minimum: 70,
                            //maximum: 130,
                            interval: 10,
                            numberFormat: NumberFormat.simpleCurrency(decimalDigits: 5),
                            interactiveTooltip: InteractiveTooltip(
                                enable: true,
                                canShowMarker: false
                            )
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.maxFinite,
                      color: Colors.lightGreenAccent[100],
                      child: Column(
                        children: [
                          Expanded(flex: 1,
                            child: Container(
                                child: Text('TESTE TEMPORARIO WOOOOW'),
                            )
                          ),
                        ],
                      )
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return Center(child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            color: AppColors.purple,
            strokeWidth: 6,
          ),
        ));
      }
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
      this.segmentColor = (close >= open) ? Colors.red : Colors.green;

  @override
  String toString() {
    return 'ChartSampleData{x: $x, open: $open, close: $close}';
  }
}

Future<List<ChartSampleData>> readFromDatabase(String tokenName, AvmeWallet appState) async {
  List<ChartSampleData> _chartData = [];
  String datetime = DateTime.now().millisecondsSinceEpoch.toString();
  double _aux = 0;
  bool isFirst=true;
  await ValueHistoryTable.instance.readAmount(tokenName, 30).then((value) =>
  {
    value.forEach((element) {
      if (isFirst)
      {
        _aux = element.value.toDouble();
        isFirst = false;
      } else {
        _chartData.add(ChartSampleData(
            DateTime.fromMillisecondsSinceEpoch(int.tryParse(element.dateTime.toString()+'000')!),
            _aux,
            element.value.toDouble()));
        _aux = element.value.toDouble();
      }
    })
  });
  if (tokenName=='AVAX')
  {
    _chartData.add(
        ChartSampleData(DateTime.fromMillisecondsSinceEpoch(int.tryParse(datetime)!), _aux, double.tryParse(appState.networkToken.value)!)
    );
  } else {
    _chartData.add(
        ChartSampleData(DateTime.fromMillisecondsSinceEpoch(int.tryParse(datetime)!), _aux, double.tryParse(appState.activeContracts.token.tokenValue(tokenName))!)
    );
  }
  return _chartData;
}