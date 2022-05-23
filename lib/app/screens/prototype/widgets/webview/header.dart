// @dart=2.12
import 'dart:math';

import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart' as sa;
class Header extends StatefulWidget {
  const Header({Key? key, required this.borderRadius}) : super(key: key);
  final BorderRadius borderRadius;
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> with sa.AnimationMixin {
  late TickerProvider ticker;
  late BubbleModel bubble;
  late AnimationController mixinController;
  final List<BubbleModel> particles = [];

  @override
  void initState() {
    int bubbles = 8;

    for(int i = 0; i < bubbles; i++)
    {
      particles.add(BubbleModel(createController()));
    }
    super.initState();
    // initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/header-bg-840-480.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ClipPath(
            clipper: BubbleClipper(particles),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.purpleVariant1,
                  AppColors.lightBlue
                ])
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset("assets/avme-header.png", height: 80,)
                  ],
                ),
              ),
              Expanded(
                flex:2,
                child: Container(),
              )
            ],
          )
        ],
      ),
    );
  }
}

class BubbleModel {
  // declare Animation variables
  late Animation<double> x;
  late Animation<double> y;
  late double size;
  final AnimationController animationController;
  bool isDone = false;

  BubbleModel(this.animationController)
  {
    animate();
  }

  void animate({bool reset = false})
  {
    Random random = Random();
    if(reset)
      this.animationController.reset();
    double startOff = 1.4 * random.nextDouble();
    Offset startPosition = Offset(0.1 + (startOff * random.nextDouble()), 1.4);
    Offset endPosition = Offset(0.1 + (startOff * random.nextDouble()), -0.4);
    Duration duration = Duration(milliseconds: 1000 + random.nextInt(3000));
    AnimationController xController = animationController..animateTo(startPosition.dx, duration: duration);
    x = Tween<double>(begin: startPosition.dx, end: endPosition.dx)
        .animate(xController)..addListener(() {
    });
    AnimationController yController = animationController..animateTo(startPosition.dy, duration: duration);
    y = Tween<double>(begin: startPosition.dy, end: endPosition.dy)
        .animate(yController)..addListener(() {
      complete(x.isCompleted, y.isCompleted, x.value, y.value);
    });

    size = 0.2 + random.nextDouble() * 0.2;

  }

  void complete(bool xComplete, bool yComplete, double x, double y)
  {
    if(xComplete == true && yComplete == true) {
      isDone = true;

      animate(reset: true);
      return;
    }
  }
}

class BubbleClipper extends CustomClipper<Path>
{
  List<BubbleModel> particles;
  BubbleClipper(this.particles);

  @override
  Path getClip(Size size) {
    Path path = Path();
    for(BubbleModel particle in particles)
    {
      final position =
        Offset(particle.x.value * size.width, particle.y.value * size.height);
      path.addOval(
        Rect.fromCircle(center: position, radius: size.width * 0.2 * particle.size)
      );
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => true;
}

// class ParticlePainter extends CustomPainter {
//   List<BubbleModel> particles;
//   ParticlePainter(this.particles);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.blue;
//     particles.forEach((particle) {
//       final position =
//         Offset(particle.x.value * size.width, particle.y.value * size.height);
//       canvas.drawCircle(position, size.width * 0.2 * particle.size, paint);
//     });
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }

