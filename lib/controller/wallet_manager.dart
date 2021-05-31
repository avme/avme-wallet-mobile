import 'dart:math';
import 'package:avme_wallet/screens/helper.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'dart:io';
import 'package:hex/hex.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web3dart/credentials.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:avme_wallet/controller/globals.dart' as global;
// CREATING FILE ON THE CREATED WALLET
// TODO: refactor this code

// Async because the app will request access to the device...

String url = env["NETWORK"];
// String password = "Banana123";
String mnemonicFile = env["MNEMONICFILEPATH"];

class WalletManager with Helpers
{
  //Our constructor
  // final String hash;
  // WalletManager({this.hash = "default"});

  String ext = ".json";
  String folder = "AVME-Wallet/";
  String filename = "account-";
  int selectedAccount;

  // GET THE DEFAULT PATH
  // Android: /data/user/0/com.avme.avme_wallet/app_flutter
  Future<String> get documentsFolder async
  {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path+"/";
  }
  // // SETTING THE FILE PATH
  // Future<File> get _accountFile async
  // {
  //   final path = await documentsFolder;
  //   return File('$path/$filename$hash$ext');
  // }

  // SETTING THE FILE PATH TO THE ACCOUNT
  Future<File> accountFile ({String position}) async
  {
    String fullPath;

    final path = await documentsFolder;
    final bool exists = await checkPath("$path$folder");
    if(exists)
    {
      if(position == null)
      {
        fullPath = "$path$folder$filename"+"0"+"$ext";
      }
      else
      {
        fullPath = "$path$folder$filename$position$ext";
      }
    }
    return File(fullPath);
  }

