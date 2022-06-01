import 'dart:convert';
import 'dart:math';
import 'package:avme_wallet/app/controller/services/contract.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/model/token.dart';
import 'package:avme_wallet/external/contracts/erc20_contract.dart';
import 'package:bip32/bip32.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../packages/services.dart' as services;
import 'package:bip39/src/wordlists/english.dart';

import 'file_manager.dart';

String url = dotenv.get("NETWORK_URL");
String mnemonicFile = dotenv.get("MNEMONICFILEPATH");

class WalletManager {
  final FileManager fileManager;
  WalletManager(this.fileManager);

  Future<File> writeWalletJson(String json, {bool import}) async {
    print('writeWalletJson import: $import');
    File file;
    if (!import) {
      print('import = false');
      // default, creates the folder for a first time initialization or multiple accounts for the default seed
      file = await this.fileManager.accountFile();
      // print("$json");
      await file.writeAsString("$json");
    } else {
      print('import = true');
      // check for accounts1, accounts2, accounts3 ... until finds an empty one.
      // should be Accounts/ImportedAccounts/importedAccount[number].json
      file = await this.fileManager.importedAccountFile();
      print('file $file');
      print('file ${file.toString()}');
      await file.writeAsString("$json");
    }
    print("writeWalletJson has finished");
    return file;
  }

  Future<bool> deleteAccountByName(String name) async {
    print('Deleteing account $name...');
    print('Checking the default accounts.json created from the same seed...');
    bool found = false;
    File file = await this.fileManager.accountFile();
    List contents = jsonDecode(await file.readAsString());
    for (int i = 0; i < contents.length; i++) {
      if (contents[i]['title'] == name) {
        print('Found a match for $name! Deleting...');
        contents.removeAt(i);
        found = true;
      }
    }
    if (found) {
      //Doesn't need to go further, just fix the main accounts.json and ignore imported accounts
      String json = this.fileManager.encoder.convert(contents);
      // String json = jsonEncode(contents);
      await file.writeAsString("$json");
      return true;
    } else {
      print('Not found in main');
      print('Checking the imported accounts from importedAccountX.json created from a different seed...');
      //Has to grab one, check, then move on to the next if false, or delete that one if true
      found = false;
      dynamic _temp;
      for (int i = 0; i < 9; i++) {
        print('Entering loop...');
        _temp = await this.fileManager.readImported(i);
        print('_temp = $_temp');

        //Continue in dart means restarting the for at the next iteration.  Go figure...
        if (_temp == false) continue;

        print('Continuing!');

        contents = jsonDecode(await _temp.readAsString());
        print('contents $contents');
        if (contents.first['title'] == name) {
          print('Found an imported match for $name! Deleting...');
          bool delete = await this.fileManager.deleteImported(i);
          print('delete: $delete');
          if (delete)
            print('Deleted successfully');
          else
            print('Failed to delete imported account');
          found = true;
          break;
        }
      }
      //Continuing after for...
      return found ? true : false;
    }
  }

  ///Added import boolean function when creating accounts, so it can check whether account
  ///is imported or not.  It also makes so when creating a new account from the same seed,
  ///it won't even attempt to check other imported accounts as they shouldn't be of worry
  ///otherwise, leave import to default
  Future<String> readWalletJson({position = -1, bool import = true}) async {
    String content;
    try {
      final file = await this.fileManager.accountFile();
      List contents = jsonDecode(await file.readAsString());

      if (import) {
        List list = await this.fileManager.importedAccountFileRead();
        for (var i = 0; i < list.length; i++) {
          contents.add(list[i][0]);
        }
      }

      content = (position == -1 ? jsonEncode(contents) : jsonEncode(contents[position]["data"]));
    } catch (e) {
      print(e.toString());
    }
    return content;
  }

  Future<bool> walletAlreadyExists() async {
    File file = await this.fileManager.accountFile();
    bool e = await file.exists();
    print("File existis? ${e.toString()}");
    return file.exists();
  }

