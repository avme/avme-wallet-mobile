import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class ScreenIndicator extends StatelessWidget {
  final double height;
  final double width;

  const ScreenIndicator({@required this.height, @required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.width,
      height: this.height,
      // color: Colors.black,
      child: CustomPaint(
        painter: Indicator(),
      ),
    );
  }
}

class Indicator extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    Paint mainPainter = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 2;

    Paint secondaryPainter = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 4;

    canvas.drawLine(Offset(0, 8), Offset(size.width, 8), mainPainter);

    canvas.drawLine(
      Offset(size.width * 1.1 / 4, 10),
      Offset(size.width * 2.9 / 4, 10),
      secondaryPainter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}