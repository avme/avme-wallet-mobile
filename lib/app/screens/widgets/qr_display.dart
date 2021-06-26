import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
class QrDisplay extends StatelessWidget {

  QrDisplay({this.stringToRender, this.size});

  final String stringToRender;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:() => _copyToClipboard(context),
      child: QrImage(
        backgroundColor: Colors.white,
        data: this.stringToRender,
        version: QrVersions.auto,
        size: size ?? getQrSize(context),
      ),
    );
  }

  double getQrSize(BuildContext context)
  {
    double qrSize = MediaQuery.of(context).size.width <= 200 ?
    MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.6;
    return qrSize;
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: this.stringToRender));
    snack("Address copied to clipboard",context);
  }
}
