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

// CREATING FILE ON THE CREATED WALLET
// TODO: refactor this code

// Async because the app will request access to the device...

String url = "https://api.avax-test.network:443/ext/bc/C/rpc";
String password = "Banana123";
String mnemonicFile = "AVME-Wallet/secret.txt.aes";

class WalletManager with Helpers
{
  //Our constructor
  final String hash;

  WalletManager({this.hash = "default"});

  String ext = ".json";
  String folder = "AVME-Wallet/";
  String filename = "wallet-";


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
  Future<File> get accountFile async
  {
    String fullPath;
    final path = await documentsFolder;
    final bool exists = await checkPath("$path$folder");

    if(exists) {
      fullPath = "$path$folder$filename$hash$ext";
    }
    return File(fullPath);
  }

  Future<bool> hasPreviousWallet() async
  {
      File file = await accountFile;
      return file.exists();
  }
  // ONLY FOR TESTING PURPOSES
  Future<void> deletePreviousWallet() async
  {
    bool hasFile = await hasPreviousWallet();
    if(hasFile){
      File file = await accountFile;
      file.delete();

      String documentsPath = await documentsFolder;
      File mnemonic = new File(documentsPath + mnemonicFile);
      debugPrint("MEME MONIC: "+mnemonic.path);
      mnemonic.delete();
    }
  }
  // WRITTING DATA
  Future<File> write(String json) async
  {
    final file = await accountFile;
    return file.writeAsString("$json");
  }
  // READING DATA
  Future<String> read() async
  {
    try
    {
      // Waits our path to resolve
      final file = await accountFile;
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

  Future<String> decryptAes() async
  {
    String documentsPath = await documentsFolder;
    AesCrypt crypt = AesCrypt();

    // Using the same password to uncrypt the file
    crypt.setPassword(password);
    return crypt.decryptTextFromFileSync(documentsPath + mnemonicFile, utf16: true);
  }

  Future<String> newMnemonic() async
  {
    // Gera mnemomic
    String mnemonic =
        "blossom skate magnet magic put task famous square because attract clog ketchup";

    // UNCOMMENT THE NEXT LINE TO GENERATE ANOTHER
    // String mnemonic = bip39.generateMnemonic();
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

  Future<String> generateSeed() async
  {
    String mnemonic = await newMnemonic();
    var node = bip32.BIP32.fromSeed(bip39.mnemonicToSeed(mnemonic));
    var child = node.derivePath("m/44'/60'/0'/0/0");
    String privateKey = HEX.encode(child.privateKey);
    // GENERATIONG HEX
    // return bip39.mnemonicToSeedHex(preMnemonic);

    Client httpClient = new Client();
    Web3Client eth = Web3Client(url, httpClient);
    // var credentials = await eth.credentialsFromPrivateKey(privateKey);
    // print(credentials.extractAddress());

    Credentials credentials = await eth.credentialsFromPrivateKey(privateKey);
    var futagostosa = await credentials.extractAddress();
    print(futagostosa.hex);
    return privateKey;
  }

  Future<String> makeAccount(String password) async
  {
    String hex = await generateSeed();
    // String palavra = await WalletManager().generateSeedTwo();
    // snack(hex,context);
    // return '';
    // WalletManager wm = new WalletManager(hash:hex);
    var _rng = new Random.secure();
    // Credentials _random = EthPrivateKey.createRandom(_rng);
    Credentials credentFromHex = EthPrivateKey.fromHex(hex);
    Wallet wallet = Wallet.createNew(credentFromHex,password, _rng);
    String json = wallet.toJson();
    File path = await write(json);
    return path.path;
  }


  // TODO: change this to verify if the user has been logged and the wallet has been initialised


  bool logged()
  {
    return true;
  }
}