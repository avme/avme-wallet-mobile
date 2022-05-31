// @dart=2.12
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../controller/web/web_utils.dart';
import '../../button.dart';
import '../../neon_button.dart';
import '../../popup.dart';

Future<bool> requestSitePermission(BuildContext context, String origin, {bool unlocked = false, required AllowedUrls allowedUrls})
async {
  /// This Popup will hold the request until the user interacts
  Completer<bool> onWait = Completer();
  showDialog(
    context: context, builder: (BuildContext context) {
    return AppPopupWidget(
        title: "Warning",
        cancelable: unlocked,
        canClose: true,
        actions: [
          AppNeonButton(
              expanded: false,
              onPressed: () {
                allowedUrls.blockSite(origin);
                Navigator.of(context).pop();
                onWait.complete(false);
              },
              text: "CANCEL"
          ),
          AppButton(
              expanded: false,
              onPressed: () {
                allowedUrls.allowSite(origin);
                Navigator.of(context).pop();
                onWait.complete(true);
              },
              text: "ALLOW"
          ),
        ],
        children: [
          Column(
            children: [
              Text("The website \"$origin\" is requesting your permission, allow it?")
            ],
          )
        ]
    );
  },
  );

  return await onWait.future;
}