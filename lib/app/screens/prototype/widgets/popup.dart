import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

import 'button.dart';
import 'neon_button.dart';

class AppPopup {
  void show({
    @required BuildContext context,
    Text title = const Text("App Popup Widget Title"),
    List<Widget> children,
    EdgeInsets padding,
  })
  {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (builder, setState){
          return AppPopupWidget(
            children: children,
            title: title,
            padding: padding,
          );
        });
    });
  }
}

class AppPopupWidget extends StatefulWidget {

  final List<Widget> children;
  final Text title;
  final EdgeInsets padding;

  const AppPopupWidget({
    Key key,
    @required this.title,
    @required this.children,
    this.padding
  }) : super(key: key);

  @override
  _AppPopupWidgetState createState() => _AppPopupWidgetState();
}

class _AppPopupWidgetState extends State<AppPopupWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: AppColors.cardDefaultColor,
        contentPadding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)
        ),
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ///Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        ///Close button
                        GestureDetector(
                          child: Container(
                            color: Colors.transparent,
                            // color: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 10,
                                  left: 16,
                                  right: 16
                              ),
                              child: Icon(Icons.close),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        widget.title,
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  )
                ],
              ),
              ScreenIndicator(
                height: 20,
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 1 / 1.8,
              ),
              Padding(
                padding: widget.padding ?? const EdgeInsets.all(32),
                child: Column(
                  children: widget.children,
                ),
              ),
            ],
          ),
        )
    );
  }
}
