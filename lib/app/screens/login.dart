import 'package:avme_wallet/app/controller/events.dart';
import 'package:avme_wallet/app/database/notifier.dart';
import 'package:flutter/material.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart' as theme;
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/controller/globals.dart' as globals;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:provider/provider.dart';

//
// void progress()
// {
//   print("Loading data!! "+ _progress.progress.toString());
// }
Notifier _progress = Notifier();

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Passphrase controller
  TextEditingController _passphrase = new TextEditingController();
  ChangeNotifierProvider loadDialog;
  ButtonStyle _btnStyleLogin = ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsets>
        (EdgeInsets.symmetric(vertical: 17.6, horizontal: 0)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(4), topRight: Radius.circular(4))
          )
      ),
      backgroundColor: MaterialStateProperty.all(theme.mainBlue),
      elevation: MaterialStateProperty.all(0)
  );

  BorderRadius _radiusField = BorderRadius.only(bottomLeft: Radius.circular(4), topLeft: Radius.circular(4));

  @override
  Widget build(BuildContext context)
  {
    _passphrase.text = env["DEFAULT_PASSWORD"] ?? "";
    return Scaffold(
      body: SafeArea(child:
      Container(
        color: theme.defaultTheme().scaffoldBackgroundColor,
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
                          'assets/resized-newlogo02-trans.png',
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
                                        color: theme.mainBlue
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1, color: theme.mainBlue),
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
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      testEventListeneer();
                    },
                    child: Text("Teste Event"),
                    // style: ElevatedButton.styleFrom(
                    //   padding: EdgeInsets.symmetric(vertical: 21, horizontal: 0),
                    style: _btnStyleLogin,
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
    BuildContext _loadingPopupContext;

    // NOTIFIER
    globals.walletManager.notifier = _progress;
    // _progress.addListener(progress);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _loadingPopupContext = context;
        return loadDialog.build(context);
      }
    );

    Map data = await globals.walletManager.authenticate(_passphrase.text);
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
      globals.walletManager.selectedAccount = 0;
      snack("Account #0 selected", context);
      Navigator.pushReplacementNamed(context, "/home");
    }
    // snack(data, context);
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

  void testEventListeneer() async{
    EventListeneer evento = new EventListeneer();
    evento.addListener(fireEvent);

    for(int i = 0; i < 5; i++)
    {
      await Future.delayed(Duration(seconds: 1), (){
        evento.foo = i;
      });
    }
  }

  void fireEvent()
  {
    print("Event fired");
  }
}
