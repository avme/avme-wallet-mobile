import 'package:avme_wallet/app/model/app.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme.dart';

class TokenChart extends StatefulWidget {
  TokenChart(this.appState);
  final AvmeWallet appState;
  @override
  _TokenChartState createState() => _TokenChartState();
}

class _TokenChartState extends State<TokenChart> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  bool showAvg;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
       Card(
         elevation: 8.0,
         child: Padding(
           padding: const EdgeInsets.only(right: 18.0, left: 8.0, bottom: 12),
           child:
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Padding(
                 padding: const EdgeInsets.only(top: 12, bottom: 15),
                 child: Text("AVME Chart:",
                     style: TextStyle(
                         fontWeight: FontWeight.bold, fontSize: 16)),
               ),
               Padding(
                 padding: const EdgeInsets.all(4.0),
                 child: Row(
                   children: [
                     Expanded(
                       child: AspectRatio(
                         aspectRatio: 4/3,
                         child: LineChart(
                               // showAvg ? avgData() : mainData(),
                               mainData(),
                             ),
                           ),
                         ),
                     ]
                 ),
               )
             ],
           )
         ),
       ),
      ],
    );
  }

  LineChartData mainData() {
    const Color bgColors = Color(0xFF747474);
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: bgColors,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: bgColors,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) =>
          const TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.bold, fontSize: 16),
          getTitles: (value) => getDays(value),
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xffffffff),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) =>  getHeight(value),
          reservedSize: 28,
          margin: 8,
        ),
      ),
      borderData:
      FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 15,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 1),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  String getHeight(double value)
  {
    double highest = widget.appState.dashboard.getHighestValue()[1] * 1.15;

    switch (value.toInt()) {
      case 1:
        return (highest/3).toStringAsPrecision(2);
      case 3:
        return (highest/2).toStringAsPrecision(2);
      case 5:
        return highest.toStringAsPrecision(2);
    }
    return '';
  }

  String getDays(double value)
  {
    int lastday =  widget.appState.dashboard.getHighestDay()[0];
    int secondsday10 = 864000;
    DateTime dateTimeYesterday  = DateTime.fromMillisecondsSinceEpoch(lastday * 1000);
    // DateTime dateTime10  = DateTime.fromMillisecondsSinceEpoch((lastday - secondsday10) * 1000);
    DateTime dateTime20 = DateTime.fromMillisecondsSinceEpoch((lastday - secondsday10 * 2 ) * 1000);
    DateTime dateTime30 = DateTime.fromMillisecondsSinceEpoch((lastday - secondsday10 * 3) * 1000);

    switch (value.toInt()) {
      case 0:
        return DateFormat('MM/dd').format(dateTime30).toString();
      case 7:
        return DateFormat('MM/dd').format(dateTime20).toString();
      case 14:
        return DateFormat('MM/dd').format(dateTimeYesterday).toString();
    }
    return '';
  }
  /*
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(card["unixDate"],isUtc: false);
    DateFormat dateFormat = DateFormat('MM-dd-yyyy hh:mm:ss');
   */
}