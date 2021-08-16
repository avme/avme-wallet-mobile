import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

class Overview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppCard(
          child: Column(
            children: [
              GradientContainer(
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
                            Text("+ 18,69%",
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
        ),
      ],
    );
  }
}

class GradientContainer extends StatefulWidget {
  final Widget child;

  const GradientContainer({@required this.child});
  @override
  _GradientContainerState createState() => _GradientContainerState();
}

class _GradientContainerState extends State<GradientContainer>
    with TickerProviderStateMixin {
  ///Tween are "state" or states of the transition our explicit transition
  ///will animate.
  final DecorationTween decorationTween = DecorationTween(
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
    ),
  );

  AnimationController _controller;

  @override
  void initState()
  {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
  }

  @override
  void dispose()
  {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DecoratedBoxTransition(
        position: DecorationPosition.background,
        decoration: decorationTween.animate(_controller),
        child: Container(child: widget.child),
      ),
    );
  }
}