  // ONLY FOR TESTING PURPOSES
  void deletePreviousWallet() async {
    bool hasFile = await walletAlreadyExists();
    if (hasFile) {
      File file = await this.fileManager.accountFile();
      file.delete();

      File mnemonic = new File(this.fileManager.documentsFolder + this.fileManager.accountFolder + mnemonicFile);
      print("MNEMONIC FILE PATH: " + mnemonic.path);
      mnemonic.delete();
    }
  }

  Future<String> decryptAes(String password) async {
    String documentsPath = this.fileManager.documentsFolder;
    AesCrypt crypt = AesCrypt();

    // Using the same password to uncrypt the file
    crypt.setPassword(password);
    return crypt.decryptTextFromFileSync(documentsPath + this.fileManager.accountFolder + mnemonicFile, utf16: true);
  }

  ///Strength: 12 words = 128 strength, 24 words = 256 strength
  String newMnemonic(int strength) {
    int _strength = strength == 12 ? 128 : 256;

    String mnemonic = bip39.generateMnemonic(strength: _strength);
    for (int i = 0; i < 10; i++) {}

    return mnemonic;
  }

  Future<bool> checkMnemonic({String phrase, int phraseCount}) async {
    ///Validating the phrase
    List<String> phraseWords = phrase.split(' ');

    ///Checking the word count

    if (phraseWords.length != phraseCount) return false;

    ///Checking if the words are in the dictionary
    for (int i = 0; i < phraseWords.length; i++) {
      ///WORDLIST imported from bip39/src/wordlists
      if (!WORDLIST.contains(phraseWords[i])) return false;
    }
    return true;
  }

  Future<Map<String, dynamic>> makeAccount(String password, AvmeWallet appState,
      {String mnemonic, String title = "", int slot, int stregth, bool import = false}) async {
    print("Is account list empty? ${appState.accountList.isEmpty}");

    if (appState.accountList.isEmpty) {
      slot = 0;
      mnemonic = mnemonic ?? newMnemonic(stregth);

      String documentsPath = this.fileManager.documentsFolder;

      AesCrypt crypt = AesCrypt();

      // Setting the main Password to encrypt the file, remember to use
      // the same parameter if you're planning to use it again, like uncrypt...
      crypt.setPassword(password);
      // Saving file with the method 'encryptTextToFileSync' from the Lib "aes_crypt"
      await this.fileManager.accountFile();
      crypt.encryptTextToFileSync(mnemonic, documentsPath + this.fileManager.accountFolder + mnemonicFile, utf16: true);
    } else {
      mnemonic = mnemonic ?? await decryptAesWallet(password, shouldReturnMnemonicFile: true);
    }

    BIP32 node = bip32.BIP32.fromSeed(await compute(bip39.mnemonicToSeed, mnemonic));
    Random _rng = new Random.secure();

    if (appState.accountList.keys.length > 9) {
      throw Exception("Limit of 9 accounts reached!");
    }

    BIP32 child = node.derivePath("m/44'/60'/0'/0/$slot");
    String privateKey = HEX.encode(child.privateKey);

    Credentials credentFromHex = EthPrivateKey.fromHex(privateKey);
    Wallet _wallet = Wallet.createNew(credentFromHex, password, _rng);

    // if (title.length == 0) {
    //   title = "-unnamed $slot-";
    // }

    Map accountObject = {
      "slot": slot,
      "title": (appState.accountList.isEmpty ? "Default Account" : title),
      "derived": slot,
      "data": jsonDecode(_wallet.toJson())
    };

    List walletObject;

    if (appState.accountList.isEmpty || import == true) {
      // if (appState.accountList.isEmpty) {
      walletObject = [accountObject];
    } else {
      walletObject = jsonDecode(await readWalletJson(import: false));
      walletObject.add(accountObject);
    }

    String json = this.fileManager.encoder.convert(walletObject);
    await writeWalletJson(json, import: import);
    appState.w3dartWallet = _wallet;

    if (appState.accountList.isEmpty) {
      await authenticate(password, appState);
      appState.selectedId = slot;
    }
    return {"status": 200, "message": ""};
  }

