import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class Circle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Color circleColor1 = AppColors().randomPrimaries();
    double circleRadius1 = size.width / 2;
    var paint1 = Paint()
      ..color = circleColor1
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), circleRadius1, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class WidgetToImage extends StatefulWidget {
  final Function(GlobalKey key) builder;

  const WidgetToImage({Key key, this.builder}) : super(key: key);
  @override
  _WidgetToImageState createState() => _WidgetToImageState();
}

class _WidgetToImageState extends State<WidgetToImage> {
  final globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: widget.builder(globalKey),
    );
  }
}