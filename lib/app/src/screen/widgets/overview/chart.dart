import 'dart:io';
import 'package:avme_wallet/app/src/helper/extensions.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/src/helper/size.dart';
import 'package:avme_wallet/app/src/screen/widgets/card.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart' as intl;

import '../../../controller/ui/market_info.dart';
import '../../../helper/print.dart';

class MarketChart extends StatefulWidget {
  final String name;
  final String symbol;
  final String currencyType;
  final EdgeInsets containerPadding;
  final List<ChartData> chartData;
  const MarketChart({
    Key? key,
    required this.name,
    required this.symbol,
    required this.containerPadding,
    required this.chartData,
    this.currencyType = "USD"
  }) : super(key: key);

  @override
  State<MarketChart> createState() => _MarketChartState();
}

class _MarketChartState extends State<MarketChart> {
  late double minY;
  late double maxY;

  @override
  void initState() {
    super.initState();
    minY = widget.chartData.reduce((currentChartData, nextChartData) => currentChartData.low! < nextChartData.low! ? currentChartData : nextChartData).low!;
    maxY = widget.chartData.reduce((currentChartData, nextChartData) => currentChartData.high! > nextChartData.high! ? currentChartData : nextChartData).high!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue.withOpacity(0.2),
      padding: widget.containerPadding,
      child: Column(
        children: [
          Row(
            children: [
              Text("${widget.name.capitalize()} Price Chart (${widget.symbol}/${widget.currencyType})",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: DeviceSize.fontSizeHuge * 0.90
                ),
              ),
            ],
          ),
          ///Chart
          Expanded(
            child: AppCard(
              padding: widget.containerPadding.copyWith(left: 0, right: 0),
              innerPadding: widget.containerPadding.copyWith(
                left: DeviceSize.blockSizeVertical * 0.66,
                top: DeviceSize.blockSizeVertical*2,
                bottom: DeviceSize.blockSizeVertical,
                right: DeviceSize.blockSizeVertical * 2
              ),
              child: Container(
                child: SfCartesianChart(
                  series: <CandleSeries> [
                    CandleSeries<ChartData, DateTime>(
                      dataSource: widget.chartData,
                      xValueMapper: (ChartData history, _) => history.x,
                      lowValueMapper: (ChartData history, _) => history.low,
                      highValueMapper: (ChartData history, _) => history.high,
                      openValueMapper: (ChartData history, _) => history.open,
                      closeValueMapper: (ChartData history, _) => history.close,
                    ),
                  ],
                  primaryXAxis: DateTimeAxis(
                      labelStyle: TextStyle(fontSize: DeviceSize.fontSize),
                      dateFormat: intl.DateFormat.MMMd(Platform.localeName),
                      majorGridLines: MajorGridLines(width: 1,dashArray: [1,5]),
                      interval: 5,
                      minimum: DateTime(widget.chartData.first.x!.year,widget.chartData.first.x!.month,widget.chartData.first.x!.day-1),
                      maximum: DateTime(widget.chartData.last.x!.year,widget.chartData.last.x!.month,widget.chartData.last.x!.day+1),
                      interactiveTooltip: InteractiveTooltip(
                          enable: true,
                          canShowMarker: false
                      )
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: minY * 0.95,
                    interval: 1,
                    maximum: maxY * 1.05,
                  ),
                  plotAreaBorderWidth: 0,
                  margin: EdgeInsets.all(0),
                  crosshairBehavior: CrosshairBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    shouldAlwaysShow: true,
                    lineDashArray: [5,5]
                  ),
                  zoomPanBehavior: ZoomPanBehavior(
                    zoomMode: ZoomMode.x,
                    enablePinching: true,
                    enablePanning: true,
                    maximumZoomLevel: 0.2
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
