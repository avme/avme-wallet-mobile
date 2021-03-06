import 'dart:math';

import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

import 'gradient_container.dart';

class GradientCard extends StatefulWidget {
  final String address;
  final Function onPressed;
  final Function onIconPressed;
  final Widget iconChild;
  final String balance;
  final String label;
  final DecorationTween balanceTween;

  GradientCard({
    @required this.address,
    @required this.onPressed,
    @required this.onIconPressed,
    @required this.iconChild,
    @required this.balance,
    @required this.label,
    @required this.balanceTween,
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GradientContainer(
        decorationTween: widget.balanceTween,
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0),
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
                        Text(widget.label, style: TextStyle(fontSize: SizeConfig.fontSizeLarge)),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "\$${widget.balance}",
                          style: TextStyle(
                            fontSize: SizeConfig.fontSizeLarge * 1.1,
                          ),
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.copy),
                            SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              child: Column(
                                children: [
                                  Text(
                                    "${widget.address}",
                                    style: TextStyle(fontSize: SizeConfig.fontSize),
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
                    child: Icon(
                      Icons.account_circle_outlined,
                      size: 36,
                      color: Colors.white,
                    ),
                    onPressed: widget.onIconPressed,
                  ),
                  widget.iconChild
                ],
              )
            ],
          ),
        ));
  }
}
