import 'package:avme_wallet/app/controller/events.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:provider/provider.dart';

//
// void progress()
// {
//   print("Loading data!! "+ _progress.progress.toString());
// }

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Passphrase controller
  TextEditingController _passphrase = new TextEditingController();
  ButtonStyle _btnStyleLogin = ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsets>
        (EdgeInsets.symmetric(vertical: 17.6, horizontal: 0)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(4), topRight: Radius.circular(4))
          )
      ),
      backgroundColor: MaterialStateProperty.all(AppColors.lightBlue1),
      elevation: MaterialStateProperty.all(0)
  );

  BorderRadius _radiusField = BorderRadius.only(bottomLeft: Radius.circular(4), topLeft: Radius.circular(4));

  @override
  Widget build(BuildContext context)
  {
    _passphrase.text = dotenv.get("DEFAULT_PASSWORD") ?? "";
    return Scaffold(
      body: SafeArea(child:
      Container(
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                // flex: 1, default as 1
                  child:
                  Container(
                    color: Color(0xAFFFFFF),
                    constraints: BoxConstraints.expand(),
                    child: Center(
                      child: Image.asset(
                        'assets/avme_logo.png',
                        width: 120,
                        fit: BoxFit.fitHeight,),
                    ),
                  )
              ),
              Container(
                color: Color(0xFFFFFFF),
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Center(child: Text("Welcome to AVME Wallet"),),
              ),
              Expanded(
                flex: 2,
                child:
                Container(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                    // color: Color(0x26FFFFFF),
                    constraints: BoxConstraints.expand(),
                    child:
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: TextField(
                                controller: _passphrase,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: _radiusField
                                  ),
                                  labelText: "Please type your passphrase.",
                                  labelStyle: TextStyle(
                                      color: AppColors.lightBlue1
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1,
                                          color: AppColors.lightBlue1
                                      ),
                                      borderRadius: _radiusField
                                  ),

                                )
                            ),
                          ),
                          SizedBox(
                            child: ElevatedButton(
                              onPressed: () async{
                                authenticate(context);
                              },
                              child: Icon(Icons.arrow_forward_outlined),
                              // style: ElevatedButton.styleFrom(
                              //   padding: EdgeInsets.symmetric(vertical: 21, horizontal: 0),
                              style: _btnStyleLogin,
                            ),
                          ),
                        ]
                    )
                ),
              ),
            ],
          )
      )
      ),
    );
  }
  void authenticate(BuildContext context) async
  {
    bool empty = (_passphrase == null || _passphrase.text.length == 0) ? true : false;
    AvmeWallet appState = Provider.of<AvmeWallet>(context, listen: false);

    BuildContext _loadingPopupContext;
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

    if(empty)
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
      appState.selectedId = 0;
      snack("Account #0 selected", context);
      Navigator.pushReplacementNamed(context, "/home");
    }
  }
}
