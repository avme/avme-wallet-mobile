//main file of the design, change to cappucino or something else on:
//url: [IMPLEMENT URL]
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
      String preMnemonic = "cross burst million health capital category salt float velvet clerk version always";
      // UNCOMMENT THE NEXT LINE TO GENERATE ANOTHER
      // var mnemonic = bip39.generateMnemonic();
      // GENERATIONG HEX

      var _hex = bip39.mnemonicToSeedHex(preMnemonic);
      hex = _hex;
      snack(_hex, context);
      // PRINTING DATA USING SNACKBAR
      // debugPrint(mnemonic);
      // snack(mnemonic.toString(), context);


  }
  btnMakeWallet(BuildContext context)
  async {
      //ALLOCATING WALLET DATA

      // String content = new File("wallet.json").readAsStringSync();
      // Wallet wallet = Wallet.fromJson(content, "test");

      //DESCOMENTAR
      var _rng = new Random.secure();
      // Credentials _random = EthPrivateKey.createRandom(_rng);
      Credentials credentFromHex = EthPrivateKey.fromHex(hex);
      Wallet wallet = Wallet.createNew(credentFromHex,"abacate", _rng);

      snack(wallet.toJson(), context);

      // CREATING FILE ON THE CREATED WALLET
      // todo: refactor this code

      // Async because the app will request access to the device...

      // String path = await WalletManager()._localPath;
      // snack(path, context);
  }
  @override
  void afterFirstLayout(BuildContext context) {
    onLoad(context);
  }
}

// CREATING FILE ON THE CREATED WALLET
// todo: refactor this code

// Async because the app will request access to the device...

class WalletManager
{
    //Our constructor
    final String hash;
    WalletManager({this.hash});

    String ext = ".json";
    String filename = "AVME/wallet-";


    // GET THE DEFAULT PATH
    // Android: /data/user/0/com.avme.avme_wallet/app_flutter
    Future<String> get _localPath async
    {
        final directory = await getApplicationDocumentsDirectory();

        return directory.path;
    }
    // SETTING THE FILE PATH
    Future<File> get _localFile async
    {
        final path = await _localPath;
        return File('$path/$filename$hash$ext');
    }
    // WRITTING DATA
    Future<File> write(String json) async
    {
        final file = await _localFile;
        return file.writeAsString("$json");
    }
    // READING DATA
    Future<String> read() async
    {
        try
        {
            // Waits our path to resolve
            final file = await _localFile;
            // Read file
            String contents = await file.readAsString();

            return contents;
        }
        catch(e)
        {
            debugPrint(e.toString());
        }
    }
}