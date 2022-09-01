import 'dart:async';
import 'dart:io';

import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:avme_wallet/app/src/controller/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../helper/size.dart';
import '../../screen/widgets/hint.dart';
import '../../screen/widgets/theme.dart';

class ProgressDialog {
  ValueNotifier<String> label = ValueNotifier("Loading...");
  ValueNotifier<num> percentage = ValueNotifier(0);
  ProgressDialog([label, percentage]){
    this.label.value = label ?? this.label.value;
    this.percentage.value = percentage ?? this.percentage.value;
  }
}

class ProgressPopup {
  static final ProgressPopup _self = ProgressPopup._internal();

  ProgressPopup._internal();

  factory ProgressPopup() => _self;

  bool visible = false;
  static BuildContext? context;
  bool isDesktop = Platform.isWindows || Platform.isLinux;
  Completer<bool> isDone = Completer();

  static Future<ProgressDialog> display([ProgressDialog? progress]) async {
    if (_self.visible) {
      // throw "Error at ProgressPopup.display -> Already displaying a process";
      Print.warning("Error at ProgressPopup.display -> Already displaying a process");
      await _self.isDone.future;
    }
    ProgressDialog pDialog = progress ?? ProgressDialog();

    _self.visible = true;
    context = Routes.globalContext.currentContext;

    if (_self.isDesktop) {
      Print.warning("[Warning] Device detected as Desktop");
      pDialog.percentage.addListener(() => _self.terminalListener(pDialog));
    }
    else
    {
      showDialog(
        context: context!,
        builder: (_) {
          return StatefulBuilder(
            builder: (builder, setState) {
              return _self.ui(context!, pDialog);
            },
          );
        }
      );
    }
    return pDialog;
  }

  static void dismiss()
  {
    if(_self.visible) {
      _self.visible = !_self.visible;
      _self.isDone.complete(true);
      if(!_self.isDesktop)
      {
        Navigator.pop(context!);
      }
      _self.isDone = Completer();
    }
  }

  void terminalListener(ProgressDialog progress)
  {
    Print.mark("[Progress Dialog] ${progress.percentage.value} - ${progress.label.value}");
  }

  Widget ui(BuildContext context, ProgressDialog progress){
    return GestureDetector(
      onTap: () {
        if(dotenv.get("DEBUG_MODE") == "TRUE")
        {
          return dismiss();
        }
        return null;
      },
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
                      child: AlertDialog(
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
                                        valueListenable: progress.percentage,
                                        builder: (BuildContext context, text, Widget? child) {
                                          return Text("Loading $text%",
                                            textAlign: TextAlign.left);
                                        }
                                      ),
                                      SizedBox(height: 8),
                                      ValueListenableBuilder(
                                        valueListenable: progress.label,
                                        builder: (BuildContext context, String text, Widget? child) {
                                          return Text(text,
                                            style: AppTextStyles.span,
                                            textAlign: TextAlign.left,
                                          );
                                        }
                                      )
                                    ],
                                  ),
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