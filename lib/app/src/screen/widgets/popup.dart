import 'package:avme_wallet/app/src/screen/widgets/hint.dart';
import 'package:avme_wallet/app/src/screen/widgets/painted.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:avme_wallet/app/src/helper/size.dart';
import 'buttons.dart';


class AppPopupWidget extends StatefulWidget {
  ///The widget children will be stacked inside a Column widget
  final List<Widget> children;
  final String title;
  final TextStyle? textStyle;
  ///This is the default content padding
  final EdgeInsets? padding;
  final List<Widget>? actions;
  final bool canClose;
  ///This is the distance the popup has between
  ///itself and the device's dimensions
  final EdgeInsets? margin;
  final bool showIndicator;
  final bool cancelable;
  final bool scrollable;

  AppPopupWidget({
    Key? key,
    required this.title,
    required this.children,
    this.padding,
    this.margin,
    this.actions,
    this.cancelable = true,
    this.canClose = true,
    this.showIndicator = true,
    this.scrollable = false,
    this.textStyle,
    /*
    this.textStyle = const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500
    ),
    */
  }) : super(key: key);

  @override
  _AppPopupWidgetState createState() => _AppPopupWidgetState();
}

class _AppPopupWidgetState extends State<AppPopupWidget> {

  @override
  Widget build(BuildContext context) {
    List<Widget> popupActions = [];

    // TextStyle widgetTextStyle = widget.textStyle ?? AppTextStyles.label.copyWith(fontSize: DeviceSize.titleSize);
    TextStyle widgetTextStyle = widget.textStyle ?? AppTextStyles.label.copyWith(fontSize: DeviceSize.labelSize);

    ScrollPhysics isScrollable = widget.scrollable != false ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics();
    List actions = widget.actions ?? [];

    if(widget.cancelable == true)
    {
      popupActions.insert(
        0,
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: AppNeonButton(
            textStyle: TextStyle(color: Colors.white, fontSize: DeviceSize.spanSize * 1.6),
            onPressed: () => Navigator.pop(this.context),
            expanded: false,
            text: "CANCEL"
          ),
        )
      );
      if(actions.isNotEmpty) {
        actions.asMap().forEach((key, itemWidget) {
          if(actions.first != itemWidget) {
            popupActions.add(
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: itemWidget,
              )
            );
          }
          else {
            popupActions.add(
              itemWidget
            );
          }
        });
      }
    }
    else {
      actions.asMap().forEach((key, itemWidget) {
        if(actions.first != itemWidget)
          popupActions.add(
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: itemWidget,
            )
          );
        else {
          popupActions.add(
            itemWidget
          );
        }
      });
    }


    return GestureDetector(
      onTap: () => widget.canClose ? Navigator.pop(context) : null,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Builder(
          builder: (BuildContext context) =>
            Center(
              child: ListView(
                physics: isScrollable,
                shrinkWrap: true,
                children: [
                  GestureDetector(
                    onTap: () => null,
                    child: WillPopScope(
                      onWillPop: () async {
                        if(!widget.canClose)
                        {
                          AppHint.show("You can't go back now", duration: const Duration(seconds: 2));
                        }
                        return widget.canClose;
                      },
                      child: AlertDialog(
                        insetPadding: widget.margin ?? EdgeInsets.symmetric(
                          ///Vertical margin of the popup
                          horizontal: DeviceSize.safeBlockHorizontal * 4,
                        ),
                        buttonPadding: EdgeInsets.zero,
                        actionsPadding: popupActions.length > 0 ? EdgeInsets.symmetric(
                            vertical: DeviceSize.safeBlockHorizontal * 4,
                            horizontal: DeviceSize.safeBlockHorizontal * 4
                        ) : EdgeInsets.only(top: DeviceSize.safeBlockHorizontal * 5),
                        backgroundColor: AppColors.cardDefaultColor,
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        actions:
                          widget.cancelable &&
                          widget.actions == null
                          ? [
                          AppNeonButton(
                            onPressed: () => Navigator.pop(this.context),
                            expanded: false,
                            text: "CANCEL"
                          )
                        ] : popupActions,
                        content: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal:DeviceSize.safeBlockHorizontal * 4),
                              child: Container(
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ///Header
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: DeviceSize.safeBlockVertical * 2),
                                      child: Text(
                                        widget.title,
                                        style: widgetTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    widget.showIndicator
                                    ? Padding(
                                      padding: EdgeInsets.only(bottom: DeviceSize.safeBlockVertical * 2,),
                                      child: ScreenIndicator(
                                        height: 20,
                                        width: MediaQuery.of(context).size.width,
                                      ),
                                    )
                                    : Container(),
                                    Column(
                                      children: widget.children,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ///Closing Popup button
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.close, color: widget.canClose ? Colors.white : Colors.transparent,
                                  textDirection: TextDirection.ltr,
                                ),
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                padding: EdgeInsets.all(0),
                                // alignment: Alignment.topRight.add(Alignment(0.55, 0.0)),
                                onPressed: () {
                                  if(widget.canClose) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ),
                          ],
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

class FuturePopupWidget extends StatefulWidget {
  final String title;
  final TextStyle textStyle;
  ///This is the default content padding
  final EdgeInsets? padding;
  final List<Widget>? actions;
  final bool canClose;
  ///This is the distance the popup has between
  ///itself and the device's dimensions
  final EdgeInsets? margin;
  final bool showIndicator;
  final bool cancelable;

  final Future<List<Widget>> future;

  FuturePopupWidget({
    Key? key,
    required this.title,
    required this.future,
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
    List<Widget> actions = widget.actions ?? [];

    if(widget.cancelable == true)
    {
      popupActions.insert(
        0,
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: AppNeonButton(
            onPressed: () => Navigator.pop(this.context),
            expanded: false,
            text: "CANCEL"
          ),
        )
      );
      if(actions.isNotEmpty) {
        actions.asMap().forEach((key, itemWidget) {
          if(actions.first != itemWidget) {
            popupActions.add(
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: itemWidget,
              )
            );
          }
          else {
            popupActions.add(
              itemWidget
            );
          }
        });
      }
    }
    else {
      actions.asMap().forEach((key, itemWidget) {
        if(actions.first != itemWidget) {
          popupActions.add(
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: itemWidget,
              )
          );
        }
        else {
          popupActions.add(itemWidget);
        }
      });
    }

    return GestureDetector(
      onTap: () => widget.canClose ? Navigator.pop(context) : null,
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
                        AppHint.show("You can't go back now", duration: const Duration(seconds: 2));
                      }
                      return widget.canClose;
                    },
                    child: FutureBuilder<List<Widget>>(
                      future: widget.future,
                      builder: (BuildContext context, AsyncSnapshot snapshot)
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
                                EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
                              buttonPadding: const EdgeInsets.all(0),
                              actionsPadding: EdgeInsets.only(
                                right: widget.padding!.right,
                                bottom: widget.padding!.top,
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
                                        Navigator.pop(this.context),
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
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [

                                                  ///Close button
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.close,
                                                      color: widget.canClose
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                    ),
                                                    highlightColor: Colors.transparent,
                                                    splashColor: Colors.transparent,
                                                    onPressed: () {
                                                      if (widget.canClose) {
                                                        Navigator.pop(context);
                                                      }
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
                                        width: MediaQuery.of(context).size.width,
                                      ),
                                    )
                                    : Container(),
                                    Padding(
                                      padding: widget.padding ?? const EdgeInsets.all(32),
                                      child: Column(
                                        children: snapshot.data!!,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          );
                        }
                      }
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

class ProgressPopup extends StatefulWidget {
  final String title;
  final List<ValueNotifier>? listNotifier;
  final TextStyle textStyle;
  ///This is the default content padding
  final EdgeInsets padding;
  final List<Widget>? actions;
  ///This is the distance the popup has between
  ///itself and the device's dimensions
  final EdgeInsets? margin;
  final bool showIndicator;
  final Future? future;

  final bool dismiss;

  ProgressPopup({
    Key? key,
    required this.title,
    this.listNotifier,
    required this.future,
    this.padding = const EdgeInsets.only(
      left: 32,
      right: 32,
      top: 16,
      bottom: 8
    ),
    this.margin,
    this.actions,
    this.showIndicator = false,
    this.textStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500
    ),
    this.dismiss = false,
  }) : super(key: key);

  @override
  _ProgressPopupState createState() => _ProgressPopupState();
}

class _ProgressPopupState extends State<ProgressPopup> with SingleTickerProviderStateMixin{

  late List<ValueNotifier> _listNotifier;

  @override
  void initState()
  {
    _listNotifier = widget.listNotifier ?? [ValueNotifier(10),ValueNotifier("This may take a while.")];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> popupActions = [];
    List<Widget> actions = widget.actions ?? [];

    actions.asMap().forEach((key, widget) {
      if(key.remainder(2) == 0) {
        popupActions.add(
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: widget,
          )
        );
      }
      else {
        popupActions.add(
          widget
        );
      }
    });


    return GestureDetector(
      onTap: () => dotenv.get("DEBUG_MODE") == "TRUE" ? Navigator.pop(context) : null,
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
                          AppHint.show("please wait for the current operation to finish.");
                          return false;
                        },
                        child: FutureBuilder(
                            future: widget.future,
                            builder: (BuildContext context, snapshot)
                            {
                              if(snapshot.data == null || widget.dismiss)
                              {
                                return AlertDialog(
                                  backgroundColor: AppColors.cardDefaultColor,
                                  contentPadding: EdgeInsets.all(DeviceSize.safeBlockHorizontal * 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  content: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: DeviceSize.safeBlockHorizontal * 6),
                                        child: Column(
                                          children: [
                                            Container(
                                              // color: Colors.green,
                                              child: SizedBox(
                                                height: DeviceSize.safeBlockVertical * 5.5,
                                                width: DeviceSize.safeBlockVertical * 5.5,
                                                child: CircularProgressIndicator(
                                                  color: AppColors.purple,
                                                  strokeWidth: DeviceSize.titleSize / 5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        // color:Colors.blue,
                                        child: Flexible(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ValueListenableBuilder(
                                                valueListenable: _listNotifier[0],
                                                builder: (BuildContext context, text, Widget? child) =>
                                                  Text("Loading $text%", textAlign: TextAlign.left,)),
                                              SizedBox(height: 8),
                                              ValueListenableBuilder(
                                                valueListenable: _listNotifier[1],
                                                builder: (BuildContext context, text, Widget? child) =>
                                                  Text("$text",style: AppTextStyles.span, textAlign: TextAlign.left,))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                );
                              }
                              else {
                                dynamic data = snapshot.data!;
                                Widget? container;
                                if(data is List<Widget>)
                                {
                                  container = Column(
                                    children: [
                                      Column(
                                        children: data,
                                      ),
                                      SizedBox(
                                        height: 24,
                                      ),
                                      Column(
                                          children: [
                                            AppButton(
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                              expanded: false,
                                              text: "Ok",
                                            )
                                          ]
                                      ),
                                      SizedBox(
                                        height: 24,
                                      ),
                                    ],
                                  );
                                }
                                return AlertDialog(
                                    insetPadding: widget.margin ??
                                      EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
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
                                                              color: Colors.white),
                                                          highlightColor: Colors.transparent,
                                                          splashColor: Colors.transparent,
                                                          onPressed: () {
                                                            Navigator.pop(context);
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
                                              width: MediaQuery.of(context).size.width,
                                            ),
                                          )
                                          : Container(),
                                          container ?? Container()
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