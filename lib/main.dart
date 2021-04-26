//main file of the design, change to cappucino or something else on:
//url: [IMPLEMENT URL]
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:web3dart/web3dart.dart';
import 'package:avme_wallet/Screen/helper.dart';
import 'package:after_layout/after_layout.dart';
import 'package:bip39/bip39.dart' as bip39;

var random = Null;

final String password = "abacate";
void main() {
  runApp(AvmeWallet());
}

class AvmeWallet extends StatelessWidget with Helpers {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: Login(),
      home: Scaffold(
        appBar: AppBar(title: Text("AVME Wallet")),
        body: LoginTwo(),
        // body: Password()
      )
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

class Password extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
        Text("Password Widget",
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),)
    );

  }
}


class LoginTwo extends StatelessWidget with Helpers
{
  @override
  Widget build(BuildContext context) {
      return ListView(
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
                title: Text("2 - New Wallet"),
                trailing: ElevatedButton(
                  onPressed: () {
                    btnMakeWallet(context);
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
          )
        ],
      );
  }
  btnLoadWallet(BuildContext context) async
  {

    snack("Trying to load...", context);
    WalletManager wm = new WalletManager(hash:"futa");
    File fileP = await wm._localFile;
    String content = new File(fileP.path).readAsStringSync();
    Wallet wallet = Wallet.fromJson(content, password);
    // snack(content, context);
    //Check the credentials
    Credentials accessGranted = wallet.privateKey;
    snack(accessGranted.toString(), context);
  }
  btnChangeNavigation(BuildContext context)
  {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => Password()));
  }
  btnMakeWallet(BuildContext context) async
  {
    String hex = await WalletManager().generateSeed();
    // WalletManager wm = new WalletManager(hash:hex);
    WalletManager wm = new WalletManager(hash:"futa");
    var _rng = new Random.secure();
    // Credentials _random = EthPrivateKey.createRandom(_rng);
    Credentials credentFromHex = EthPrivateKey.fromHex(hex);
    Wallet wallet = Wallet.createNew(credentFromHex,password, _rng);
    String json = wallet.toJson();
    // snack(wallet.toJson(), context);

    // SAVING THE WALLET


    // UNCOMMENT TO SHOW THE PATH
    // File pathString = await wm._localFile;
    // snack(pathString.path, context);

    File path = await wm.write(json);
    snack("Saved to: "+path.path, context);
  }
  // @override
  // void afterFirstLayout(BuildContext context) {
  //   onLoad(context);
  // }
}

class LoginState extends State<Login> with AfterLayoutMixin <Login>, Helpers
{

  @override
  Widget build(BuildContext context) {

    return Row(children: [
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
                        btnMakeWallet(context);
                      },
                      child: Text("Make Wallet"),
                    )

                  ],
                ),
              ])
        ]);

  }
  onLoad(BuildContext context)
  {

  }
  btn1(context)
  {
      snack("botao apertado", context);
  }

  btnMakeWallet(BuildContext context) async
  {
      String hex = await WalletManager().generateSeed();
      // WalletManager wm = new WalletManager(hash:hex);
      WalletManager wm = new WalletManager(hash:"futa");
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

      File path = await wm.write(json);
      snack("Saved to: "+path.path, context);
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
  WalletManager({this.hash = ""});

  String ext = ".json";
  String folder = "AVME-Wallet/";
  String filename = "wallet-";


  // GET THE DEFAULT PATH
  // Android: /data/user/0/com.avme.avme_wallet/app_flutter
  Future<String> get _localPath async
  {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }
  // // SETTING THE FILE PATH
  // Future<File> get _localFile async
  // {
  //   final path = await _localPath;
  //   return File('$path/$filename$hash$ext');
  // }

  // SETTING THE FILE PATH
  Future<File> get _localFile async
  {
    final path = await _localPath;
    final bool exists = await checkPath("$path/$folder");
    String fullPath;
    if(exists)
    {
         fullPath = "$path/$folder$filename$hash$ext";
    }
    return File(fullPath);
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
    return null;
  }
  // VALIDATE THE GIVEN PATH, OTHERWISE CREATES THE DIRECTORY
  Future<bool> checkPath(path) async
  {
      bool exists = await Directory(path).exists();
      if(exists.toString() == "false")
      {
          var directory = await Directory(path).create(recursive: true);
          debugPrint("CREATING THE DIRECTORY: " + directory.path);
          exists = true;
      }
      else
      {
          debugPrint("DIRECTORY ALREADY EXISTS!" + path);
      }
      return exists;
  }

  Future<String> generateSeed() async
  {

    String preMnemonic = "cross burst million health capital category salt float velvet clerk version always";

    // UNCOMMENT THE NEXT LINE TO GENERATE ANOTHER
    // var mnemonic = bip39.generateMnemonic();

    // GENERATIONG HEX
    return bip39.mnemonicToSeedHex(preMnemonic);
    // debugPrint(mnemonic);
  }
}

