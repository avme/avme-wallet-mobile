import 'package:flutter/material.dart';
import 'package:avme_wallet/app/src/helper/size.dart';
import 'package:avme_wallet/app/src/screen/widgets/widgets.dart';

class OverviewAndButtons extends StatefulWidget {
  final String totalBalance;
  final String address;
  final Widget difference;
  final VoidCallback onPressed;
  final VoidCallback onIconPressed;
  final VoidCallback onSendPressed;
  final VoidCallback onReceivePressed;
  final VoidCallback onBuyPressed;
  final DecorationTween balanceTween;

  OverviewAndButtons({
    Key? key,
    required this.totalBalance,
    required this.address,
    required this.difference,
    required this.onPressed,
    required this.onIconPressed,
    required this.onSendPressed,
    required this.onReceivePressed,
    required this.onBuyPressed,
    required this.balanceTween,
  }) : super(key: key);

  @override
  _OverviewAndButtonsState createState() => _OverviewAndButtonsState();
}

class _OverviewAndButtonsState extends State<OverviewAndButtons> {

  @override
  Widget build(BuildContext context) {
    double cardpad = DeviceSize.safeBlockHorizontal * 3.5;
    return AppCard(
      child: Column(
        children: [
          GradientContainer(
            decorationTween: widget.balanceTween,
            onPressed: () {},
            child: Padding(
              padding: EdgeInsets.only(top: cardpad, left: cardpad, bottom: cardpad),
              child: Row(
                children: [
                  ///Fist Column with Data.
                  Flexible(
                    child: GestureDetector(
                      onTap: widget.onPressed,
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Balance",
                              style: TextStyle(fontSize: DeviceSize.labelSize * 0.6),
                            ),
                            SizedBox(
                              height: DeviceSize.safeBlockVertical,
                            ),
                            Text(
                              "\$${widget.totalBalance}",
                              style: TextStyle(
                                fontSize: DeviceSize.labelSize,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            widget.difference,
                            SizedBox(
                              height: 18,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Icon(
                                    Icons.copy,
                                    size: DeviceSize.labelSize,
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Flexible(
                                  child: Column(
                                    children: [
                                      Text(
                                        "${widget.address}",
                                        style: TextStyle(fontSize: DeviceSize.fontSize),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  ///This is the second column, icon only
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: widget.onIconPressed,
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: EdgeInsets.only(left: cardpad / 2, right: cardpad),
                            child: Icon(
                              Icons.qr_code_scanner,
                              size: 58,
                              color: Colors.white,
                            ),
                          )
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppNeonButton(
                  onPressed: widget.onSendPressed,
                  text: "SEND",
                  iconData: Icons.upload_sharp,
                ),
              ),
              SizedBox(
                width: DeviceSize.safeBlockHorizontal * 1.6,
              ),
              Expanded(
                child: AppNeonButton(
                  onPressed: widget.onReceivePressed,
                  text: "RECEIVE",
                  iconData: Icons.download_sharp,
                ),
              ),

              ///Uncomment this to display the "buy" button referenced
              ///inside the design
              // SizedBox(
              //   width: DeviceSize.safeBlockHorizontal * 1.6,
              // ),
              // Expanded(
              //   child: AppNeonButton(
              //     onPressed: widget.onBuyPressed,
              //     text: "BUY",
              //     iconData: Icons.shopping_cart,
              //   ),
              // ),
            ],
          )
        ],
      ),
    );
  }
}