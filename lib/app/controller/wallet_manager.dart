import 'dart:convert';
import 'dart:math';
import 'package:avme_wallet/app/controller/services/contract.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/token.dart';
import 'package:avme_wallet/external/contracts/erc20_contract.dart';
import 'package:bip32/bip32.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:flutter/foundation.dart';
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
  final FileManager fileManager;
  WalletManager(this.fileManager);

  Future<File> writeWalletJson(String json) async
  {
    File file = await this.fileManager.accountFile();
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
      final file = await this.fileManager.accountFile();
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
    File file = await this.fileManager.accountFile();
    bool e = await file.exists();
    print("File existis? ${e.toString()}");
    return file.exists();
  }

  // ONLY FOR TESTING PURPOSES
  void deletePreviousWallet() async
  {
    bool hasFile = await walletAlreadyExists();
    if(hasFile){
      File file = await this.fileManager.accountFile();
      file.delete();

      File mnemonic = new File(this.fileManager.documentsFolder + this.fileManager.accountFolder + mnemonicFile);
      print("MNEMONIC FILE PATH: "+mnemonic.path);
      mnemonic.delete();
    }
  }

  Future<String> decryptAes(String password) async
  {
    String documentsPath = this.fileManager.documentsFolder;
    AesCrypt crypt = AesCrypt();

    // Using the same password to uncrypt the file
    crypt.setPassword(password);
    return crypt.decryptTextFromFileSync(documentsPath + this.fileManager.accountFolder + mnemonicFile, utf16: true);
  }

  String newMnemonic()
  {
    // Gera mnemomics
    String mnemonic =
        "blossom skate magnet magic put task famous square because attract clog ketchup";

    // UNCOMMENT THE NEXT LINE TO GENERATE ANOTHER
    // String mnemonic = bip39.generateMnemonic();
    print(mnemonic);

    return mnemonic;
  }

  Future<Map<String,dynamic>> makeAccount(String password, AvmeWallet appState,
    {
      String mnemonic,
      String title = "",
      int slot
    }) async
  {
    print("Is account list empty? ${appState.accountList.isEmpty}");

    if(appState.accountList.isEmpty)
    {
      slot = 0;
      mnemonic = mnemonic ?? newMnemonic();

      String documentsPath = this.fileManager.documentsFolder;

      AesCrypt crypt = AesCrypt();

      // Setting the main Password to encrypt the file, remember to use
      // the same parameter if you're planning to use it again, like uncrypt...
      crypt.setPassword(password);
      // Saving file with the method 'encryptTextToFileSync' from the Lib "aes_crypt"
      await this.fileManager.accountFile();
      crypt.encryptTextToFileSync(mnemonic, documentsPath + this.fileManager.accountFolder + mnemonicFile,utf16: true);
    }
    else
    {
      mnemonic = await decryptAesWallet(password, shouldReturnMnemonicFile: true);
    }

    print(mnemonic);
    BIP32 node = bip32.BIP32.fromSeed(await compute(bip39.mnemonicToSeed,mnemonic));
    Random _rng = new Random.secure();

    if(appState.accountList.keys.length > 9)
    {
      throw Exception("Limit of 9 accounts reached!");
    }

    BIP32 child = node.derivePath("m/44'/60'/0'/0/$slot");
    String privateKey = HEX.encode(child.privateKey);

    Credentials credentFromHex = EthPrivateKey.fromHex(privateKey);
    Wallet _wallet = Wallet.createNew(credentFromHex,password, _rng);

    if(title.length == 0)
    {
      title = "-unnamed $slot-";
    }

    Map accountObject = {
      "slot" : slot,
      "title" : (appState.accountList.isEmpty ? "Default Account" : title),
      "derived" : slot,
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
    String json = this.fileManager.encoder.convert(walletObject);
    await writeWalletJson(json);
    appState.w3dartWallet = _wallet;

    if(appState.accountList.isEmpty)
    {
      appState.changeCurrentWalletId = slot;
      await authenticate(password, appState);
      await restartTokenServices(appState);
    }
    return {"status":200, "message":""};

  }

  Future decryptAesWallet(String password, {bool shouldReturnMnemonicFile = false}) async
  {
    try
    {
      String documentsPath = this.fileManager.documentsFolder;
      AesCrypt crypt = AesCrypt();
      crypt.setPassword(password);
      String ret = crypt.decryptTextFromFileSync(documentsPath + this.fileManager.accountFolder + mnemonicFile, utf16: true);
      return shouldReturnMnemonicFile ? ret : true;
    }
    on AesCryptDataException
    {
      return shouldReturnMnemonicFile ? "" : false;
    }
  }

  Future<Map> authenticate(String password, AvmeWallet appState) async
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
      print("INICIANDO loadWalletAccounts");
      await loadWalletAccounts(password, appState);
      if(appState.accountList[0].walletObj != null)
      {
        appState.w3dartWallet = appState.accountList[0].walletObj;
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

  ///Decrypt accounts in a separated thread
  Future<bool> loadWalletAccounts(String password, AvmeWallet appState) async
  {
    List<dynamic> file = jsonDecode(await readWalletJson());
    return await services.loadWalletAccounts(file,password, appState);
  }

  Future<void> startBalanceSubscription(AvmeWallet appState) async
  {
    if(!appState.services.containsKey("balanceSubscription"))
    {
      bool res = await services.balanceSubscription(appState);
      print("services.balanceSubscription returned: $res");
    }

  }

  void stopBalanceSubscription(AvmeWallet appState)
  {
    if(appState.services.containsKey("balanceSubscription"))
      appState.killService("balanceSubscription");
  }

  Future<void> startValueSubscription(AvmeWallet appState) async
  {
    if(!appState.services.containsKey("valueSubscription"))
      await services.valueSubscription(appState);
  }

  void stopValueSubscription(AvmeWallet appState)
  {
    if(appState.services.containsKey("valueSubscription"))
      appState.killService("valueSubscription");
  }

  Future<Map<String,dynamic>> sendTransaction(AvmeWallet wallet, String address, BigInt amount, tokenId, {List<ValueNotifier> listNotifier}) async
  {
    if (!await services.hasEnoughBalanceToPayTaxes(wallet.currentAccount.networkTokenBalance))
    {
      return {"title" : "Attention", "status": 500, "message": "Not enough AVAX to complete the transaction."};
    }
    wallet.lastTransactionWasSucessful.retrievingData = true;
    String url = await services.sendTransaction(wallet, address, amount, tokenId, listNotifier: listNotifier);
    return {"title": "", "status": 200, "message": url};
  }

  Future<Map<int,List>> previewAvaxBalance(String password) async
  {
    String mnemonic = await decryptAesWallet(password, shouldReturnMnemonicFile: true);
    BIP32 node = bip32.BIP32.fromSeed(await compute(bip39.mnemonicToSeed,mnemonic));
    BIP32 child;
    Credentials credentFromHex;
    Map<int, String> pkeyMap = {};
    for(int slot = 0; slot <= 9; slot++)
    {
      child = node.derivePath("m/44'/60'/0'/0/$slot");
      credentFromHex = EthPrivateKey.fromHex(HEX.encode(child.privateKey));
      pkeyMap[slot] = (await credentFromHex.extractAddress()).toString();
    }
    Map<int,List> data = await services.requestBalanceByAddress(pkeyMap);
    return data;
  }

  Future<void> requestBalanceFromNetwork(AvmeWallet wallet) async
  {
    Map<String,List> contracts = Contracts.getInstance().contracts;
    Map<int,String> pkeys = wallet.accountList.map((key,value) => MapEntry(key, value.address));
    await services.requestBalanceFromNetwork(contracts, pkeys);
  }

  ERC20 signer(String contractAddress, int chainId, ContractAbi abi)
  {
    Client httpClient = Client();
    Web3Client ethClient = Web3Client(url, httpClient);

    EthereumAddress _ethereumAddress = EthereumAddress.fromHex(contractAddress);
    return ERC20(abi, address: _ethereumAddress, client: ethClient, chainId: chainId);
  }

  Future<void> restartTokenServices(AvmeWallet app) async
  {
    stopValueSubscription(app);
    await startValueSubscription(app);
    stopBalanceSubscription(app);
    await startBalanceSubscription(app);
  }

  ///Removes token from appState Queue
  Future<void> removeToken(AvmeWallet app, String tokenName) async
  {
    Token token = app.activeContracts.token;
    token.tokenValues.remove(tokenName);
    await app.activeContracts.removeToken(tokenName);
    await restartTokenServices(app);
  }
}
