import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
/// Just a simple notification bar
///
/// The [context] and [text] arguments must not be null.
@Deprecated(
  'Use AppHint instead \n'
  'AppHint.show(String Text, AppHintPosition? AppHintPosition.BOTTOM)',
)
class NotificationBar {
  void show(BuildContext context, {Function onPressed, String text})
  {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(
            color: Colors.white
          ),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.labelDefaultColor,
          onPressed: onPressed ?? (){},
        ),
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: AppColors.cardDefaultColor,
      )
    );
  }
}
