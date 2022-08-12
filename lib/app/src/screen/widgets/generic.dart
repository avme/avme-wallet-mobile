import 'package:avme_wallet/app/src/screen/widgets/hint.dart';
import 'package:avme_wallet/app/src/screen/widgets/popup.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pie_chart/pie_chart.dart' as PieChart;
import 'package:avme_wallet/app/src/helper/size.dart';
import 'buttons.dart';
import 'card.dart';

///Generic Widgets without a specific place to put them...

class LabelText extends StatelessWidget {
  final String text;
  final double fontSize;
  LabelText(this.text, {this.fontSize = 16});
  @override
  Widget build(BuildContext context) {
    return Text(this.text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: this.fontSize
      )
    );
  }
}

class LoadingPopUp extends StatefulWidget {
  final String title;
  final String text;
  final BuildContext context;
  LoadingPopUp({required this.title, this.text = 'Sample Text', required this.context});
  @override
  LoadingPopUpState createState() => LoadingPopUpState();
}

class LoadingPopUpState extends State<LoadingPopUp> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title != null ? Text(widget.title) : null,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState)
        {
          return Text(widget.text);
        }
      ),
      actions: widget.title != null ? [
        TextButton(
          onPressed: () {
            //Pops this alertDialog
            Navigator.pop(context);
          },
          child: Text("OK")
        )
      ] : null,
    );
  }
}

class CircularLoading extends StatefulWidget {
  final String text;

  CircularLoading({this.text = "Loading."});

  @override
  _CircularLoadingState createState() => _CircularLoadingState();
}

class _CircularLoadingState extends State<CircularLoading> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 14),
            Text(widget.text),
          ],
        ),
      ),
    );
  }
}

class QrDisplay extends StatefulWidget {

  final String stringToRender;
  final double? size;
  final VoidCallback? onPressed;

  QrDisplay({
    required this.stringToRender,
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
      onTap: widget.onPressed,
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

class AppLabelText extends StatelessWidget {

  final String text;
  final TextStyle textStyle;
  final bool bold;
  final double fontSize;
  const AppLabelText(
      this.text,{
        Key? key,
        this.bold = true,
        this.textStyle = const TextStyle(
            color: AppColors.labelDefaultColor
        ), this.fontSize = 16,
      }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(this.text,
        style: this.textStyle.copyWith(
            fontWeight: this.bold == true ? FontWeight.bold : FontWeight.normal,
            fontSize: this.fontSize
        )
    );
  }
}

class ReceivePopup extends StatefulWidget {
  final String title;
  final String address;
  final String accountTitle;
  final VoidCallback onQrPressed;

  const ReceivePopup({
    Key? key,
    required this.title,
    required this.address,
    required this.accountTitle,
    required this.onQrPressed,
  }) : super(key: key);

  @override
  _ReceivePopupState createState() => _ReceivePopupState();
}

class _ReceivePopupState extends State<ReceivePopup> {
  @override
  Widget build(BuildContext context) {
    return AppPopupWidget(
      padding: EdgeInsets.all(0),
      cancelable: false,
      textStyle: TextStyle(
        fontSize: DeviceSize.fontSizeLarge*1.2,
        fontWeight: FontWeight.w500
      ),
      margin: EdgeInsets.all(DeviceSize.safeBlockHorizontal*4),
      title: widget.title,
      children: [
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: DeviceSize.safeBlockVertical,horizontal: DeviceSize.safeBlockHorizontal*3),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 1 / 1.5,
                      height: MediaQuery.of(context).size.width * 1 / 1.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: QrDisplay(
                          stringToRender: widget.address,
                          onPressed: widget.onQrPressed,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: DeviceSize.blockSizeVertical * 3,
                          horizontal: DeviceSize.safeBlockHorizontal*3
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await Clipboard.setData(ClipboardData(text: widget.address));
                              AppHint.show("Copied to clipboard");
                            },
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right:12.0),
                                  child: Icon(Icons.copy,
                                    size: DeviceSize.fontSizeHuge * 1.3,
                                  ),
                                ),
                                Flexible(
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.address,
                                        style: TextStyle(fontSize: DeviceSize.fontSizeLarge),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: DeviceSize.blockSizeVertical * 3),
                          AppButton(
                            mainAxisAlignment: MainAxisAlignment.start,
                            paddingBetweenIcons: 16,
                            text: "${widget.accountTitle}",
                            onPressed: () {},
                            iconData: Icons.account_circle_outlined,
                          ),
                          //SizedBox(height: 18,),
                          SizedBox(height: DeviceSize.blockSizeVertical * 2),
                          AppNeonButton(
                            mainAxisAlignment: MainAxisAlignment.start,
                            paddingBetweenIcons: 16,
                            text: "SHARE",
                            iconData: Icons.share,
                            onPressed: () {
                              Share.share(
                                widget.address,
                                subject: "Sharing \"${widget.accountTitle}\" address."
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )],
    );
  }
}