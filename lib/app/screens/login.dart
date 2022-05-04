import 'dart:convert';
import 'dart:io';

import 'package:avme_wallet/app/controller/authapi.dart';
import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  final bool canGoBack;

  const Login({Key key, this.canGoBack = true}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _passphrase = TextEditingController();
  bool allowFingerprint = false;
  AuthApi authApi;

  @override
  void initState() {
    checkAuthenticate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double fieldSpacing = SizeConfig.safeBlockVertical * 2;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[AppColors.purpleVariant1, AppColors.purpleBlue])),
          child: GestureDetector(
            onTap: () {},
            child: Center(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.safeBlockHorizontal * 8,
                      ),
                      child: Container(
                        child: Card(
                          color: AppColors.cardBlue,
                          child: Container(
                              child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.safeBlockVertical * 4,
                              horizontal: SizeConfig.safeBlockVertical * 4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ///Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          !widget.canGoBack
                                              ? GestureDetector(
                                                  ///Close button
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    //color: Colors.red,
                                                    // previously there was a padding involving icon
                                                    child: Icon(
                                                      Icons.arrow_back,
                                                      size: 32,
                                                      color: AppColors.labelDefaultColor,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          Text("Load", style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.titleSize)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: SizeConfig.safeBlockVertical * 2),
                                  child: ScreenIndicator(
                                    height: SizeConfig.safeBlockVertical * 2,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: fieldSpacing,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Please type your passphrase.',
                                            style: AppTextStyles.span.copyWith(fontSize: SizeConfig.fontSize * 1.5),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: SizeConfig.safeBlockVertical * 2,
                                      ),
                                      AppTextFormField(
                                        controller: _passphrase,
                                        obscureText: true,
                                        hintText: "**********",
                                        onFieldSubmitted: (_) {
                                          authenticate(context, _passphrase.text);
                                        },
                                        icon: allowFingerprint
                                            ? Icon(
                                                Icons.fingerprint,
                                                color: AppColors.labelDefaultColor,
                                                size: 32,
                                              )
                                            : Container(),
                                        // iconOnTap: () => NotificationBar().show(context, text:"Opening the camera"),
                                        iconOnTap: () async {
                                          if (allowFingerprint) {
                                            dynamic _temp = await authApi.retrieveSecret();
                                            if (_temp is String) {
                                              AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);
                                              app.fingerprintAuth = true;
                                              bool valid = await app.login(_temp, context, display: true);
                                              if (valid) {
                                                app.selectedId = 0;
                                                Navigator.pushReplacementNamed(context, "app/overview");
                                              }
                                            }
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: fieldSpacing * 2,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          authenticate(context, _passphrase.text);
                                        },
                                        child: Text("LOAD EXISTING WALLET"),
                                        // style: ElevatedButton.styleFrom(
                                        //   padding: EdgeInsets.symmetric(vertical: 21, horizontal: 0),
                                        // style: _btnStyleLogin,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkAuthenticate() async {
    authApi = await AuthApi.init();
    allowFingerprint = authApi.canAuthenticate();
    setState(() {});
    if (allowFingerprint) {
      AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);
      app.fingerprintAuth = true;
      dynamic _temp = await authApi.retrieveSecret();
      if (_temp is String) {
        bool valid = await app.login(_temp, context, display: true);
        if (valid) {
          app.selectedId = 0;
          Navigator.pushReplacementNamed(context, "app/overview");
        }
      }
    }
  }

  void authenticate(BuildContext context, String password) async {
    bool empty = (this._passphrase == null || _passphrase.text.length == 0) ? true : false;
    if (empty)
      showDialog(context: context, builder: (BuildContext context) => SimpleWarning(title: "Warning", text: "The Password field cannot be empty."));
    else {
      AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);
      bool valid = await app.login(this._passphrase.text, context, display: true);
      if (valid) {
        // app.changeCurrentWalletId = 0;
        app.selectedId = 0;
        Navigator.pushReplacementNamed(context, "app/overview");
      }
    }
  }
}