  Future decryptAesWallet(String password, {bool shouldReturnMnemonicFile = false}) async {
    try {
      String documentsPath = this.fileManager.documentsFolder;
      AesCrypt crypt = AesCrypt();
      crypt.setPassword(password);
      String ret = crypt.decryptTextFromFileSync(documentsPath + this.fileManager.accountFolder + mnemonicFile, utf16: true);
      return shouldReturnMnemonicFile ? ret : true;
    } on AesCryptDataException {
      return shouldReturnMnemonicFile ? "" : false;
    }
  }

  Future<Map> authenticate(String password, AvmeWallet appState, {restart = true}) async {
    Map ret = {"status": 400, "message": "Wrong password."};
    bool mnemonicUnlocked = await decryptAesWallet(password);
    if (!mnemonicUnlocked) {
      ret["message"] = "[Error: 1] " + ret["message"];
      return ret;
    }
    try {
      if (restart) {
        printMark("[Wallet Manager] Starting loadWalletAccounts");
        await loadWalletAccounts(password, appState);
        if (appState.accountList[0].walletObj != null) {
          appState.w3dartWallet = appState.accountList[0].walletObj;
        }
      } else
        printMark("[Wallet Manager] Ignored loadWalletAccounts");
      ret["status"] = 200;
      ret["message"] = "";
      return ret;
    } catch (e) {
      print(e.toString());
      ret["message"] = "[Error: 2] " + ret["message"];
      return ret;
    }
  }

  ///Decrypt accounts in a separated thread
  Future<bool> loadWalletAccounts(String password, AvmeWallet appState) async {
    List<dynamic> file = jsonDecode(await readWalletJson());
    return await services.loadWalletAccounts(file, password, appState);
  }

  Future<void> startBalanceSubscription(AvmeWallet appState) async {
    if (!appState.tProcesses.containsKey("balanceSubscription")) {
      bool res = await services.balanceSubscription(appState);
    }
  }

  void stopBalanceSubscription(AvmeWallet appState) {
    if (appState.tProcesses.containsKey("balanceSubscription")) appState.killIdProcess("balanceSubscription");
  }

  Future<void> startValueSubscription(AvmeWallet appState) async {
    if (!appState.tProcesses.containsKey("valueSubscription")) await services.getValues(appState);
  }

  void stopValueSubscription(AvmeWallet appState) {
    if (appState.tProcesses.containsKey("valueSubscription")) appState.killIdProcess("valueSubscription");
  }

  Future<Map<String, dynamic>> sendTransaction(
    AvmeWallet wallet,
    String address,
    BigInt amount,
    int maxGas,
    BigInt gasPrice,
    String token, {
    List<ValueNotifier> listNotifier,
  }) async {
    print("sendTransaction \n${[wallet, address, amount, token]}");
    bool hasEnough = await services.hasEnoughBalanceToPayTaxes(wallet.currentAccount.networkTokenBalance, amount, gasPrice);
    print("hasEnoughBalanceToPayTaxes? $hasEnough");
    if (!hasEnough) {
      dynamic error = {"title": "Attention", "status": 500, "message": "Not enough AVAX to complete the transaction."};
      print("$error");
      return error;
    }
    wallet.lastTransactionWasSucessful.retrievingData = true;
    String url = await services.sendTransaction(wallet, address, amount, maxGas, gasPrice, token, listNotifier: listNotifier);
    return {"title": "", "status": 200, "message": url};
  }

