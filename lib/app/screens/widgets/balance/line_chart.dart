import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../custom_widgets.dart';
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
  List<FlSpot> chartSpots;
  Map<dynamic, dynamic> daysAndPrice;
  @override
  Widget build(BuildContext context) {
    daysAndPrice = organizeValue();
    chartSpots = getChartPoints();

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
                 padding: const EdgeInsets.only(top: 12,),
                 child: LabelText("Market Data:"),
               ),
               Padding(
                 padding: const EdgeInsets.all(4.0),
                 child: Row(
                   children: [
                     Expanded(
                       child: AspectRatio(
                         aspectRatio: 4/3,
                         child: Padding(
                           padding: const EdgeInsets.only(right:18.0,left: 8),
                           child: Stack(
                             children:
                             [
                               LineChart(
                                 lines(),
                               ),
                               LineChart(
                                 mainData(),
                               ),
                             ]
                           ),
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

  LineChartData lines() {
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
          getTextStyles: (value) =>
          const TextStyle(color: Colors.transparent, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Colors.transparent,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) =>  getHeight(value),
          reservedSize: 28,
          // margin: 8,
        ),
        topTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value) => const TextStyle(
              color:  Colors.transparent,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            getTitles: (value) {
              if(value == 7) return "Historical AVME Prices";
              return null;
            }
        ),
      ),
      borderData:
      FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 15,
      minY: 0,
      maxY: 4,
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          barWidth: 5,
          dotData: FlDotData(
            show: false,
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
          const TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.bold, fontSize: 14),
          getTitles: (value) => getDays(value),
          // margin: 8,
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
          // margin: 8,
        ),
        topTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value) => const TextStyle(
              color:  Color(0xffffffff),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            getTitles: (value) {
              if(value == 7) return "Historical AVME Prices";
              return null;
            }
        ),
      ),
      borderData:
      FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 15,
      minY: 0,
      maxY: 2,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (value)
            {
              return value.map((e) => LineTooltipItem(
                  "${e.y} USD\n${daysAndPrice[e.x][1]}",
                  const TextStyle(color: Color(0xff23b6e6), fontWeight: FontWeight.bold, fontSize: 16),
                )
              ).toList();
            }
        )
      ),
      lineBarsData: [
        LineChartBarData(
          spots: getChartPoints(),

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
      case 0:
        return "0.0\n\n";

      case 1:
        return (highest/2).toStringAsPrecision(2);

      case 2:
        return highest.toStringAsPrecision(2);
    }
    return '';
  }

  String getDays(double value)
  {
    int lastday =  widget.appState.dashboard.getHighestDay()[0];
    int secondsday10 = 864000;
    // DateTime dateTimeYesterday  = DateTime.fromMillisecondsSinceEpoch(lastday * 1000);
    DateTime today  = DateTime.fromMillisecondsSinceEpoch((lastday + 86400) * 1000);
    // DateTime dateTime10  = DateTime.fromMillisecondsSinceEpoch((lastday - secondsday10) * 1000);
    DateTime dateTime20 = DateTime.fromMillisecondsSinceEpoch((lastday - secondsday10 * 2) * 1000);
    DateTime dateTime30 = DateTime.fromMillisecondsSinceEpoch(((lastday + 86400) - secondsday10 * 3) * 1000);

    switch (value.toInt()) {
      case 0:
        return DateFormat('MM/dd').format(dateTime30).toString();
      case 7:
        return DateFormat('MM/dd').format(dateTime20).toString();
      case 14:
        return DateFormat('MM/dd').format(today).toString();
    }
    return '';
  }

  Map<dynamic, dynamic> organizeValue()
  {
    int totalDays = widget.appState.dashboard.tokenList.length + 1;
    int _totalDays = totalDays;
    Map ret = widget.appState.dashboard.tokenList.map((key, value) {
      if(totalDays == _totalDays)
      {
        totalDays--;
        double key = (_totalDays - 1)/2;
        return MapEntry(key, [_totalDays+1, DateFormat('MM/dd').format(DateTime.now()).toString(), double.parse(double.parse(widget.appState.activeContracts.token.tokenValues["AVME"]).toStringAsPrecision(3))]);
      }
      else
      {
        totalDays--;
        DateTime day = DateTime.fromMillisecondsSinceEpoch((key) * 1000);
        return MapEntry(((totalDays-1)/2).toDouble(),[totalDays, DateFormat('MM/dd').format(day).toString(), double.parse(double.parse(value).toStringAsPrecision(3))]);
      }
    });
    return ret;
  }

  List<FlSpot> getChartPoints()
  {
    /// FLSpot (dia,valor) FlSpot(0, 1)
    List<FlSpot> valueSpots = [];
    daysAndPrice.forEach((key, value) {
      valueSpots.add(FlSpot(key,value[2]));
    });

    return valueSpots;
  }
  // List<FlSpot> getChartPoints()
  // {
  //   /// FLSpot (dia,valor) FlSpot(0, 1)
  //   int order = 0;
  //   int totalDays = widget.appState.dashboard.tokenList.length + 1;
  //   List<FlSpot> valueSpots = [];
  //   widget.appState.dashboard.tokenList.forEach((key, value) {
  //     order++;
  //     totalDays--;
  //     DateTime day = DateTime.fromMillisecondsSinceEpoch((key + 86400) * 1000);
  //     valueSpots.add(FlSpot(((totalDays-1) / 2).toDouble(),double.parse(double.parse(value).toStringAsPrecision(3))));
  //     return MapEntry(order,{key: [totalDays, DateFormat('MM/dd').format(day).toString(), double.parse(value).toStringAsPrecision(3)]});
  //   });
  //   return valueSpots;
  // }
}