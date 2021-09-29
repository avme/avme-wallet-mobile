import 'dart:math';

import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

import 'gradient_container.dart';

class GradientCard extends StatefulWidget {

  final String address;
  final Function onPressed;
  final Function onIconPressed;
  final String balance;
  final String label;
  final AppColors appColors;

  GradientCard(
  {
    @required this.address,
    @required this.onPressed,
    @required this.onIconPressed,
    @required this.balance,
    @required this.label,
    @required this.appColors,
    Key key,
  }) : super(key: key);

  // final DecorationTween balanceTween = DecorationTween(
  //   begin: BoxDecoration(
  //     borderRadius: BorderRadius.circular(8),
  //     gradient: LinearGradient(
  //       begin: Alignment.centerLeft,
  //       end: Alignment.centerRight,
  //       colors: <Color>[
  //         AppColors.purpleVariant2,
  //         AppColors.lightBlue,
  //       ]
  //     )
  //   ),
  //   end: BoxDecoration(
  //     borderRadius: BorderRadius.circular(8),
  //     gradient: LinearGradient(
  //       begin: Alignment.centerLeft,
  //       end: Alignment.centerRight,
  //       colors: <Color>[
  //         AppColors.lightBlue,
  //         AppColors.purpleVariant2,
  //       ]
  //     )
  //   )
  // );


  @override
  _GradientCardState createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard> {

  @override
  Widget build(BuildContext context) {

    Color startColorLeft = widget.appColors.randomColor();
    Color startColorRight = widget.appColors.randomColor(ignore:true);
    Color endColorLeft = widget.appColors.randomColor(ignore: true);
    Color endColorRight = widget.appColors.randomColor(ignore: true);

    DecorationTween balanceTween = DecorationTween(
        begin: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  startColorLeft,
                  startColorRight,
                ]
            )
        ),
        end: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  endColorLeft,
                  endColorRight,
                ]
            )
        )
    );

    return GradientContainer(
        decorationTween: balanceTween,
        onPressed: (){},
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            bottom: 16.0,
            left: 16.0
          ),
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
                        Text(widget.label),
                        SizedBox(height: 8,),
                        Text("\$${widget.balance}",
                          style: TextStyle(
                            fontSize: 18,
                          ),),
                        SizedBox(height: 18,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.copy),
                            SizedBox(width: 8,),
                            Flexible(
                              child: Column(
                                children: [
                                  Text("${widget.address}",
                                    style: TextStyle(
                                      fontSize: 12
                                    ),
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
                children: [
                  TextButton(
                    child: Icon(Icons.account_circle_outlined, size: 36,color: Colors.white,),
                    onPressed: widget.onIconPressed,
                  ),
                ],
              )
            ],
          ),
        )
    );
  }
}
