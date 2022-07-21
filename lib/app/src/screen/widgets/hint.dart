import 'package:avme_wallet/app/src/screen/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

import '../../controller/routes.dart';

enum AppHintPosition {
  TOP,
  BOTTOM
}

class AppHint {
  static void show(
    String text,
    {
      VoidCallback? onPressed,
      AppHintPosition position = AppHintPosition.BOTTOM,
      Duration duration = const Duration(seconds: 4)
    })
  {
    BuildContext? context = Routes.globalContext.currentContext;

    if(context == null)
      throw "AppHint.show failed to recover the current context";

    Widget content = Text(
      text,
      style: TextStyle(
          color: Colors.white
      ),
    );

    Color backgroundColor = AppColors.cardDefaultColor;

    if(position == AppHintPosition.BOTTOM)
    {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: duration,
            content: content,
            action: SnackBarAction(
              label: 'OK',
              textColor: AppColors.labelDefaultColor,
              onPressed: onPressed ?? (){},
            ),
            // elevation: 8,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: backgroundColor,
          )
      );
    }
    else
    {
      late Flushbar flush;
      double horizontalMargin = 15;
      double topMargin = 10;
      double bottomMargin = 5;
      flush = Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        messageText: content,
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        backgroundColor: backgroundColor,
        boxShadows: [BoxShadow(color: Colors.black26, offset: Offset(0.0, 1.0), blurRadius: 5.0)],
        duration: duration,
        mainButton: TextButton(
          child: Text('OK'),
          // textColor: AppColors.labelDefaultColor,
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color?>((set) => AppColors.labelDefaultColor),
          ),
          onPressed: onPressed ?? (){
            flush.dismiss();
          },
        ),
        borderRadius: BorderRadius.circular(8),
        // padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(
            left: horizontalMargin,
            top: topMargin,
            right: horizontalMargin,
            bottom: bottomMargin
        ),
      )..show(context);
    }
  }
}