import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:avme_wallet/app/src/screen/widgets/hint.dart';
import 'package:flutter/material.dart';

class Send extends StatefulWidget {
  const Send({Key? key}) : super(key: key);

  @override
  State<Send> createState() => _SendState();
}

class _SendState extends State<Send> {

  ///List of available tokens with image and label
  List availableTokens = [];

  Future selfInit() async {
    availableTokens.addAll(await Coins.listRaw());
    // availableTokens.insert(0, Coins.platform)
    AppHint.show("$availableTokens", duration: Duration(seconds: 3600));
  }

  @override
  void initState() {
    super.initState();
    selfInit();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