  /// If previewing from the current account, string = password
  ///
  /// If previewing from another seed, string = mnemonic separated by spaces,
  /// bool mnemonic = true
  Future<Map<int, List>> previewAvaxBalance(String string, {bool mnemonic = false}) async {
    BIP32 node;
    if (mnemonic) {
      node = bip32.BIP32.fromSeed(await compute(bip39.mnemonicToSeed, string));
    } else {
      String mnemonics = await decryptAesWallet(string, shouldReturnMnemonicFile: true);
      node = bip32.BIP32.fromSeed(await compute(bip39.mnemonicToSeed, mnemonics));
    }
    BIP32 child;
    Credentials credentFromHex;
    // Map<int, String> pkeyMap = {};
    List<Map> body = [];
    for (int slot = 0; slot <= 9; slot++) {
      child = node.derivePath("m/44'/60'/0'/0/$slot");
      credentFromHex = EthPrivateKey.fromHex(HEX.encode(child.privateKey));
      // pkeyMap[slot] = (await credentFromHex.extractAddress()).toString();
      String address = (await credentFromHex.extractAddress()).toString();
      body.add({
        "id": slot,
        "jsonrpc": "2.0",
        "method": "eth_getBalance",
        "params": [address, "latest"]
      });
    }

    List result = jsonDecode(await services.executeInNetwork(body));
    Map<int, List> data = {};
    for (dynamic item in result) {
      if (item is Map) {
        if (item.containsKey("result")) {
          BigInt balance = EtherAmount.fromUnitAndValue(EtherUnit.wei, hexToInt(item["result"])).getInWei;
          String convertedBalance = balance.toDouble() != 0 ? weiToFixedPoint(balance.toString()) : "0";
          data[item["id"]] = [
            body[item["id"]]["params"][0],
            shortAmount(convertedBalance, length: 6),
          ];
        }
      }
    }
    return data;
  }

  ERC20 signer(String contractAddress, int chainId, ContractAbi abi) {
    Client httpClient = Client();
    Web3Client ethClient = Web3Client(url, httpClient);

    EthereumAddress _ethereumAddress = EthereumAddress.fromHex(contractAddress);
    return ERC20(abi, address: _ethereumAddress, client: ethClient, chainId: chainId);
  }

  //TODO: When restarting recover the id of the process and shut it
  Future<void> restartTokenServices(AvmeWallet app) async {
    stopValueSubscription(app);
    await startValueSubscription(app);
    stopBalanceSubscription(app);
    await startBalanceSubscription(app);
  }

  ///Removes token from appState Queue
  Future<void> removeToken(AvmeWallet app, String tokenName) async {
    print("REMOVE TOKEN $tokenName");
    Token token = app.activeContracts.token;
    token.removeToken(tokenName);

    ///Removing stored balance from every account
    Map<int, AccountObject> accounts = app.accountList;
    accounts.forEach((key, AccountObject accountObject) {
      accountObject.tokensBalanceList.removeWhere((tokenKey, value) {
        print("tokenKey $tokenKey, tokenName $tokenName");
        return tokenKey == tokenName;
      });
    });

    await app.activeContracts.removeToken(tokenName);
    await restartTokenServices(app);
  }

  Future<void> addNewToken(BuildContext context, String token, {List<ValueNotifier> notifier = const []}) async {
    if (notifier.length > 0) {
      notifier[0].value = 20;
      notifier[1].value = "Requesting data...";
      AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);
      bool abiMounted = await app.activeContracts.sContracts.enableContract(token);
      if (!abiMounted) return;
      notifier[0].value = 60;
      notifier[1].value = "Saving token data...";
      await app.activeContracts.addToken(token);
      notifier[0].value = 90;
      notifier[1].value = "Restarting services...";
      await restartTokenServices(app);
    } else {
      AvmeWallet app = Provider.of<AvmeWallet>(context, listen: false);
      app.activeContracts.sContracts.enableContract(token);
      await app.activeContracts.addToken(token);
      await restartTokenServices(app);
    }

    // app.activeContracts.sContracts.addContract(abi, address, chainId, name, res)
  }

  BigInt calculateTransactionCost(BigInt amount, BigInt gasLimit, BigInt gasPrice) {
    // Amount is in fixed point (10^18 Wei), gas limit is in Wei, gas price is in Gwei (10^9 Wei)
    BigInt totalU256 = amount + (gasLimit * gasPrice);
    printError("totalU256 $totalU256");
    return totalU256;
  }

  Future<EtherAmount> getGasPrice() async {
    Client httpClient = Client();
    Web3Client ethClient = Web3Client(dotenv.get('NETWORK_URL'), httpClient);
    EtherAmount networkGas = await ethClient.getGasPrice();

    ///Adding 20 GWEI as a "safe" to approve the transaction
    BigInt graceGas = BigInt.from((20 * pow(10, 9)));
    return EtherAmount.inWei(networkGas.getInWei + graceGas);
  }
}
