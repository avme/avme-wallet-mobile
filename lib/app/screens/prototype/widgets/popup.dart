import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';

import 'neon_button.dart';
import 'notification_bar.dart';


class AppPopupWidget extends StatefulWidget {
  ///The widget children will be stacked inside a Column widget
  final List<Widget> children;
  final String title;
  final TextStyle textStyle;
  ///This is the default content padding
  final EdgeInsets padding;
  final List<Widget> actions;
  final bool canClose;
  ///This is the distance the popup has between
  ///itself and the device's dimensions
  final EdgeInsets margin;
  final bool showIndicator;
  final bool cancelable;

  AppPopupWidget({
    Key key,
    @required this.title,
    @required this.children,
    this.padding = const EdgeInsets.only(
        left: 32,
        right: 32,
        top: 16,
        bottom: 8
    ),
    this.margin,
    this.actions,
    this.cancelable = true,
    this.canClose = true,
    this.showIndicator = true,
    this.textStyle = const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500
    ),
  }) : super(key: key);

  @override
  _AppPopupWidgetState createState() => _AppPopupWidgetState();
}

class _AppPopupWidgetState extends State<AppPopupWidget> {

  @override
  Widget build(BuildContext context) {

    List<Widget> popupActions = [];

    if(widget.actions != null)
    {
      if(widget.cancelable == true)
      {
        widget.actions.insert(
            0,
            AppNeonButton(
                onPressed: () => Navigator.of(this.context).pop(),
                expanded: false,
                text: "CANCEL"
            ));
        if(widget.actions.length > 0)
          widget.actions.asMap().forEach((key, widget) {
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
      }
      else
        widget.actions.asMap().forEach((key, widget) {
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
    }



    return GestureDetector(
      onTap: () => widget.canClose ? Navigator.of(context).pop() : null,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Builder(
          builder: (BuildContext context) =>
            Center(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  GestureDetector(
                    onTap: () => null,
                    child: WillPopScope(
                      onWillPop: () async {
                        if(!widget.canClose)
                        {
                          NotificationBar().show(
                              context,
                              text: "You can't go back now"
                          );
                        }
                        return widget.canClose;
                      },
                      child: AlertDialog(
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
                          actions: widget.cancelable &&
                              widget.actions == null ? [
                            AppNeonButton(
                                onPressed: () =>
                                    Navigator.of(this.context).pop(),
                                expanded: false,
                                text: "CANCEL"
                            )
                          ] : popupActions,
                          content: Container(
                            width: double.maxFinite,
                            child: Column(
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
                                            Text(
                                              widget.title,
                                              style: widget.textStyle,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      )
                                    ],
                                  ),
                                ),
                                widget.showIndicator ? FractionallySizedBox(
                                  widthFactor: 0.84,
                                  child: ScreenIndicator(
                                    height: 20,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                )
                                    : Container(),
                                Padding(
                                  padding: widget.padding ?? const EdgeInsets.all(32),
                                  child: Column(
                                    children: widget.children,
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }
}
//TODO: Implement cancelable future
class FuturePopupWidget extends StatefulWidget {
  final String title;
  final TextStyle textStyle;
  ///This is the default content padding
  final EdgeInsets padding;
  final List<Widget> actions;
  final bool canClose;
  ///This is the distance the popup has between
  ///itself and the device's dimensions
  final EdgeInsets margin;
  final bool showIndicator;
  final bool cancelable;
  ///The widget children will be stacked inside a Column widget,
  ///contents depend on the returned data from the Future<dynamic>
  final Future future;

  FuturePopupWidget({
    Key key,
    @required this.title,
    @required this.future,
    this.padding = const EdgeInsets.only(
        left: 32,
        right: 32,
        top: 16,
        bottom: 8
    ),
    this.margin,
    this.actions,
    this.cancelable = true,
    this.canClose = true,
    this.showIndicator = true,
    this.textStyle = const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500
    ),
  }) : super(key: key);

  @override
  _FuturePopupWidgetState createState() => _FuturePopupWidgetState();
}

class _FuturePopupWidgetState extends State<FuturePopupWidget> with SingleTickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    List<Widget> popupActions = [];

    if(widget.actions != null)
    {
      if(widget.cancelable == true)
      {
        widget.actions.insert(
            0,
            AppNeonButton(
                onPressed: () => Navigator.of(this.context).pop(),
                expanded: false,
                text: "CANCEL"
            ));
        if(widget.actions.length > 0)
          widget.actions.asMap().forEach((key, widget) {
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
      }
      else
        widget.actions.asMap().forEach((key, widget) {
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
    }

    return GestureDetector(
      onTap: () => widget.canClose ? Navigator.of(context).pop() : null,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Builder(
          builder: (BuildContext context) =>
            Center(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  GestureDetector(
                    onTap: () => null,
                    child: WillPopScope(
                      onWillPop: () async {
                        if(!widget.canClose)
                        {
                          NotificationBar().show(
                              context,
                              text: "You can't go back now"
                          );
                        }
                        return widget.canClose;
                      },
                      child: FutureBuilder(
                        future: widget.future,
                        builder: (BuildContext context, snapshot)
                        {
                          if(snapshot.data == null)
                          {
                            return AlertDialog(
                                backgroundColor: AppColors.cardDefaultColor,
                                contentPadding: EdgeInsets.all(0),
                                insetPadding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width / 4
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                content: Container(
                                  width: double.maxFinite,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding:
                                          const EdgeInsets.all(32),
                                        child: Column(
                                          children:
                                          [
                                            Container(
                                              height: 48,
                                              width: 48,
                                              child: CircularProgressIndicator(
                                                color: AppColors.purple,
                                                strokeWidth: 6,
                                              ),
                                            ),
                                            SizedBox(height: 32),
                                            Text("Loading")
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            );
                          }
                          else {
                            return AlertDialog(
                                insetPadding: widget.margin ??
                                    Dialog().insetPadding,
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
                                actions: widget.cancelable &&
                                    widget.actions == null ? [
                                  AppNeonButton(
                                      onPressed: () =>
                                          Navigator.of(this.context).pop(),
                                      expanded: false,
                                      text: "CANCEL"
                                  )
                                ] : popupActions,
                                content: Container(
                                  width: double.maxFinite,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [

                                      ///Header
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: [

                                                    ///Close button
                                                    IconButton(
                                                      icon: Icon(Icons.close,
                                                        color: widget.canClose
                                                            ? Colors.white
                                                            : Colors
                                                            .transparent,),
                                                      highlightColor: Colors
                                                          .transparent,
                                                      splashColor: Colors
                                                          .transparent,
                                                      onPressed: () {
                                                        if (widget.canClose)
                                                          Navigator.of(context)
                                                              .pop();
                                                      },
                                                    ),
                                                  ],
                                                )
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    widget.title,
                                                    style: widget.textStyle,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(),
                                            )
                                          ],
                                        ),
                                      ),
                                      widget.showIndicator
                                          ? FractionallySizedBox(
                                        widthFactor: 0.84,
                                        child: ScreenIndicator(
                                          height: 20,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                        ),
                                      )
                                          : Container(),
                                      Padding(
                                        padding: widget.padding ??
                                            const EdgeInsets.all(32),
                                        child: Column(
                                          children: snapshot.data,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            );
                          }
                        }
                      )
                      ,
                    ),
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }
}