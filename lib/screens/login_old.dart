import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:avme_wallet/screens/helper.dart';
import 'package:avme_wallet/controller/globals.dart' as global;
import 'package:web3dart/web3dart.dart';

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
    String hex = await global.walletManager.generateSeed('Banana123');

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

    File path = await global.walletManager.writeWalletJson(json);
    snack("Saved to: "+path.path, context);
  }
  @override
  void afterFirstLayout(BuildContext context) {
    onLoad(context);
  }
}