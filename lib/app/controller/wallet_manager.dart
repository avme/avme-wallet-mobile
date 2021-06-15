import 'dart:math';
import 'package:avme_wallet/app/controller/services/balance.dart';
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
import 'services/account.dart' as accountThread;

import 'file_manager.dart';

String url = env["NETWORK_URL"];
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
    File file = await this._fileManager.accountFile(position: "1");
    bool e = await file.exists();
    print("File existis? ${e.toString()}");
    return file.exists();
  }

  // ONLY FOR TESTING PURPOSES
  void deletePreviousWallet() async
  {
    bool hasFile = await hasPreviousWallet();
    if(hasFile){
      Map<int,String> accounts = await getAccounts();
      accounts.forEach((key, value) async{
        File file = await this._fileManager.accountFile(position: key.toString());
        file.delete();
      });

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

  Future<List<String>> makeAccount(String password, AvmeWallet wallet, AppLoadingState state) async
  {
    List<String> ret = [];
    String mnemonic = await newMnemonic(password);
    BIP32 node = bip32.BIP32.fromSeed(bip39.mnemonicToSeed(mnemonic));
    Random _rng = new Random.secure();

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
        wallet.w3dartWallet = _wallet;
      }
      ret.add(savedPath.path);

    }

    await authenticate(password, wallet, state);

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

  Future<Map> authenticate(String password, AvmeWallet wallet, AppLoadingState state) async
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
      await loadWalletAccounts(password, wallet, state);
      wallet.w3dartWallet = wallet.accountList[0].account;
      wallet.eAddress = await wallet.getW3DartWallet.privateKey.extractAddress();
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

  Future<Map<int, String>> getAccounts() async
  {
    Map<int, String> files = {};
    RegExp regex = new RegExp(r'.aes$', caseSensitive: false, multiLine: false);
    Directory directoryRes = new Directory(this._fileManager.filesFolder());
    int index = 0;
    await for (FileSystemEntity entity in directoryRes.list(recursive: true, followLinks: false))
    {
      if(regex.hasMatch(entity.path)){
        continue;
      }
      files[index] = entity.path;
      index++;
    }
    return files;
  }

  Future<bool> loadWalletAccounts(String password, AvmeWallet wallet, AppLoadingState state) async
  {
    //Priority to account #0 or preferred in options menu
    //TODO: get the last account and set to default
    Map<int, String> accounts = await wallet.walletManager.getAccounts();
    int lastAccount = 0;
    Map<int, String> defaultAccount = {lastAccount:accounts[lastAccount]};
    accounts.remove(lastAccount);
    await accountThread.loadWalletAccounts(defaultAccount,password, wallet, state);
    //Loads all accounts
    await accountThread.loadWalletAccounts(accounts,password, wallet, state);
    return false;
  }

  void getBalance(AvmeWallet wallet)
  {
    updateBalanceService(wallet);
  }

  Future<void> sendTransaction(AvmeWallet wallet) async
  {
    Client httpClient = Client();
    Web3Client ethClient = Web3Client(url, httpClient);
    Transaction _transaction = Transaction(
      to:EthereumAddress.fromHex("0x879bf934cee4d2fe5294cbab1ca9c5703867ccbb"),
      // gasPrice: EtherAmount.inWei(BigInt.one),
      gasPrice: EtherAmount.inWei(BigInt.from(225000000000)),
      maxGas: 210000,
      value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1)
    );

    // await ethClient.sendTransaction(wallet.currentAccount.account.privateKey,_transaction);
    var objSigning = ethClient.signTransaction(wallet.currentAccount.account.privateKey, _transaction, chainId: 43113);

    print(HEX.encode(await objSigning));
    // internalSign()
  }


}
