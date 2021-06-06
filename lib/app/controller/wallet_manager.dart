import 'dart:math';
import 'package:avme_wallet/app/model/app.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'dart:io';
import 'package:hex/hex.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:avme_wallet/app/controller/globals.dart' as global;
import 'package:avme_wallet/app/controller/thread.dart' as thread;

import 'file_manager.dart';

String url = env["NETWORK"];
String mnemonicFile = env["MNEMONICFILEPATH"];

class WalletManager
{
  FileManager _fileManager;
  int selectedAccount;

  void setFileManager(FileManager newfileManager) =>
      this._fileManager = newfileManager;

  Future<File> writeWalletJson(String json, {String position}) async
  {
    final file = await this._fileManager.accountFile(position: position);
    return file.writeAsString("$json");
  }

  Future<String> readWalletJson({position}) async
  {
    String contents;
    try
    {
      final file = await this._fileManager.accountFile(position: position);
      contents = await file.readAsString();
    }
    catch(e)
    {
      print(e.toString());
    }
    return contents;
  }

  Future<bool> hasPreviousWallet() async
  {
    File file = await this._fileManager.accountFile();
    return file.exists();
  }

  // ONLY FOR TESTING PURPOSES
  void deletePreviousWallet() async
  {
    bool hasFile = await hasPreviousWallet();
    if(hasFile){
      File file = await this._fileManager.accountFile();
      file.delete();
      File mnemonic = new File(this._fileManager.documentsFolder + mnemonicFile);
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
    return crypt.decryptTextFromFileSync(documentsPath + mnemonicFile, utf16: true);
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
    print("AES: "+documentsPath + mnemonicFile);

    // Saving file with the method 'encryptTextToFileSync' from the Lib "aes_crypt"

    crypt.encryptTextToFileSync(mnemonic, documentsPath + mnemonicFile,utf16: true);
    return mnemonic;
  }

  Future<List<String>> makeAccount(String password, {position = 0}) async
  {
    List<String> ret = [];
    String mnemonic = await newMnemonic(password);
    var node = bip32.BIP32.fromSeed(bip39.mnemonicToSeed(mnemonic));
    var _rng = new Random.secure();

    if(position == 0)
    {
      for(int index = 0; index <= 9; index++)
      {
        var child = node.derivePath("m/44'/60'/0'/0/$index");
        String privateKey = HEX.encode(child.privateKey);

        Credentials credentFromHex = EthPrivateKey.fromHex(privateKey);
        Wallet _wallet = Wallet.createNew(credentFromHex,password, _rng);
        String json = _wallet.toJson();
        File savedPath = await writeWalletJson(json,position: index.toString());
        if(index == 0)
        {
          global.wallet = _wallet;
        }
        ret.add(savedPath.path);
      }
    }

    await authenticate(password);

    return ret;
  }

  Future<bool> decryptAesWallet(String password) async
  {
    try
    {
      String documentsPath = this._fileManager.documentsFolder;
      AesCrypt crypt = AesCrypt();
      crypt.setPassword(password);
      crypt.decryptTextFromFileSync(documentsPath + mnemonicFile, utf16: true);
      return true;
    }
    on AesCryptDataException
    {
      return false;
    }
  }

  bool logged()
  {
    return (global.wallet != null ? true : false);
  }

  Future<Map> authenticate(String password, {AvmeWallet avmeWallet}) async
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
      await loadWalletAccounts(password, avmeWallet);
      global.wallet = global.accountList[0].account;
      global.eAddress = await global.wallet.privateKey.extractAddress();
      ret["status"] = 200;
      return ret;
    }
    catch(e)
    {
      print(e.toString());
      ret["message"] = "[Error: 2] "+ret["message"];
      return ret;
    }
  }

  Future<List<String>> getAccounts() async
  {
    List<String> files = [];
    RegExp regex = new RegExp(r'.aes$', caseSensitive: false, multiLine: false);
    var directoryRes = new Directory(this._fileManager.filesFolder());
    await for (var entity in directoryRes.list(recursive: true, followLinks: false))
    {
      if(regex.hasMatch(entity.path)){
        continue;
      }
      files.add(entity.path);
    }
    return files;
  }

  Future<bool> loadWalletAccounts(String password, AvmeWallet avmeWallet) async
  {
    await thread.loadWalletAccounts(password, global.walletManager, tracker: avmeWallet);
    return false;
  }
}