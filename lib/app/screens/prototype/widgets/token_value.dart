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
                    padding: const EdgeInsets.only(right:8.0),
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
