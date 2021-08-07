import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:bip32/bip32.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'dart:io';
import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../packages/services.dart' as services;

import 'file_manager.dart';

String url = env["NETWORK_URL"];
String mnemonicFile = env["MNEMONICFILEPATH"];

class WalletManager
{
  FileManager _fileManager;
  int selectedAccount;

  void setFileManager(FileManager newfileManager) =>
      this._fileManager = newfileManager;

  Future<File> writeWalletJson(String json) async
  {
    final File file = await this._fileManager.accountFile();
    // print("$json");
    await file.writeAsString("$json");
    print("writeWalletJson has finished");
    return file;
  }

  Future<String> readWalletJson({position = -1}) async
  {
    String content;
    try
    {
      final file = await this._fileManager.accountFile();
      List contents = jsonDecode(await file.readAsString());
      content = (position == -1 ? jsonEncode(contents) : jsonEncode(contents[position]["data"]));
    }
    catch(e)
    {
      print(e.toString());
    }
    return content;
  }

  Future<bool> walletAlreadyExists() async
  {
    File file = await this._fileManager.accountFile();
    bool e = await file.exists();
    print("File existis? ${e.toString()}");
    return file.exists();
  }

  // ONLY FOR TESTING PURPOSES
  void deletePreviousWallet() async
  {
    bool hasFile = await walletAlreadyExists();
    if(hasFile){
      File file = await this._fileManager.accountFile();
      file.delete();

      File mnemonic = new File(this._fileManager.documentsFolder + this._fileManager.accountFolder + mnemonicFile);
      print("MEME MONIC: "+mnemonic.path);
      mnemonic.delete();
    }
  }

  Future<String> decryptAes(String password) async
  {
    String documentsPath = this._fileManager.documentsFolder;
    AesCrypt crypt = AesCrypt();

    // Using the same password to uncrypt the file
    crypt.setPassword(password);
    return crypt.decryptTextFromFileSync(documentsPath + this._fileManager.accountFolder + mnemonicFile, utf16: true);
  }

  Future<String> newMnemonic(String password) async
  {
    // Gera mnemomic
    String mnemonic =
        "blossom skate magnet magic put task famous square because attract clog ketchup";

    // UNCOMMENT THE NEXT LINE TO GENERATE ANOTHER
    // String mnemonic = bip39.generateMnemonic();
    print(mnemonic);


    // documents folder:
    String documentsPath = this._fileManager.documentsFolder;

    AesCrypt crypt = AesCrypt();

    // String salt = hexRandBytes();

    // Setting the main Password to encrypt the file, remember to use
    // the same parameter if you're planning to use it again, like uncrypt...
    crypt.setPassword(password);
    print("AES: "+documentsPath + this._fileManager.accountFolder + mnemonicFile);

    // Saving file with the method 'encryptTextToFileSync' from the Lib "aes_crypt"

    crypt.encryptTextToFileSync(mnemonic, documentsPath + this._fileManager.accountFolder + mnemonicFile,utf16: true);
    return mnemonic;
  }

  Future<List<String>> makeAccount(String password, AvmeWallet appState, {String title = ""}) async
  {
    // print("password?");
    // print(password);
    // await Future.delayed(Duration(seconds: 10));
    // return [];
    List<String> ret = [];
    String mnemonic;
    if(appState.accountList.isEmpty)
    {
      mnemonic = await newMnemonic(password);
    }
    else
    {
      mnemonic = await decryptAesWallet(password, shouldReturnMnemonicFile: true);
    }

    print(mnemonic);
    BIP32 node = bip32.BIP32.fromSeed(bip39.mnemonicToSeed(mnemonic));
    Random _rng = new Random.secure();
    JsonEncoder encoder = JsonEncoder.withIndent('  ');

    int slot = appState.accountList.keys.length;

    if(slot > 9)
    {
      throw Exception("Limit of 9 accounts reached!");
    }

    BIP32 child = node.derivePath("m/44'/60'/0'/0/$slot");
    String privateKey = HEX.encode(child.privateKey);

    Credentials credentFromHex = EthPrivateKey.fromHex(privateKey);
    Wallet _wallet = Wallet.createNew(credentFromHex,password, _rng);

    Map accountObject = {
      "slot" : slot,
      "title" : (appState.accountList.isEmpty ? "Default Account" : title),
      "derived" : slot,
      "token" : "",
      "data" : jsonDecode(_wallet.toJson())
    };

    List walletObject;

    if(appState.accountList.isEmpty)
    {
      walletObject = [accountObject];
    }
    else
    {
      walletObject = jsonDecode(await readWalletJson());
      walletObject.add(accountObject);
    }
    String json = encoder.convert(walletObject);
    File savedPath = await writeWalletJson(json);
    appState.w3dartWallet = _wallet;
    ret.add(savedPath.path);
    print("chamando auth do makeaccount");
    Map auth = await authenticate(password, appState);
    print("auth?${jsonEncode(auth)}");
    // print("auth? no");
    return ret;
  }

