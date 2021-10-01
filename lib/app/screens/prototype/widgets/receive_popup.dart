import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/qr_display.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class ReceivePopup extends StatefulWidget {
  final String title;
  final String address;
  final String accountTitle;
  final Function onQrPressed;

  const ReceivePopup({
    Key key,
    @required this.title,
    @required this.address,
    @required this.accountTitle,
    @required this.onQrPressed,
  }) : super(key: key);

  @override
  _ReceivePopupState createState() => _ReceivePopupState();
}

class _ReceivePopupState extends State<ReceivePopup> {
  @override
  Widget build(BuildContext context) {
    print("TITLE: ${widget.accountTitle}");
    return AlertDialog(
      backgroundColor: AppColors.cardDefaultColor,
      contentPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
      ),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ///Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///Close button
                      GestureDetector(
                        child: Container(
                          color: Colors.transparent,
                          // color: Colors.red,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 10,
                                left: 16,
                                right: 16
                            ),
                            child: Icon(Icons.close),
                          ),
                        ),
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      LabelText(widget.title),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(),
                )
              ],
            ),
            ScreenIndicator(
              height: 20,
              width: MediaQuery.of(context).size.width * 1 / 1.8,
            ),
            Padding(
              padding: const EdgeInsets.all(32),
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
                    padding: const EdgeInsets.only(
                      top: 32.0,
                      left: 8,
                      right: 8,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right:12.0),
                              child: Icon(Icons.copy),
                            ),
                            Flexible(
                              child: Column(
                                children: [
                                  Text(widget.address),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 24,),
                        AppButton(
                          mainAxisAlignment: MainAxisAlignment.start,
                          paddingBetweenIcons: 16,
                          text: "widget.accountTitle",
                          onPressed: () {},
                          iconData: Icons.account_circle_outlined,
                        ),
                        SizedBox(height: 18,),
                        AppNeonButton(
                          mainAxisAlignment: MainAxisAlignment.start,
                          paddingBetweenIcons: 16,
                          text: "SHARE",
                          iconData: Icons.share,
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}