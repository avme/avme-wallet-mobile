import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDisplay extends StatefulWidget {

  final String stringToRender;
  final double size;
  final Function onPressed;

  QrDisplay({
    @required this.stringToRender,
    this.onPressed,
    this.size
  });

  @override
  _QrDisplayState createState() => _QrDisplayState();
}

class _QrDisplayState extends State<QrDisplay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:widget.onPressed,
      child: QrImage(
        backgroundColor: Colors.white,
        data: widget.stringToRender,
        version: QrVersions.auto,
        size: widget.size ?? getQrSize(context),
      ),
    );
  }

  double getQrSize(BuildContext context)
  {
    double qrSize = MediaQuery.of(context).size.width <= 200 ?
    MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.6;
    return qrSize;
  }
}