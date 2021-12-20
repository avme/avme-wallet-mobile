import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class PaintedChart extends StatelessWidget {

  final double width;
  final double height;
  final List<double> chartData;
  final Function onTap;

  const PaintedChart({
    @required this.width,
    @required this.height,
    this.chartData, this.onTap
  });

  @override
  Widget build(BuildContext context) {
    double highest = 0;
    double lowest = 0;
    List<double> formattedData = [];
    if(this.chartData != null) {
      this.chartData.forEach((double element) {
        if (element > highest)
          highest = element;
        if (lowest == 0)
          lowest = element;
        else if (element < lowest)
          lowest = element;
      });
      this.chartData.forEach((double element) =>
        formattedData.add(
          element / (highest * 1.15)
        )
      );
    }
    return GestureDetector(
      onTap: this.onTap ?? () => NotificationBar().show(context, text: "Not implemented"),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.violet,
            width: 1,
          )
        ),
        child: CustomPaint(
          painter: ChartPainter(
            formattedData,
          ),
        ),
      ),
    );
  }
}


class ChartPainter extends CustomPainter {
  final List<double> chartData;

  ChartPainter(this.chartData);
  @override
  void paint(Canvas canvas, Size size) {
    drawGrid(canvas, size);

    Paint paint = Paint();
    paint.color = Colors.blue;
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    paint.strokeJoin = StrokeJoin.round;

    Path line = Path();

    chartData.asMap().forEach((key, value) {
      double horizontal = (key.toDouble() * size.width) / (chartData.length - 1);
      double vertical = (value * size.height) - size.height;
      vertical = vertical.abs();
      horizontal = horizontal.abs();
      if(horizontal == double.infinity || horizontal == double.nan)
        horizontal = 0;
      if(key == 0)
        line.moveTo(horizontal, vertical);
      else
        line.lineTo(horizontal, vertical);
    });
    canvas.drawPath(line, paint);
  }
  
  void drawGrid(Canvas canvas,Size size)
  {
    Paint paint = Paint();
    paint.color = AppColors.violet;
    paint.strokeWidth = 1;

    //Rows
    double row1 = (size.height / 4) * 3;
    double row2 = (size.height / 4) * 2;
    double row3 = (size.height / 4);
    canvas.drawLine(Offset(0,row1), Offset(size.width,row1), paint);
    canvas.drawLine(Offset(0,row2), Offset(size.width,row2), paint);
    canvas.drawLine(Offset(0,row3), Offset(size.width,row3), paint);

    //Columns
    double column1 = (size.width / 4) * 3;
    double column2 = (size.width / 4) * 2;
    double column3 = (size.width / 4);
    canvas.drawLine(Offset(column1, 0), Offset(column1,size.height), paint);
    canvas.drawLine(Offset(column2, 0), Offset(column2,size.height), paint);
    canvas.drawLine(Offset(column3, 0), Offset(column3,size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
