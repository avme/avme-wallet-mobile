// @dart=2.12
/*
Add to wallet provider and other classes a way to try and decrypt the wallet file with the password, no need to
actually get the file and load the wallet, just check if it is possible to decrypt, if so, then it is the correct password
*/
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/authentication.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthSetupScreen extends StatefulWidget {
  const AuthSetupScreen({Key? key}) : super(key: key);

  @override
  _AuthSetupScreenState createState() => _AuthSetupScreenState();
}

class _AuthSetupScreenState extends State<AuthSetupScreen> {
  late Authentication _authApi;
  late TextEditingController _controller;
  bool swap = false;

  @override
  void initState() {
    super.initState();
    _authApi = Authentication();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
        body: Stack(
      alignment: Alignment.center,
      children: [swap ? setup() : start()],
    ));
  }

  ///--------------------------------------------------------------

  Widget start() {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 2),
      child: AppCard(
        child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            margin: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal * 6),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Please type your passphrase.',
                            style: AppTextStyles.span
                                .copyWith(fontSize: SizeConfig.fontSize * 1.5),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 4,
                      ),
                      AppTextFormField(
                        controller: _controller,
                        obscureText: true,
                        hintText: "**********",
                        onFieldSubmitted: (_) {
                          authenticate(_controller.text);
                        },
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical * 4,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          authenticate(_controller.text);
                        },
                        child: Text("LOAD EXISTING WALLET"),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  void authenticate(String text) async {
    //get wallet password somehow
    AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);
    bool valid = await app.login(text, context, display: true);
    if (valid) {
      swap = !swap;
      FocusScope.of(context).unfocus();
      setState(() {});
    } else {
      NotificationBar()
          .show(context, text: 'Wrong password...', onPressed: () {});
    }
  }

  Widget setup() {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 2),
      child: AppCard(
        child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            margin: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal * 6),
                  child: Column(
                    children: [
                      Text('Fingerprint configuration'),
                      ElevatedButton(
                        onPressed: () async {
                          print('SAVE');
                          await _authApi.saveSecret(_controller.text);
                          NotificationBar().show(context,
                              text: 'Fingerprint added', onPressed: () {});
                        },
                        child: Text("SAVE"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return AppPopupWidget(
                                  title: 'Delete Secret?',
                                  canClose: true,
                                  margin: EdgeInsets.all(16),
                                  cancelable: false,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 32),
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        AppNeonButton(
                                            expanded: false,
                                            textStyle: TextStyle(fontSize: 18),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            text: "Cancel"),
                                        AppNeonButton(
                                            expanded: false,
                                            textStyle: TextStyle(fontSize: 18),
                                            onPressed: () async {
                                              String result =
                                                  await _authApi.deleteSecret();
                                              Navigator.pop(context);
                                              NotificationBar().show(context,
                                                  text: result,
                                                  onPressed: () {});
                                            },
                                            text: "Continue"),
                                      ],
                                    )
                                  ],
                                );
                              });
                        },
                        child: Text("DELETE"),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
