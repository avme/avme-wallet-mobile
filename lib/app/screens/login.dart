import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/screen_indicator.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _passphrase = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height * 1 / 3;
    double width = MediaQuery.of(context).size.width * 1 / 1.25;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.purpleVariant1,
                  AppColors.purpleDark2
                ]
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Card(
                  color: AppColors.cardBlue,
                  child: Container(
                    height: height * 1.125,
                    width: width,
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints)
                      {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: constraints.maxHeight * 1 / 8,
                            horizontal: constraints.maxHeight * 1 / 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  "Load",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 28)
                              ),
                              SizedBox(
                                height: 14,
                              ),
                              ScreenIndicator(
                                height: 20,
                                width: constraints.maxWidth,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextField(
                                  cursorColor: AppColors.labelDefaultColor,
                                  controller: _passphrase,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "Please type your passphrase.",
                                    labelStyle: TextStyle(
                                        color: AppColors.labelDefaultColor
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1,
                                          color: AppColors.labelDefaultColor
                                      ),
                                    ),
                                  )
                              ),
                              SizedBox(
                                height: 32,
                              ),
                              ElevatedButton(
                                onPressed: () async{
                                  authenticate(context);
                                },
                                child: Text("LOAD EXISTING WALLET"),
                                // style: ElevatedButton.styleFrom(
                                //   padding: EdgeInsets.symmetric(vertical: 21, horizontal: 0),
                                // style: _btnStyleLogin,
                              ),
                            ],
                          ),
                        );
                      },),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

  void authenticate(BuildContext context) async
  {
    bool empty = (this._passphrase == null || _passphrase.text.length == 0) ? true : false;
    AvmeWallet appState = Provider.of<AvmeWallet>(context, listen: false);
    BuildContext _loadingPopupContext;
    if(!empty)
    {
      showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            _loadingPopupContext = context;

            // Always get the provider inside the build method
            AvmeWallet appState = Provider.of<AvmeWallet>(context);
            appState.watchAccountsStateChanges();
            int progress = appState.accountsState.progress == 0 ? 0 : (( appState.accountsState.progress / appState.accountsState.total) * 100).toInt();
            return CircularLoading(
                text: "$progress% Loading accounts."
            );
          }
      );
    }
    else
    {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) =>
          SimpleWarning(
            title: "Warning",
            text:
            "The passphrase field cannot be empty."
          )
      );
      return;
    }

    Map data = await appState.walletManager.authenticate(_passphrase.text, appState);
    if(data["status"] != 200)
    {
      Navigator.pop(_loadingPopupContext);
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) =>
          SimpleWarning(
            title: "Warning",
            text:
            // "Wrong password, try again."
            data["message"]
          )
      );
      _passphrase.text = "";
      return;
    }
    else
    {
        Navigator.pop(_loadingPopupContext);
        appState.changeCurrentWalletId = 0;
        snack("Account #0 selected", context);
        Navigator.pushReplacementNamed(context, "/home");
        // Navigator.pushReplacementNamed(context, "test/preview");
    }
  }
}


