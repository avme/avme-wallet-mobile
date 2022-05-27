// @dart=2.12
import 'package:avme_wallet/app/controller/web/webview.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddressBar extends StatefulWidget {
  const AddressBar({
    required this.addressController,
    required this.enabled,
    required this.isLoadingStream,
    required this.controller
  });

  final TextEditingController addressController;
  final bool enabled;
  final Stream<bool> isLoadingStream;
  final Future<WebViewController> controller;

  @override
  _AddressBarState createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> with SingleTickerProviderStateMixin {

  late AnimationController _loadingAnimationController;
  late Animation<double> _animation;

  late Future<bool> addressBar;
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    addressBar = _addressBar();

    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1)
    )..repeat(reverse: false);
    _animation = CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.linear
    );

  }

  Future<bool> _addressBar()
  async {
    webViewController = await widget.controller;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: widget.enabled
                ? TextFormField(
                  controller: widget.addressController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black12,
                    // fillColor: AppColors.purpleDark2,
                    contentPadding: EdgeInsets.all(4),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                )
                : Container(),
            ),
          ),
          FutureBuilder<bool>(
            future: addressBar,
            builder: (context, snapWeb) {
              bool controllerReady = snapWeb.connectionState == ConnectionState.done;
              return Container(
                child: StreamBuilder<bool>(
                  stream: widget.isLoadingStream,
                  builder: (context, snapshot) {
                    bool isLoading = snapshot.data ?? false;
                    if(isLoading)
                      _loadingAnimationController.repeat();
                    else
                      _loadingAnimationController.reset();
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: controllerReady && !isLoading ?
                        () {
                          webViewController.reload();
                        } : null,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 10,
                          top: 8,
                          bottom: 8
                        ),
                        child: RotationTransition(
                          turns: _animation,
                          child: Icon(
                            Icons.refresh_rounded,
                            color: isLoading ? AppColors.labelDisabledColor : AppColors.labelDefaultColor,
                            size: 26,
                          ),
                        ),
                      ),
                    );
                  }
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}
