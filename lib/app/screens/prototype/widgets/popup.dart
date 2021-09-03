import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

import 'neon_button.dart';
import 'notification_bar.dart';

class AppPopup {

  BuildContext context;

  AppPopup(this.context);

  Future<void> show({
    Widget title = const Text("App Popup Widget Title"),
    ///The widget children will be stacked inside a Column widget
    List<Widget> children,
    ///This is the default content padding
    EdgeInsets padding = const EdgeInsets.only(
      left: 32,
      right: 32,
      top: 16,
      bottom: 8
    ),
    ///This is the distance the popup has between
    ///itself and the device's dimentions
    EdgeInsets margin,
    ///Actions (buttons) the dev can provide
    ///to the popup
    List actions = const [],
    bool canClose = true,
  }) async
  {
    FocusScopeNode currentFocus = FocusScope.of(this.context);
    currentFocus.unfocus();

    if(actions.length == 0)
      AppNeonButton(
        onPressed: () => Navigator.of(this.context).pop(),
        expanded: false,
        text: "CANCEL"
      );


    List<Widget> popupActions = [];

    if(actions.length > 0)
      actions.asMap().forEach((key, widget) {
        if(key.remainder(2) == 0)
          popupActions.add(
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: widget,
              )
          );
        else
          popupActions.add(
              widget
          );
      });

    Future.delayed(Duration(milliseconds: 200), ()
    {
      showDialog(
        context: this.context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Builder(
                builder: (context) =>
                  Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        GestureDetector(
                          onTap: () => null,
                          child: !canClose
                          /// Restrained popup
                          ? WillPopScope(
                            onWillPop: () async {
                              NotificationBar().show(
                                  context,
                                  text: "You can't go back now"
                              );
                              return false;
                            },
                            child: StatefulBuilder(
                              builder: (builder, setState) {
                                return AppPopupWidget(
                                  children: children,
                                  title: title,
                                  padding: padding,
                                  actions: popupActions,
                                  canClose: canClose,
                                  margin: margin
                                );
                              }),
                          )
                          /// Normal popup
                          : StatefulBuilder(builder: (builder, setState) {
                          return AppPopupWidget(
                              children: children,
                              title: title,
                              padding: padding,
                              actions: popupActions,
                              canClose: canClose,
                              margin: margin
                          );
                        })
                ),
                      ],
                    ),
                  ),
              ),
            ),
          );
        }
      );
    });
  }
}

class AppPopupWidget extends StatefulWidget {

  final List<Widget> children;
  final Widget title;
  final EdgeInsets padding;
  final List<Widget> actions;
  final bool canClose;
  final EdgeInsets margin;
  const AppPopupWidget({
    Key key,
    @required this.title,
    @required this.children,
    this.padding,
    this.margin,
    this.actions,
    this.canClose
  }) : super(key: key);

  @override
  _AppPopupWidgetState createState() => _AppPopupWidgetState();
}

class _AppPopupWidgetState extends State<AppPopupWidget> {

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      insetPadding: widget.margin ?? Dialog().insetPadding,
      buttonPadding: const EdgeInsets.all(0),
      actionsPadding: EdgeInsets.only(
        right: widget.padding.right,
        bottom: widget.padding.top,
        top: 16
      ),
      backgroundColor: AppColors.cardDefaultColor,
      contentPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
      ),
      actions: widget.actions,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          ///Header
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///Close button
                      IconButton(
                        icon: Icon(Icons.close, color: widget.canClose ? Colors.white : Colors.transparent,),
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onPressed: () {
                          if(widget.canClose)
                            Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )
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
          ),
          FractionallySizedBox(
            widthFactor: 0.8,
            child: ScreenIndicator(
              height: 20,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Padding(
            padding: widget.padding ?? const EdgeInsets.all(32),
            child: Column(
              children: widget.children,
            ),
          ),
        ],
      )
    );
  }
}
