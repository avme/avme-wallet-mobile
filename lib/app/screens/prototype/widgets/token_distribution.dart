import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:pie_chart/pie_chart.dart' as PieChart;

import 'neon_button.dart';
import 'card.dart';
import 'notification_bar.dart';


class TokenDistribution extends StatefulWidget {
  // Map<String, List<dynamic>> dataPie = {
  //   "AVME": [5, AppColors.lightBlue],
  //   "AVAX": [3, Colors.redAccent],
  //   "BRL": [2, Colors.green],
  //   "EUR": [1, Colors.indigo],
  //   "USD": [0.5, Colors.purple],
  //   "SAA": [0.15, Colors.white],
  //   "DAA": [0.15, Colors.white],
  //   "KAA": [0.15, Colors.white],
  // };
  final Map<String, List<dynamic>> chartData;
  final bool shouldAnimate;
  const TokenDistribution({Key key, @required this.chartData, @required this.shouldAnimate}) : super(key: key);
  @override
  _TokenDistributionState createState() => _TokenDistributionState();
}

class _TokenDistributionState extends State<TokenDistribution> {
  bool multiline = false;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double piePad = 32;
    piePad = SizeConfig.deviceGroup == "SMALL" ? 8 : piePad;
    if(widget.chartData.length > 4)
      multiline = true;
    piePad = (piePad / widget.chartData.length) * 2;

    return AppCard(
      child: Column(
        children: [
          Text("This Account",style: TextStyle(fontSize: SizeConfig.labelSize*0.8)),
          SizedBox(
            height: SizeConfig.safeBlockVertical*1.5,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.darkBlue
            ),
            child: totalValue(widget.chartData) == 0
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(child: Text("No Data to be shown."),),
              )
              : Row(
                children: [
                  Expanded(
                      flex: SizeConfig.deviceGroup == "SMALL" ? 8 : 6,
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: piePad, top: piePad, bottom: piePad, right: SizeConfig.safeBlockHorizontal*15,
                              //left: 28, top: 28, bottom: 28, right: 64,
                              // Ratib: Right dictates the size of the ring for some reason, so I made only it dynamic and removed const
                              // the bigger the number, the smaller the radius of the circle is
                          ),
                          child: Stack(
                            children: [
                              PieChart.PieChart(
                                animationDuration: widget.shouldAnimate
                                  ? Duration(milliseconds: 800)
                                  : Duration.zero,
                                dataMap: extractValues(widget.chartData),
                                initialAngleInDegree: 270,
                                legendOptions: PieChart.LegendOptions(
                                  showLegends: false,
                                ),
                                ringStrokeWidth: 12,
                                colorList: extractColorList(widget.chartData),
                                chartType: PieChart.ChartType.ring,
                                chartRadius: 180,
                                chartValuesOptions: PieChart.ChartValuesOptions(
                                    showChartValues: false,
                                    showChartValuesInPercentage: true,
                                    showChartValuesOutside: true,
                                    chartValueBackgroundColor: AppColors.cardDefaultColor,
                                    chartValueStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12
                                    )
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  // color: Colors.red,
                                  child: buildChartPercentages(extractPercentage(widget.chartData), multiline),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                  ),
                  Expanded(
                      flex:4,
                      child: Column(
                        children: buildChartLegend(widget.chartData),
                      )
                  ),
                ],
              ),
          ),
          SizedBox(
            height: 12,
          ),
          AppNeonButton(onPressed: (){
            NotificationBar().show(
                context,
                text: "Not implemented"
            );
          }, text: "SHOW AVAILABLE TOKENS"),
        ],
      ),
    );
  }

  List<Widget> buildChartLegend(Map data)
  {
    return data.entries.map((entry) => PieChartLegend(text: entry.key, color: entry.value[1]) ).toList();
  }

  Widget buildChartPercentages(Map data, bool multiline)
  {
    List<PieChartPercentages> list = data.entries.map((entry) => PieChartPercentages(
      text: entry.value[0],
      color: entry.value[1],
      scaling: data.length,
    )).toList();

    if(!multiline)
      return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: list,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: list.sublist(0, 4),
        ),
        SizedBox(
          width: 8,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: list.sublist(4, (list.length)),
        )
      ],
    );
  }

  Map<String, double> extractValues(Map data)
  {
    return data.map((key, value) => MapEntry(key, value[0].toDouble()));
  }

  List<Color> extractColorList(Map data)
  {
    List<Color> ret = data.entries.map((entry) => Color(entry.value[1].value)).toList();
    return ret;
  }

  Map<String, List<dynamic>> extractPercentage(Map data)
  {
    double total = 0;
    data.values.forEach((list) => total += list[0]);
    return data.map((key, value) => MapEntry(key, [makePercentage(value[0].toDouble(), total.toDouble()) + "%", Color(value[1].value)]));
  }

  String makePercentage(double value, double total)
  {
    String ret = ((value / total) * 100).toStringAsFixed(1).toString();
    return ret.substring(ret.indexOf('.'), ret.length) == ".0" ? ret.substring(0,ret.indexOf('.')) : ret;
  }

  double totalValue(Map<String,List> data)
  {
    double ret = 0;
    data.values.forEach((value) => ret +=value[0]);
    return ret;
  }
}

class PieChartLegend extends StatelessWidget
{
  final String text;
  final Color color;
  final double bottomPadding;
  final double indicatorSize;

  const PieChartLegend({Key key, @required this.text, @required this.color, this.bottomPadding = 12.0, this.indicatorSize = 12.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        children:
        [
          Container(
            height: this.indicatorSize,
            width: this.indicatorSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: this.color,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right:8.0),
          ),
          Flexible(child: Text(this.text,style: TextStyle(fontSize: SizeConfig.fontSize*1.3))),
        ],
      ),
    );
  }
}

class PieChartPercentages extends StatelessWidget
{
  final String text;
  final Color color;
  final int scaling;
  const PieChartPercentages({
    Key key,
    @required this.text,
    @required this.color,
    @required this.scaling
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Text(this.text,
        style: TextStyle(
          color: this.color,
          // fontSize: SizeConfig.deviceGroup == "SMALL" ? SizeConfig.fontSize * (1 + (scaling * 0.1) + 0.05) : SizeConfig.fontSize * 1.4,
          fontSize: SizeConfig.fontSize * (1.4 - (scaling * 0.03)),
        ),
      ),
    );
  }
}