  Future<dynamic> decryptAesWallet(String password, {bool shouldReturnMnemonicFile = false}) async
  {
    try
    {
      String documentsPath = this._fileManager.documentsFolder;
      AesCrypt crypt = AesCrypt();
      crypt.setPassword(password);
      String ret = crypt.decryptTextFromFileSync(documentsPath + this._fileManager.accountFolder + mnemonicFile, utf16: true);
      return shouldReturnMnemonicFile ? ret : true;
    }
    on AesCryptDataException
    {
      return shouldReturnMnemonicFile ? "" : false;
    }
  }

  Future<Map> authenticate(String password, AvmeWallet wallet) async
  {
    Map ret = {"status":400,"message":"Wrong password."};
    bool mnemonicUnlocked = await decryptAesWallet(password);
    if (!mnemonicUnlocked)
    {
      ret["message"] = "[Error: 1] "+ret["message"];
      return ret;
    }
    try
    {
      print("TENTANDO LOADAR WALLET ACC");
      await loadWalletAccounts(password, wallet);
      if(wallet.accountList[0].account != null)
      {
        wallet.w3dartWallet = wallet.accountList[0].account;
        wallet.eAddress = await wallet.getW3DartWallet.privateKey.extractAddress();

      }
      ret["status"] = 200;
      ret["message"] = "";
      return ret;
    }
    catch(e)
    {
      print(e.toString());
      ret["message"] = "[Error: 2] "+ret["message"];
      return ret;
    }
  }

  // Future<Map<int, String>> getAccounts() async
  // {
  //   Map<int, String> files = {};
  //   RegExp regex = new RegExp(r'.aes$', caseSensitive: false, multiLine: false);
  //   Directory directoryRes = new Directory(this._fileManager.filesFolder());
  //   int index = 0;
  //   await for (FileSystemEntity entity in directoryRes.list(recursive: true, followLinks: false))
  //   {
  //     if(regex.hasMatch(entity.path)){
  //       continue;
  //     }
  //     files[index] = entity.path;
  //     index++;
  //   }
  //   return files;
  // }

  // Future<bool> loadWalletAccounts(String password, AvmeWallet appState) async
  // {
  //   //Priority to account #0 or preferred in options menu
  //   //TODO: get the last account and set to default
  //   Map<int, String> accounts = await appState.walletManager.getAccounts();
  //   int lastAccount = 0;
  //   Map<int, String> defaultAccount = {lastAccount:accounts[lastAccount]};
  //   print(defaultAccount);
  //   accounts.remove(lastAccount);
  //
  //   await services.loadWalletAccounts(defaultAccount,password, appState);
  //   //Loads all the accounts
  //   await services.loadWalletAccounts(accounts,password, appState);
  //   return false;
  // }

  Future<bool> loadWalletAccounts(String password, AvmeWallet appState) async
  {
    List<dynamic> file = jsonDecode(await readWalletJson());
    print("THIS IS THE FILE ${jsonEncode(file)}");
    return await services.loadWalletAccounts(file,password, appState);
  }

  void getBalance(AvmeWallet wallet)
  {
    if (!wallet.services.containsKey("${wallet.currentAccount}#watchBalanceChanges")) {
      services.updateBalanceService(wallet);
    }
  }

  void getBalanceToAllAccounts(AvmeWallet wallet)
  {
    wallet.accountList.keys.forEach((key) {
      if(!wallet.services.containsKey("$key#watchBalanceChanges"))
      {
        services.updateBalanceService(wallet,
          accountData: {
            "slot" : key,
            "updateIn" : 30,
            "address" : EthereumAddress.fromHex(wallet.accountList[key].address),
          }
        );
      }
    });
  }

  Future<Map<String,dynamic>> sendTransaction(AvmeWallet wallet, String address, BigInt amount) async
  {
    if (!await services.hasEnoughBalanceToPayTaxes(wallet.currentAccount.waiBalance))
    {
      return {"title" : "Attention", "status": 500, "message": "Not enough AVAX to complete the transaction."};
    }
    wallet.lastTransactionWasSucessful.retrievingData = true;
    services.sendTransaction(wallet, address, amount);
    return {"title": "", "status": 200, "message": ""};
  }
}
