import 'package:flutter/material.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:pie_chart/pie_chart.dart' as PieChart;

import 'neon_button.dart';
import 'card.dart';


class TokenDistribution extends StatefulWidget {
  final Map<String, List<dynamic>> dataPie = {
    "AVME": [5, AppColors.lightBlue],
    "AVAX": [3, Colors.redAccent],
    "FUT": [2, Colors.green],
    "AGO": [1, Colors.indigo],
    "STO": [0.5, Colors.purple],
    "SAA": [0.15, Colors.white],
  };
  @override
  _TokenDistributionState createState() => _TokenDistributionState();
}

class _TokenDistributionState extends State<TokenDistribution> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text("This Account"),
          SizedBox(
            height: 12,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.darkBlue
            ),
            child: Row(
              children: [
                Expanded(
                    flex:6,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 28, top: 28, bottom: 28, right: 64
                        ),
                        child: Stack(
                          children: [
                            PieChart.PieChart(
                              dataMap: extractValues(widget.dataPie),
                              initialAngleInDegree: 270,
                              legendOptions: PieChart.LegendOptions(
                                showLegends: false,
                              ),
                              ringStrokeWidth: 12,
                              colorList: extractColorList(widget.dataPie),
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: buildChartPercentages(extractPercentage(widget.dataPie)),
                                ),
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
                      children: buildChartLegend(widget.dataPie),
                    )
                ),
              ],
            ),
          ),
          SizedBox(
            height: 12,
          ),
          AppNeonButton(onPressed: (){}, text: "SHOW AVALAIBLE TOKENS"),
        ],
      ),
    );
  }

  List<Widget> buildChartLegend(Map data)
  {
    return data.entries.map((entry) => PieChartLegend(text: entry.key, color: entry.value[1]) ).toList();
  }

  List<Widget> buildChartPercentages(Map data)
  {
    return data.entries.map((entry) => PieChartPercentages(text:  entry.value[0], color: entry.value[1]) ).toList();
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
          Text(this.text),
        ],
      ),
    );
  }
}

class PieChartPercentages extends StatelessWidget
{
  final String text;
  final Color color;

  const PieChartPercentages({Key key, @required this.text, @required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Text(this.text,
        style: TextStyle(
          color: this.color,
          fontSize: 11,
        ),
      ),
    );
  }
}

