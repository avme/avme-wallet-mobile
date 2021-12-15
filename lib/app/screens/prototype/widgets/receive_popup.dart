import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/qr_display.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

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
    SizeConfig().init(context);
    return AppPopupWidget(
      padding: EdgeInsets.all(0),
      cancelable: false,
      textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500
      ),
      margin: EdgeInsets.all(SizeConfig.safeBlockHorizontal*4),
      title: widget.title,
      children: [
        Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical,horizontal: SizeConfig.safeBlockHorizontal*3),
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
                    padding: EdgeInsets.symmetric(vertical:SizeConfig.blockSizeVertical*3,horizontal: SizeConfig.safeBlockHorizontal*3),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: widget.address));
                            NotificationBar().show(context,text: "Copied to clipboard");
                          },
                          child: Row(
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
                        ),
                        SizedBox(height: SizeConfig.blockSizeVertical*3),
                        AppButton(
                          mainAxisAlignment: MainAxisAlignment.start,
                          paddingBetweenIcons: 16,
                          text: "${widget.accountTitle}",
                          onPressed: () {},
                          iconData: Icons.account_circle_outlined,
                        ),
                        //SizedBox(height: 18,),
                        SizedBox(height: SizeConfig.blockSizeVertical*2),
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