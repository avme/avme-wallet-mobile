import 'package:flutter/material.dart';

class GradientContainer extends StatefulWidget {

  final Widget child;

  ///Tween are "state" or states of the transition our explicit transition
  ///will animate.
  final DecorationTween decorationTween;
  final Function onPressed;
  const GradientContainer({@required this.child, @required this.decorationTween, @required this.onPressed});
  @override
  _GradientContainerState createState() => _GradientContainerState();
}

class _GradientContainerState extends State<GradientContainer>
    with TickerProviderStateMixin {

  // final DecorationTween decorationTween = DecorationTween(
  //   begin: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8),
  //       gradient: LinearGradient(
  //           begin: Alignment.centerLeft,
  //           end: Alignment.centerRight,
  //           colors: <Color>[
  //             AppColors.purpleVariant2,
  //             AppColors.lightBlue,
  //           ]
  //       )
  //   ),
  //   end: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8),
  //       gradient: LinearGradient(
  //           begin: Alignment.centerLeft,
  //           end: Alignment.centerRight,
  //           colors: <Color>[
  //             AppColors.lightBlue,
  //             AppColors.purpleVariant2,
  //           ]
  //       )
  //   ),
  // );

  AnimationController _controller;

  @override
  void initState()
  {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    ///Add uncomment this line to enable the transitions
    // )..repeat(reverse: true);
    );
  }

  @override
  void dispose()
  {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        child: DecoratedBoxTransition(
          position: DecorationPosition.background,
          decoration: widget.decorationTween.animate(_controller),
          child: Container(child: widget.child),
        ),
      ),
    );
  }
}