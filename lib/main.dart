//main file of the design, change to cappucino or something else on:
//url: [IMPLEMENT URL]
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:web3dart/web3dart.dart';
import 'package:avme_wallet/Screen/helper.dart';
import 'package:after_layout/after_layout.dart';
import 'package:bip39/bip39.dart' as bip39;

String hex = "";
var random = Null;
void main() {
  runApp(AvmeWallet());
}

class AvmeWallet extends StatelessWidget with Helpers {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
    );
  }

}

class Login extends StatefulWidget
{
  //Criando estado do nosso widget
  //retorna o State do nosso Login State
  @override
  State<StatefulWidget> createState() => LoginState();

  void onLoad(BuildContext context)
  {
      debugPrint('loaded');
  }
}

class LoginState extends State<Login> with AfterLayoutMixin <Login>, Helpers
{

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("AVME Wallet"),
      ),
      body:
        Column(
          children: [
            ElevatedButton(
              onPressed: () {
                btn1(context);
              },
              child: Text("btn1"),
            ),

            ElevatedButton(
              onPressed: () {
                btn2(context);
              },
              child: Text("btn2"),
            ),
            ElevatedButton(
              onPressed: () {
                btnMakeWallet(context);
              },
              child: Text("Make Wallet"),
            )

          ],
        ),
    );
  }
  onLoad(BuildContext context)
  {
      debugPrint('ANAL');
  }
  btn1(context)
  {
      snack("botao apertado", context);
  }
  btn2(context)
  {
      String pre_mnemonic = "cross burst million health capital category salt float velvet clerk version always";
      // UNCOMMENT THE NEXT LINE TO GENERATE ANOTHER
      // var mnemonic = bip39.generateMnemonic();
      // GENERATIONG HEX

      var _hex = bip39.mnemonicToSeedHex(pre_mnemonic);
      hex = _hex;
      snack(_hex, context);
      // PRINTING DATA USING SNACKBAR
      // debugPrint(mnemonic);
      // snack(mnemonic.toString(), context);


  }
  btnMakeWallet(BuildContext context)
  {
      //ALLOCATING WALLET DATA

      // String content = new File("wallet.json").readAsStringSync();
      // Wallet wallet = Wallet.fromJson(content, "test");

      //DESCOMENTAR
      var _rng = new Random.secure();
      // Credentials _random = EthPrivateKey.createRandom(_rng);
      Credentials credentFromHex = EthPrivateKey.fromHex(hex);
      Wallet wallet = Wallet.createNew(credentFromHex,"abacate", _rng);
      debugPrint(wallet.toJson());
      snack(wallet.toJson(), context);

  }
  @override
  void afterFirstLayout(BuildContext context) {
    onLoad(context);
  }
}

// mixin Helpers {
//   void snack(texto, BuildContext context)
//   {
//     debugPrint('$texto');
//     ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('$texto')));
//   }
// }
