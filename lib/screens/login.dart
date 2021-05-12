import 'package:flutter/material.dart';
import 'package:avme_wallet/config/main_theme.dart' as theme;
import 'package:avme_wallet/screens/helper.dart';

class Login extends StatelessWidget with Helpers{

  //Passphrase controller
  TextEditingController _passphrase = new TextEditingController();
  ButtonStyle _btnStyleLogin = ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsets>
        (EdgeInsets.symmetric(vertical: 17.6, horizontal: 0)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(4), topRight: Radius.circular(4))
          )
      ),
      elevation: MaterialStateProperty.all(0)
  );

  BorderRadius _radiusField = BorderRadius.only(bottomLeft: Radius.circular(4), topLeft: Radius.circular(4));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:
      Container(
        // padding: EdgeInsets.all(5),
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
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
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
                                        color: theme.defaultTheme().colorScheme.primary
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1, color: theme.defaultTheme().colorScheme.primary),
                                        borderRadius: _radiusField
                                    ),

                                  )
                              ),
                            ),
                            SizedBox(
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement the authentication
                                  snack("Please implement this method!", context);
                                },
                                child: Icon(Icons.arrow_forward_outlined),
                                // style: ElevatedButton.styleFrom(
                                //   padding: EdgeInsets.symmetric(vertical: 21, horizontal: 0),
                                style: _btnStyleLogin,
                              ),
                            ),]
                      )
                  ),
                )
              ]
          )
      )
      ),
    );
  }
}
