// @dart=2.12
import 'dart:async';

import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

class Discover extends StatefulWidget {

  final double verticalButtons;
  final double horizontalButtons;
  final StreamController<int> browserUtility;
  const Discover({
    required this.verticalButtons,
    required this.horizontalButtons,
    required this.browserUtility
  });

  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      // shrinkWrap: true,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: 32.0,
              right: 32.0,
              top: widget.horizontalButtons
            // top: 64,
          ),
          child: Container(
            // color: Colors.red,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: AppDarkIconButton(
                    onPressed: () {  },
                    text: Text("BUY \$AVME",style: TextStyle(color: AppColors.labelDefaultColor),),
                    icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: Icon(Icons.shopping_cart, color: AppColors.labelDefaultColor)
                    ),
                  ),
                ),
                Row(
                  children: [
                    AppDarkIconButton(
                      onPressed: () {  },
                      alignment: Alignment.centerLeft,
                      text: Text("NFTs",style: TextStyle(color: AppColors.labelDefaultColor),),
                      icon: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Icon(Icons.insert_photo_rounded, color: AppColors.labelDefaultColor)
                      ),
                    ),
                    AppDarkIconButton(
                      onPressed: () {  },
                      alignment: Alignment.centerLeft,
                      text: FittedBox(child: Text("DECENTRALIZED\nFINANCE",style: TextStyle(color: AppColors.labelDefaultColor),)),
                      icon: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: FaIcon(FontAwesomeIcons.exchangeAlt, color: AppColors.labelDefaultColor, size: 18,)
                      ),
                    ),
                  ].asMap().map((int key, Widget element) {
                    if(key == 0)
                      return MapEntry(
                          key,
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(right: widget.verticalButtons),
                              child: SizedBox(
                                width: double.infinity,
                                child: element,
                              ),
                            ),
                          )
                      );
                    return MapEntry(
                        key,
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: widget.verticalButtons),
                            child: SizedBox(
                              width: double.infinity,
                              child: element,
                            ),
                          ),
                        )
                    );
                  }).values.toList(),
                ),
                Row(
                  children: [
                    AppDarkIconButton(
                      onPressed: () {  },
                      alignment: Alignment.centerLeft,
                      text: Text("CHARTS",style: TextStyle(color: AppColors.labelDefaultColor),),
                      icon: FaIcon(FontAwesomeIcons.chartLine, color: AppColors.labelDefaultColor, size: 18,),
                    ),
                    AppDarkIconButton(
                      onPressed: () {  },
                      alignment: Alignment.centerLeft,
                      text: FittedBox(child: Text("OUR WEBSITE",style: TextStyle(color: AppColors.labelDefaultColor),)),
                      icon: FaIcon(FontAwesomeIcons.globeAmericas,  color: AppColors.labelDefaultColor, size: 18,),
                    ),
                  ].asMap().map((int key, Widget element) {
                    if(key == 0)
                      return MapEntry(
                          key,
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(right: widget.verticalButtons),
                              child: SizedBox(
                                width: double.infinity,
                                child: element,
                              ),
                            ),
                          )
                      );
                    return MapEntry(
                        key,
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: widget.verticalButtons),
                            child: SizedBox(
                              width: double.infinity,
                              child: element,
                            ),
                          ),
                        )
                    );
                  }).values.toList(),
                ),
                SizedBox(
                  width: double.infinity,
                  child: AppDarkIconButton(
                    onPressed: () {
                      NotificationBar().show(context, text: "I Don't know");
                    },
                    text: Text("HOW DOES THIS WORK?",style: TextStyle(color: AppColors.labelDefaultColor),),
                    icon: FaIcon(FontAwesomeIcons.solidQuestionCircle, color: AppColors.labelDefaultColor, size: 18,),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: AppDarkIconButton(
                    onPressed: () {
                      widget.browserUtility.add(1);
                    },
                    text: Text("Swap to Browser",style: TextStyle(color: AppColors.labelDefaultColor),),
                    icon: FaIcon(FontAwesomeIcons.solidQuestionCircle, color: AppColors.labelDefaultColor, size: 18,),
                  ),
                ),
              ].map((Widget element) =>
                  Padding(
                    child: element,
                    padding: EdgeInsets.only(bottom: widget.horizontalButtons),
                  )
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }
}