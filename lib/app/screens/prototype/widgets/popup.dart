import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

import 'notification_bar.dart';

class AppPopup {
  void show({
    @required BuildContext context,
    Widget title = const Text("App Popup Widget Title"),
    List<Widget> children,
    EdgeInsets padding,
    actions = const [],
    canClose = true,
  })
  {
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

    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Scaffold (
            backgroundColor: Colors.transparent,
            body: Builder(
              builder: (context) => GestureDetector(
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
                    child: StatefulBuilder(builder: (builder, setState) {
                      return AppPopupWidget(
                          children: children,
                          title: title,
                          padding: padding,
                          actions: actions,
                          canClose: canClose
                      );
                    }),
                  )
                    /// Normal popup
                    : StatefulBuilder(builder: (builder, setState) {
                  return AppPopupWidget(
                      children: children,
                      title: title,
                      padding: padding,
                      actions: actions,
                      canClose: canClose
                  );
                })
              ),
            ),
          ),
        );
      }


    );
  }
}

class AppPopupWidget extends StatefulWidget {

  final List<Widget> children;
  final Widget title;
  final EdgeInsets padding;
  final List<Widget> actions;
  final bool canClose;

  const AppPopupWidget({
    Key key,
    @required this.title,
    @required this.children,
    this.padding,
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
      )
    );
  }
}
