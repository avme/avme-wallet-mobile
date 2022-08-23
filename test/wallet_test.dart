import 'package:avme_wallet/app/src/controller/wallet/account.dart';
import 'package:avme_wallet/app/src/controller/wallet/wallet.dart';
import 'package:avme_wallet/app/src/helper/enums.dart';
import 'package:avme_wallet/app/src/helper/file_manager.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io' show Platform;

class WalletTest {
  static void main(String password)
  {
    Account();
    Wallet wallet = Wallet();

    group("Wallet", () {
      test("Initialization Completer", () async {
        bool? init = await wallet.init.future;
        expect(init, isNotNull);
        // Utils.printMark("Authentication.accountExists: ${Authentication.walletExists}");
      });

      test("Creating Wallet if not exists", () async {
        Print.warning("[Password] \"$password\"");
        await Wallet.createWallet(password, Strenght.twelve);
        expect(Wallet.exists, true);
      });

      test("Unlocking file with password", () async {
        bool didAuth = await Wallet.auth(password);
        expect(didAuth, true);
      });

      test("Display the account public key", () async {
        List<AccountData> accounts = Account.accounts;
        // EthereumAddress address = await accounts.first.address;
        String address = accounts.first.address;
        Print.approve("First account's address: \"${address}\"");
        expect(accounts.length, greaterThan(0));
      });

      test("Deriving account from master mnemonic", () async {
        bool didDerive = await Wallet.deriveAccount(password, 1);
        List<AccountData> accounts = Account.accounts;
        for(int i = 0; i < accounts.length; i++)
        {
          // EthereumAddress address = await accounts[i].address;
          String address = accounts[i].address;
          Print.approve("Master | ID #$i Account Address: \"${address}\"");
        }
        expect(didDerive, true);
      });

      test("Deriving account from imported mnemonic", () async {
        bool didDerive = await Wallet.deriveAccount(
          password,
          0,
          title: "Imported from Testing",
          mnemonic: "hat salt toy seed check wise link execute pattern senior eyebrow melody"
        );
        List<AccountData> accounts = Account.accounts;
        // EthereumAddress address = await accounts.last.address;
        String address = accounts.last.address;
        Print.approve("Imported | ID #${accounts.length - 1} Account Address $address");
        expect(didDerive, true);
      });
    });
  }

  static void dispose() {
    bool removeFiles = true;
    if(removeFiles) {
      test("Undoing created files", () async {
        bool didRemoveSecret = await FileManager.removeFile(AppRootFolder.Root.name, 'secret');
        bool didRemoveAccounts = await FileManager.removeFile(AppRootFolder.Accounts.name, 'accounts.json');
        bool didRemoveAll = didRemoveSecret && didRemoveAccounts ? true : false;
        Print.mark("Did remove created files? $didRemoveAll");
        expect(didRemoveAll, true);
      });
    }
  }
}