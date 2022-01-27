import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:flutter/material.dart';

import 'neon_button.dart';
import 'card.dart';
import 'gradient_container.dart';

class OverviewAndButtons extends StatefulWidget {
  final String totalBalance;
  final String difference;
  final String address;
  final Function onPressed;
  final Function onIconPressed;
  final Function onSendPressed;
  final Function onReceivePressed;
  final Function onBuyPressed;
  final DecorationTween balanceTween;

  OverviewAndButtons({
    Key key,
    @required this.totalBalance,
    @required this.address,
    @required this.onPressed,
    @required this.onIconPressed,
    @required this.onSendPressed,
    @required this.onReceivePressed,
    @required this.onBuyPressed,
    this.difference = "+18,69%", this.balanceTween,
  }) : super(key: key);

  @override
  _OverviewAndButtonsState createState() => _OverviewAndButtonsState();
}

class _OverviewAndButtonsState extends State<OverviewAndButtons> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double cardpad = SizeConfig.safeBlockHorizontal*3.5;
    return AppCard(
      child: Column(
        children: [
          GradientContainer(
            decorationTween: widget.balanceTween,
            onPressed: (){},
            child: Padding(
              // padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal*3.5),
              padding: EdgeInsets.only(top: cardpad, left: cardpad, bottom: cardpad),
              child: Row(
                children: [
                ///Fist Column with Data.
                Flexible(
                  child: GestureDetector(
                    onTap: widget.onPressed,
                    child: Container(
                      color:Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Balance",style: TextStyle(fontSize: SizeConfig.labelSize*0.6),),
                          SizedBox(height: SizeConfig.safeBlockVertical,),
                          Text("\$${widget.totalBalance}",
                            style: TextStyle(
                              fontSize: SizeConfig.labelSize,
                            ),),
                          SizedBox(height: 4,),
                          Text("${widget.difference}",
                              style: TextStyle(
                                fontSize: SizeConfig.fontSize,
                              )),
                          SizedBox(height: 18,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Icon(Icons.copy,size: SizeConfig.labelSize,),
                              ),
                              SizedBox(width: 4,),
                              Flexible(
                                child: Column(
                                  children: [
                                    Text("${widget.address}",
                                      style: TextStyle(
                                          fontSize: SizeConfig.fontSize
                                      ),),
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
                    // Center(
                    //   child: TextButton(
                    //     child: Icon(Icons.qr_code_scanner, size: 58,color: Colors.white,),
                    //     onPressed: widget.onIconPressed,
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: widget.onIconPressed,
                      child: Container(
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.only(left: cardpad / 2,right: cardpad),
                          child: Icon(Icons.qr_code_scanner, size: 58,color: Colors.white,),
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
                width: SizeConfig.safeBlockHorizontal * 1.6,
              ),
              Expanded(
                child: AppNeonButton(
                  onPressed: widget.onReceivePressed,
                  text: "RECEIVE",
                  iconData: Icons.download_sharp,
                ),
              ),
              SizedBox(
                width: SizeConfig.safeBlockHorizontal * 1.6,
              ),
              Expanded(
                child: AppNeonButton(
                  onPressed: widget.onBuyPressed,
                  text: "BUY",
                  iconData: Icons.shopping_cart,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