  Future<bool> hasPreviousWallet() async
  {
      File file = await accountFile();
      return file.exists();
  }
  // ONLY FOR TESTING PURPOSES
  Future<void> deletePreviousWallet() async
  {
    bool hasFile = await hasPreviousWallet();
    if(hasFile){
      File file = await accountFile();
      file.delete();

      String documentsPath = await documentsFolder;
      File mnemonic = new File(documentsPath + mnemonicFile);
      debugPrint("MEME MONIC: "+mnemonic.path);
      mnemonic.delete();
    }
  }
  // WRITTING DATA
  Future<File> writeWalletJson(String json, {String position}) async
  {
    final file = await accountFile(position: position);
    return file.writeAsString("$json");
  }
  // READING DATA
  Future<String> readWalletJson({position}) async
  {
    try
    {
      // Waits our path to resolve
      final file = await accountFile(position: position);
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
    // else
    // {
    //   debugPrint("DIRECTORY ALREADY EXISTS!" + path);
    // }
    return exists;
  }

  Future<String> decryptAes(String password) async
  {

    String documentsPath = await documentsFolder;
    AesCrypt crypt = AesCrypt();

    // Using the same password to uncrypt the file
    crypt.setPassword(password);
    debugPrint(password);
    return crypt.decryptTextFromFileSync(documentsPath + mnemonicFile, utf16: true);
  }

  Future<String> newMnemonic(String password) async
  {
    // Gera mnemomic
    // String mnemonic =
    //     "blossom skate magnet magic put task famous square because attract clog ketchup";

    // UNCOMMENT THE NEXT LINE TO GENERATE ANOTHER
    String mnemonic = bip39.generateMnemonic();
    print(mnemonic);


    // documents folder:
    String documentsPath = await documentsFolder;

    AesCrypt crypt = AesCrypt();

    // String salt = hexRandBytes();

    // Setting the main Password to encrypt the file, remember to use
    // the same parameter if you're planning to use it again, like uncrypt...
    crypt.setPassword(password);
    debugPrint("AES: "+documentsPath + mnemonicFile);

    // Saving file with the method 'encryptTextToFileSync' from the Lib "aes_crypt"

    crypt.encryptTextToFileSync(mnemonic, documentsPath + mnemonicFile,utf16: true);
    return mnemonic;
  }

  // Future<String> generateSeed(String password) async
  // {
  //   String mnemonic = await newMnemonic(password);
  //   var node = bip32.BIP32.fromSeed(bip39.mnemonicToSeed(mnemonic));
  //   var child = node.derivePath("m/44'/60'/0'/0/0");
  //   String privateKey = HEX.encode(child.privateKey);
  //   // GENERATIONG HEX
  //   // return bip39.mnemonicToSeedHex(preMnemonic);
  //
  //   Client httpClient = new Client();
  //   Web3Client eth = Web3Client(url, httpClient);
  //   // var credentials = await eth.credentialsFromPrivateKey(privateKey);
  //   // print(credentials.extractAddress());
  //
  //   Credentials credentials = await eth.credentialsFromPrivateKey(privateKey);
  //   var pv = await credentials.extractAddress();
  //   print(pv.hex);
  //   return privateKey;
  // }

  Future<List<String>> makeAccount(String password, {position = 0}) async
  {
    // String hex = await generateSeed(password);
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


        // /*Please remove this piece of code...*/
        // Client httpClient = new Client();
        // Web3Client eth = Web3Client(url, httpClient);
        // Credentials credentials = await eth.credentialsFromPrivateKey(privateKey);
        // var pv = await credentials.extractAddress();
        // print(pv.hex);

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

  // Future<String> makeAccount(String password) async
  // {
  //   String hex = await generateSeed(password);
  //   // String palavra = await WalletManager().generateSeedTwo();
  //   // snack(hex,context);
  //   // return '';
  //   // WalletManager wm = new WalletManager(hash:hex);
  //   var _rng = new Random.secure();
  //   // Credentials _random = EthPrivateKey.createRandom(_rng);
  //   Credentials credentFromHex = EthPrivateKey.fromHex(hex);
  //   Wallet _wallet = Wallet.createNew(credentFromHex,password, _rng);
  //   String json = _wallet.toJson();
  //   File path = await writeWalletJson(json);
  //   // created wallet to global scope
  //   global.wallet = _wallet;
  //   return path.path;
  // }

  Future<bool> decryptAesWallet(String password) async
  {
    try
    {
      String documentsPath = await documentsFolder;
      AesCrypt crypt = AesCrypt();

      // Using the same password to uncrypt the file
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

  Future<Map> authenticate(String password) async
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
      //Load the entire wallet
      await loadWalletAccounts(password);
      debugPrint(global.accountList.toString());
      global.wallet = global.accountList[0].account;
      global.eAddress = await global.wallet.privateKey.extractAddress();

      ret["status"] = 200;

      return ret;
    }
    catch(e)
    {
      debugPrint(e.toString());
      ret["message"] = "[Error: 2] "+ret["message"];
      return ret;
    }
  }

  Future<List<String>> getAccounts() async
  {
    List<String> files = [];
    String path = await documentsFolder;
    RegExp regex = new RegExp(r'.aes$', caseSensitive: false, multiLine: false);
    var directoryRes = new Directory("$path$folder");
    await for (var entity in directoryRes.list(recursive: true, followLinks: false))
    {
      if(regex.hasMatch(entity.path)){
        continue;
      }
      files.add(entity.path);
    }
    return files;
  }

  Future<bool> loadWalletAccounts(String password) async
  {
    List<String> accountPathList = await getAccounts();
    int index = 0;
    await Future.forEach(accountPathList, (pathEntity) async {
      print(index.toString()+pathEntity);
      String content = await readWalletJson(position: index.toString());
      debugPrint(content);
      Wallet _wallet = Wallet.fromJson(content, password);
      EthereumAddress _ethAddress = await _wallet.privateKey.extractAddress();
      global.accountList.add(
        global.AccountItem(
          account: _wallet,
          accountPath: pathEntity,
          address: _ethAddress.hex));
      index += 1;
    });

    return true;
  }
}