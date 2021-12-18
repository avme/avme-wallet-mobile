import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

import 'button.dart';
import 'notification_bar.dart';

class TokenValue extends StatefulWidget {
  final Image image;
  final String amount;
  final String marketValue;
  final String valueDifference;
  final String name;

  const TokenValue({
    Key key,
    @required this.image,
    this.amount = "0",
    this.marketValue = "0",
    this.valueDifference = "0",
    @required this.name
  }) : super(key: key);
  @override
  _TokenValueState createState() => _TokenValueState();
}

class _TokenValueState extends State<TokenValue> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: AppColors.purple,
              width: 2
          ),
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF521380),
                Color(0xFF35174F),
              ]
          )
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ///Fist Column with Data.
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      // color: Colors.red,
                      width: 38,
                      height: 38,
                      child: widget.image
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text(widget.amount + " " + widget.name,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text("\$${widget.marketValue}",
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.labelDisabledTransparent
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text("+${widget.valueDifference}%",
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.lightBlue
                    ),
                  ),
                ],
              ),
            ),
            ///This is the second column, icon only
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right:SizeConfig.safeBlockHorizontal),
                    child: AppButton(
                      onPressed: () {
                        NotificationBar().show(
                            context,
                            text: "Not implemented"
                        );
                      },
                      text: "BUY",
                      iconData: Icons.shopping_cart,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TokenTracker extends StatefulWidget {
  final Image image;
  final String amount;
  final String marketValue;
  final String name;
  final String asNetworkToken;

  const TokenTracker({
    Key key,
    @required this.image,
    @required this.amount,
    @required this.marketValue,
    @required this.asNetworkToken,
    @required this.name
  }) : super(key: key);
  @override
  _TokenTrackerState createState() => _TokenTrackerState();
}

class _TokenTrackerState extends State<TokenTracker> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: SizeConfig.screenHeight / 5
        // minHeight: SizeConfig.screenHeight / 2
      ),
      child: Container(
        margin: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: AppColors.purple,
                width: 2
            ),
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  // Color(0xFF521380),
                  Color(0xFF521380),
                  Color(0xFF35174F),
                ]
            )
        ),
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ///Fist Column with Data.
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            // color: Colors.red,
                              width: 38,
                              height: 38,
                              child: widget.image
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 2),
                          child: Text(widget.name,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8,),
                    Text(widget.amount,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text("\$${widget.marketValue}",
                      style: AppTextStyles.span
                    )]..addAll(widget.asNetworkToken.length > 0
                    ? [
                      SizedBox(height: 8,),
                      Text(widget.asNetworkToken,
                        style: AppTextStyles.span
                      ),
                    ]
                    : []
                  )
                ),
              ),
              ///Graph
              Expanded(
                flex: 3,
                child: Container(
                  height: SizeConfig.safeBlockHorizontal * 8,
                  color: Colors.purple,
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}

