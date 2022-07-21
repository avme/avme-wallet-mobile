import 'package:avme_wallet/app/src/controller/wallet/wallet.dart';
import 'package:avme_wallet/app/src/screen/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/src/helper/size.dart';
import 'package:avme_wallet/app/src/screen/widgets/widgets.dart';
import 'package:avme_wallet/app/src/controller/wallet/authentication.dart';

class Login extends StatefulWidget {
  final bool canGoBack;

  const Login({Key? key, this.canGoBack = true}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _passphrase = TextEditingController();
  bool loginWithDevice = false;

  Future init() async {
      loginWithDevice = await Authentication.registeredAuth.future;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    double fieldSpacing = DeviceSize.safeBlockVertical * 2;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[AppColors.purpleVariant1, AppColors.purpleBlue]
            )
          ),
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
                        horizontal: DeviceSize.safeBlockHorizontal * 8,
                      ),
                      child: Container(
                        child: Card(
                          color: AppColors.cardBlue,
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: DeviceSize.safeBlockVertical * 4,
                                horizontal: DeviceSize.safeBlockVertical * 4,
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
                                            widget.canGoBack
                                              ? Container()
                                              : GestureDetector(
                                                ///Close button
                                                child: Container(
                                                  color: Colors.transparent,
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
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          children: [
                                            Text("Load", style: TextStyle(fontWeight: FontWeight.bold, fontSize: DeviceSize.titleSize)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: DeviceSize.safeBlockVertical * 2),
                                    child: ScreenIndicator(
                                      height: DeviceSize.safeBlockVertical * 2,
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
                                              style: AppTextStyles.span.copyWith(fontSize: DeviceSize.fontSize * 1.5),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: DeviceSize.safeBlockVertical * 2,
                                        ),
                                        AppTextFormField(
                                          controller: _passphrase,
                                          obscureText: true,
                                          hintText: "**********",
                                          // onFieldSubmitted: (_) {
                                          //   submit();
                                          // },
                                          onFieldSubmitted: submit,
                                          icon:
                                            loginWithDevice
                                            ? Icon(
                                                Icons.fingerprint,
                                                color: AppColors.labelDefaultColor,
                                                size: 32,
                                              )
                                            : Container(),
                                          iconOnTap: () async {
                                            dynamic data = await Authentication.auth();
                                            if(data != null)
                                            {
                                              Navigator.pushReplacementNamed(context, '/navigation/dashboard');
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          height: fieldSpacing * 2,
                                        ),
                                        ElevatedButton(
                                          onPressed: submit,
                                          child: Text("LOAD EXISTING WALLET"),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ),
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

  void submit([dynamic arg1]) async
  {
    bool didAuth = await Wallet.auth(_passphrase.text);
    if(didAuth)
    {
      Navigator.pushReplacementNamed(context, '/navigation/dashboard');
    }
    else
    {
      setState(() {
        _passphrase.text = "";
      });
    }
  }
}
