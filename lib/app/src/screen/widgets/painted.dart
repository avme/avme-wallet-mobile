import 'package:avme_wallet/app/src/screen/widgets/hint.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';
import 'package:flutter/material.dart';

class ScreenIndicator extends StatelessWidget {
  final double height;
  final double width;
  final int position;
  final bool equal;
  const ScreenIndicator({
    required this.height,
    required this.width,
    this.position = 1,
    this.equal = false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.width,
      height: this.height,
      child: CustomPaint(
        painter: Indicator(this.position, this.equal),
      ),
    );
  }
}

class Indicator extends CustomPainter {
  final int position;
  final bool equal;

  Indicator(this.position, this.equal);
  @override
  void paint(Canvas canvas, Size size) {
    Paint mainPainter = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 2;

    Paint secondaryPainter = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 4;

    canvas.drawLine(Offset(0, 8), Offset(size.width, 8), mainPainter);

    if(!this.equal)
    {
      if(this.position == 0)
      {
        canvas.drawLine(
          Offset(0, 10),
          Offset(size.width * 1.1 / 4, 10),
          secondaryPainter
        );
      }

      if(this.position == 1)
      {
        canvas.drawLine(
          Offset(size.width * 1.1 / 4, 10),
          Offset(size.width * 2.9 / 4, 10),
          secondaryPainter
        );
      }

      if(this.position == 2)
      {
        canvas.drawLine(
          Offset(size.width * 2.9 / 4, 10),
          Offset(size.width, 10),
          secondaryPainter
        );
      }
    }
    else
    {
      if(this.position == 0)
      {
        canvas.drawLine(
          Offset(0, 10),
          Offset(size.width / 3, 10),
          secondaryPainter
        );
      }

      if(this.position == 1)
      {
        canvas.drawLine(
          Offset(size.width / 3, 10),
          Offset(size.width * 2 / 3, 10),
          secondaryPainter
        );
      }

      if(this.position == 2)
      {
        canvas.drawLine(
          Offset(size.width * 2 / 3, 10),
          Offset(size.width, 10),
          secondaryPainter
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class PaintedChart extends StatelessWidget {

  final double width;
  final double height;
  final String name;
  final List<double>? chartData;
  // final VoidCallback onTap;

  const PaintedChart({
    required this.width,
    required this.height,
    required this.name,
    this.chartData,
    // required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    double highest = 0;
    double lowest = 0;
    List<double> formattedData = [];
    if(this.chartData != null) {
      this.chartData!.forEach((double element) {
        if (element > highest) {
          highest = element;
        }
        if (lowest == 0) {
          lowest = element;
        }
        else if (element < lowest) {
          lowest = element;
        }
      });
      this.chartData!.forEach((double element) =>
        formattedData.add(
          // element / (highest * 1.15)
          element / (highest * 1.25)
        )
      );
    }
    return GestureDetector(
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