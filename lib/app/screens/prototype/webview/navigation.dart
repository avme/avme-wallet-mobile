// @dart=2.12
import 'dart:async';

import 'package:avme_wallet/app/controller/web/webview.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter/material.dart';

import 'address_bar.dart';
import 'menu.dart';

class Navigation extends StatefulWidget {

  const Navigation({
    this.transparent = false,
    this.enabled = true,
    required this.appWebViewController,
  });
  final bool transparent;
  final bool enabled;
  final AppWebViewController appWebViewController;
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {

  TextEditingController addressController = TextEditingController();
  late Future<bool> trackUrl;
  late String navigationUrl;

  @override
  void initState() {
    super.initState();
    navigationUrl = widget.appWebViewController.initialUrl;
    trackUrl = requestUrl();
  }

  @override
  void didUpdateWidget(Navigation oldWidget) {
    requestUrl();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 0,
          // bottom: 8.0,
          left: 8.0,
          right: 8.0
        ),
        child: Container(
          // color: Colors.white10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              WebMenu(
                widget.appWebViewController.controller.future,
                widget.appWebViewController.cookieManager
              ),
              AddressBar(
                addressController: addressController,
                enabled: widget.enabled,
                isLoadingStream: widget.appWebViewController.isLoading,
                controller: widget.appWebViewController.controller.future,
              )
            ]
          ),
        ),
      ),
    );
  }

  Future<bool> requestUrl() async {
    addressController.text = navigationUrl;
    if(widget.enabled == false)
      return true;
    widget.appWebViewController.onPageStarted.listen((url) {
      if(url is String)
        try
        {
          Uri.parse(url);
          setState(() {
            addressController.text = navigationUrl = url;
          });
        }
        catch(e) {}
    });
    return true;
  }
}

