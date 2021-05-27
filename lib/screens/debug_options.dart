import 'dart:io';
import 'package:web3dart/web3dart.dart';
import 'package:avme_wallet/controller/globals.dart' as global;
import 'package:avme_wallet/screens/helper.dart';
import 'package:flutter/material.dart';

final String password = "abacate";

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
                    String content = await global.walletManager.decryptAes("YOUR_PASSWORD_HERE");
                    snack(content, context);
                  },
                  child: Text("Try me!"),
                ),
              )
          ),
          Card(
              child: ListTile(
                title: Text("5 - New Password"),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/registerPassword");
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
    File fileP = await global.walletManager.accountFile();
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
    List<String> ret = await global.walletManager.makeAccount("abacaxi");
    snack(ret, context);
  }
}