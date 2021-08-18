import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

import 'neon_button.dart';
import 'card.dart';
import 'gradient_container.dart';

class OverviewAndButtons extends StatefulWidget {

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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ///Fist Column with Data.
                    Flexible(
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Balance"),
                          SizedBox(height: 8,),
                          Text("\$109 252,35645",
                            style: TextStyle(
                              fontSize: 26,
                            ),),
                          SizedBox(height: 8,),
                          Text("+18,69%",
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
                                    Text("0x4214496147525148769976fb554a8388117e25b1",
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
                    ///This is the second column, icon only
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left:8.0),
                          child: Icon(Icons.qr_code_scanner, size: 64,),
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
                  onPressed: (){},
                  text: "SEND",
                  iconData: Icons.upload_sharp,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: AppNeonButton(
                  onPressed: (){},
                  text: "RECEIVE",
                  iconData: Icons.download_sharp,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: AppNeonButton(
                  onPressed: (){},
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
