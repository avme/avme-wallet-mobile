import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class ScreenIndicator extends StatelessWidget {
  final double height;
  final double width;
  final int position;

  const ScreenIndicator({@required this.height, @required this.width, this.position = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.width,
      height: this.height,
      // color: Colors.black,
      child: CustomPaint(
        painter: Indicator(this.position),
      ),
    );
  }
}

class Indicator extends CustomPainter {
  final int position;

  Indicator(this.position);
  @override
  void paint(Canvas canvas, Size size) {
    Paint mainPainter = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 2;

    Paint secondaryPainter = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 4;

    canvas.drawLine(Offset(0, 8), Offset(size.width, 8), mainPainter);

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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}