import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/receive.dart';
import 'package:avme_wallet/app/screens/send.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
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

  final DecorationTween balanceTween = DecorationTween(
      begin: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                AppColors.purpleVariant2,
                AppColors.lightBlue,
              ]
          )
      ),
      end: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                AppColors.lightBlue,
                AppColors.purpleVariant2,
              ]
          )
      )
  );

  OverviewAndButtons({
    Key key,
    @required this.totalBalance,
    @required this.address,
    @required this.onPressed,
    @required this.onIconPressed,
    @required this.onSendPressed,
    @required this.onReceivePressed,
    @required this.onBuyPressed,
    this.difference = "+18,69%",
  }) : super(key: key);

  @override
  _OverviewAndButtonsState createState() => _OverviewAndButtonsState();
}

class _OverviewAndButtonsState extends State<OverviewAndButtons> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          GradientContainer(
              decorationTween: widget.balanceTween,
              onPressed: (){},
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                              Text("Total Balance"),
                              SizedBox(height: 8,),
                              Text("\$${widget.totalBalance}",
                                style: TextStyle(
                                  fontSize: 26,
                                ),),
                              SizedBox(height: 8,),
                              Text("${widget.difference}",
                                  style: TextStyle(
                                    fontSize: 12,
                                  )),
                              SizedBox(height: 18,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Icon(Icons.copy),
                                  ),
                                  SizedBox(width: 8,),
                                  Flexible(
                                    child: Column(
                                      children: [
                                        Text("${widget.address}",
                                          style: TextStyle(
                                              fontSize: 12
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
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left:8.0),
                          child: TextButton(
                            child: Icon(Icons.qr_code_scanner, size: 64,color: Colors.white,),
                            onPressed: widget.onIconPressed,
                          ),
                        ),
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
                width: 8,
              ),
              Expanded(
                child: AppNeonButton(
                  onPressed: widget.onReceivePressed,
                  text: "RECEIVE",
                  iconData: Icons.download_sharp,
                ),
              ),
              SizedBox(
                width: 8,
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
