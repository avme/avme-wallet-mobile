//main file of the design, change to cappucino or something else on:
//url: [IMPLEMENT URL]
import 'dart:math';
import 'dart:io';
import 'package:avme_wallet/screens/initial_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:avme_wallet/screens/helper.dart';
import 'package:after_layout/after_layout.dart';
import 'package:avme_wallet/controller/globals.dart' as global;
import 'package:avme_wallet/screens/tabswallet.dart';
import 'package:avme_wallet/screens/new_password.dart';
import 'package:avme_wallet/config/main_theme.dart';
var random = Null;

final String password = "abacate";
void main() {
  runApp(AvmeWallet());
}

class AvmeWallet extends StatelessWidget with Helpers {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // ThemeData theme = ThemeData.dark();
    ThemeData theme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF51ADFF),
      // accentColor: Color(0xFF7238AD),
      accentColor: Color(0xFFFFFFFF),
      fontFamily: 'Roboto Mono',
    );
    return MaterialApp(
      // home: Login(),
      // home: Scaffold(
      //   appBar: AppBar(title: Text()),
      //   body: Login(),
      //   // body: Password()
      // ),
      // theme: ThemeData.light(),
      theme: defaultTheme(),
      initialRoute: '/initialLoad',
      routes: {
        // '/' : (context) => InitialLoading(),
        '/old' : (context) => LoginOld(),
        '/passphrase' : (context) => Password(),
        '/debugOptions' : (context) => Options(),
        '/initialLoad' : (context) => InitialLoading(),
        '/home' : (context) => TabsWallet(),
        '/registerPassword' : (context) => NewPassword(),
    });
  }
}

class LoginOld extends StatefulWidget
{
  //Criando estado do nosso widget
  //retorna o State do nosso Login State
  @override
  State<StatefulWidget> createState() => LoginOldState();

  void onLoad(BuildContext context)
  {
      debugPrint('loaded');
  }
}

// class Login extends StatelessWidget with Helpers{
//   @override
//   Widget build(BuildContext context) {
//     TextStyle _textStyle = TextStyle(
//         fontFamily: 'Montserrat',
//         fontSize: 20.0, color: Colors.white
//     );
//     EdgeInsets _padding = EdgeInsets.fromLTRB(10, 5, 10, 5);
//     BorderRadius _borderRadius = BorderRadius.circular(16.0);
//     OutlineInputBorder _outlineInputBorder = OutlineInputBorder(
//         borderRadius: _borderRadius,
//     );
//     final password = TextField(
//       obscureText: false,
//       style: _textStyle,
//       decoration: InputDecoration(
//         contentPadding: _padding,
//         hintText: "Your password here owo",
//         fillColor: Colors.white60,
//         hintStyle: TextStyle(
//           color: Colors.white
//         )
//       )
//     );
//     final loginBtn = Material(
//       elevation: 5,
//       borderRadius: _borderRadius,
//       color: Color(0xff01A0C7),
//       child: MaterialButton(
//         minWidth: MediaQuery.of(context).size.width,
//         padding: _padding,
//         onPressed: () {
//           snack("Log-in button fired!", context);
//         },
//         child: Text("Login",
//           textAlign: TextAlign.center,
//           style: _textStyle.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.bold
//           ),
//         ),
//       )
//       ,
//     );
//     // return Scaffold(
//     //   body: Center(
//     //     child: Container(
//     //       color: Colors.white,
//     //       child: Padding(
//     //         padding: EdgeInsets.all(36),
//     //         child: Column(
//     //           crossAxisAlignment: CrossAxisAlignment.center,
//     //           mainAxisAlignment: MainAxisAlignment.center,
//     //           children: [
//     //             SizedBox(
//     //               height: 155.0,
//     //               child: Image.asset("assets/supreme_f.png", fit: BoxFit.contain,),
//     //             ),
//     //             SizedBox(height: 45.0),
//     //             password,
//     //             SizedBox(height: 45.0),
//     //             loginBtn
//     //           ]
//     //         ),
//     //       )
//     //     )
//     //   ),
//     // );
//     return Scaffold(
//       body: Column(
//         children: [
//         Flexible(
//           flex: 2,
//           child:
//           Container(
//             color: Colors.blue,
//             child:
//             Center(
//               child:
//                 Container(
//                   child: SizedBox(
//                     // height: 155.0,
//                     // child: Image.asset("assets/supreme_f.png", fit: BoxFit.contain,),
//                     child: Image.asset("assets/newlogo02-trans.png", fit: BoxFit.contain, height: 170,),
//                   )
//                 )
//
//             ),
//           ),
//         ),
//         Flexible(
//           flex: 3,
//           child:
//           Container(
//             color: Colors.red,
//             child:
//
//             Padding(
//               padding: EdgeInsets.fromLTRB(20,0,20,0),
//               child:
//               Column(
//                 children: [
//                   SizedBox(height: 20.0),
//                   password,
//                   SizedBox(height: 20.0),
//                   loginBtn
//                 ]
//               ),
//             )
//
//           ),
//         )
//         ],
//       ),
//     );
//     return Scaffold(
//       body: Center(
//           child: Container(
//               color: Colors.white,
//               child: Padding(
//                 padding: EdgeInsets.all(36),
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         height: 155.0,
//                         child: Image.asset("assets/supreme_f.png", fit: BoxFit.contain,),
//                       ),
//                       SizedBox(height: 45.0),
//                       password,
//                       SizedBox(height: 45.0),
//                       loginBtn
//                     ]
//                 ),
//               )
//           )
//       ),
//     );
//   }
// }


class Password extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Password Widget")),
        body:
          Center(
          child:
            Text("Password Widget",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),)
        )
      );
  }
}


class Options extends StatelessWidget with Helpers
{
  @override
  Widget build(BuildContext context) {
      return

          ListView(
            children: [
            Card(
              child: ListTile(
                title: Text("1 - Load Current Wallet"),
                trailing: ElevatedButton(
                  onPressed: () {
                    btnLoadWallet(context);
                  },
                  child: Text("Try me!"),
                ),
              )
            ),
            Card(
                child: ListTile(
                  title: Text("2 - New Account"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      btnMakeAccount(context);
                    },
                    child: Text("Try me!"),
                  ),
                )
            ),
            Card(
              child: ListTile(
                title: Text("3 - Change Navigation"),
                trailing: ElevatedButton(
                  onPressed: () {
                    btnChangeNavigation(context);
                  },
                  child: Text("Try me!"),
                ),
              )
            ),
            Card(
              child: ListTile(
                title: Text("4 - Decrypt"),
                trailing: ElevatedButton(
                  onPressed: () async {
                    String content = await global.walletManager.decryptAes();
                    snack(content, context);
                  },
                  child: Text("Try me!"),
                ),
              )
            )
            ],
          );
  }
  btnLoadWallet(BuildContext context) async
  {

    snack("Trying to load...", context);
    File fileP = await global.walletManager.accountFile;
    String content = new File(fileP.path).readAsStringSync();
    Wallet wallet = Wallet.fromJson(content, password);
    // snack(content, context);
    //Check the credentials
    Credentials accessGranted = wallet.privateKey;
    snack(accessGranted.toString(), context);
  }
  btnChangeNavigation(BuildContext context)
  {
    Navigator.pushNamed(context, '/passphrase');
  }
  btnMakeAccount(BuildContext context) async
  {
    String ret = await global.walletManager.makeAccount("abacaxi");
    snack(ret, context);
  }
  // @override
  // void afterFirstLayout(BuildContext context) {
  //   onLoad(context);
  // }
}

class LoginOldState extends State<LoginOld> with AfterLayoutMixin <LoginOld>, Helpers
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(global.appTitle)),
        body: Row(children: [
          // Row(children: [
          //
          //     Column(
          //       children: [
          //         Image.network(
          //           'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
          //           height: 150,
          //           width: 150,
          //         ),
          //         Image.asset('assets/images/supreme_f.png'
          //         ),
          //       ],
          //     ),
          // ],),
          Row(children:[
            Column(
              children: [
                // ElevatedButton(
                //   onPressed: () {
                //     btn1(context);
                //   },
                //   child: Text("btn1"),
                // ),
                //
                // ElevatedButton(
                //   onPressed: () {
                //
                //   },
                //   child: Text("btn2"),
                // ),
                // ElevatedButton(
                //   onPressed: () {
                //     hasPermission(context);
                //   },
                //   child: Text("hasPermission"),
                // ),
                ElevatedButton(
                  onPressed: () {
                    btnMakeAccount(context);
                  },
                  child: Text("Make account."),
                )

              ],
            ),
          ])
      ])
    );

  }
  onLoad(BuildContext context)
  {

  }
  btn1(context)
  {
    snack("botao apertado", context);
  }

  btnMakeAccount(BuildContext context) async
  {
    // Hex ? 
    // Chave privada em hex da account (instancia: wallet...)
    // WalletManager wm = new WalletManager(hash:hex);
    
    // gera new mnemonic
    String hex = await global.walletManager.generateSeed();

    var _rng = new Random.secure();
    // Credentials _random = EthPrivateKey.createRandom(_rng);
    Credentials credentFromHex = EthPrivateKey.fromHex(hex);
    Wallet wallet = Wallet.createNew(credentFromHex,"abacate", _rng);
    String json = wallet.toJson();
    // snack(wallet.toJson(), context);

    // SAVING THE WALLET


    // UNCOMMENT TO SHOW THE PATH
    // File pathString = await wm._localFile;
    // snack(pathString.path, context);

    File path = await global.walletManager.write(json);
    snack("Saved to: "+path.path, context);
  }
  @override
  void afterFirstLayout(BuildContext context) {
    onLoad(context);
  }
}




