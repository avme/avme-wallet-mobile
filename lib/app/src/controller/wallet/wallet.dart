import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:avme_wallet/app/src/controller/network/network.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/balance.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:avme_wallet/app/src/helper/crypto/phrase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:bip32/bip32.dart';
import 'package:bip39/bip39.dart';
import 'package:flutter/foundation.dart';
import 'package:convert/convert.dart';
import 'package:web3dart/contracts/erc20.dart';
import 'package:web3dart/web3dart.dart' as web3;

import 'package:web3dart/credentials.dart' as web3c;
import 'package:avme_wallet/app/src/helper/enums.dart';
import 'package:avme_wallet/app/src/helper/file_manager.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/controller/wallet/account.dart';

import 'package:avme_wallet/app/src/model/services.dart';
import 'package:avme_wallet/app/src/controller/ui/popup.dart';

class Wallet
{
  static final Wallet _self = Wallet._internal();
  factory Wallet() => _self;

  static bool exists = false;
  Completer<bool> init = Completer();
  static const String _file = 'secret';
  String? _secretPath;
  String url = dotenv.env["NETWORK_URL"] ?? "https://api.avax.network/ext/bc/C/rpc";
  Wallet._internal() {
    _init();
  }

  void _init () async {
    Object data = await FileManager.readFile(AppRootFolder.Root.name, _file);
    if(data is String)
    {
      exists = true;
    }

    Directory documents = await FileManager.documents();
    _secretPath = "${documents.path}/$_file";

    Account account = Account();
    await account.rawAccounts.future;
    init.complete(true);
  }

  ///Wallet.CreateWallet verifies it self for any the wallet exists
  ///and returns false, this behaviour is to prevent overwriting any
  ///existing accounts, it also
  static Future<bool> createWallet(String password, Strenght str, {String? mnemonic}) async
  {
    if(exists) {
      return false;
    }

    mnemonic = mnemonic ?? PhraseGenerator.generate(str);
    Print.approve("Create Wallet Phrase [$password]: $mnemonic");

    AesCrypt aes = AesCrypt()
      ..setPassword(password);

    String enc = await aes.encryptTextToFile(mnemonic, _self._secretPath!, utf16: true);

    Print.warning("Encrypted: $enc");
    if(enc.isEmpty) {
      throw "Error at Wallet.createWallet: Could not save the secret in \"Wallet.createWallet\"";
    }

    Uint8List seed = await compute(mnemonicToSeed, mnemonic);
    BIP32 node = BIP32.fromSeed(seed);

    Random secure = Random.secure();
    BIP32 derived = node.derivePath("m/44'/60'/0'/0/0");
    String accountPrivateKey = hex.encode(derived.privateKey!.toList());

    web3c.EthPrivateKey web3Credentials = web3c.EthPrivateKey.fromHex(accountPrivateKey);
    web3c.Wallet wallet = web3c.Wallet.createNew(web3Credentials, password, secure);

    Map entry = {
      "slot": 0,
      "title": "Default Account",
      "derived": 0,
      "data": jsonDecode(wallet.toJson())
    };

    bool didAddAccount = await Account.add(entry, wallet);

    if(didAddAccount)
    {
      exists = true;
    }

    return didAddAccount;
  }

  static Future<bool> auth(String password) async
  {
    print("password \"$password\"");
    print("args \"${[password, _self._secretPath!]}\"");
    String? secret = await compute(_computeValidate, [password, _self._secretPath!]);
    print("secret: $secret");
    if(secret == null) {
      return false;
    }

    ///Initiate other processes
    ///...

    await initializeServices(password);
    return true;
  }

  static Future<bool> initializeServices(String password) async
  {
    ///Loading accounts into memory!
    Account account = Account();
    Print.warning("Account.accounts.isEmpty ${account.accounts.isEmpty}");
    if(account.accounts.isEmpty)
    {
      await Account.load(password);
      AccountData def = account.accounts.first;
      await def.hasAddress.future;
      Print.mark("address: ${def.address}");
    }

    if(!Services.contains("observeBalance"))
    {
      Print.warning("Starting service observe balance");
      await Network.observeBalance();
      for(AccountData account in account.accounts)
      {
        for(BalanceInfo balance in account.balance)
        {
          Print.warning("[${balance.symbol}]${balance.name} \$${balance.inCurrency} Token Amount ${balance.qtd}");
        }
      }
    }
    Print.warning("Wallet.auth done");
    return true;
  }

  ///Args:
  ///0:<String> password
  ///1:<String> path

  static Future<String?> _computeValidate(List args) async
  {
    String? ret;
    try
    {
      AesCrypt aes = AesCrypt()
        ..setPassword(args[0]);
      ret = await aes.decryptTextFromFile(args[1], utf16: true);
    }
    catch(e){ return null; }
    return ret;
  }

  static Future<bool> deriveAccount(String password, int index, {String? title, String? mnemonic}) async
  {
    if(!Wallet.exists)
    {
      throw "Error at Wallet.deriveAccount: Trying to derive without an Wallet";
    }
    String? master = await compute(_computeValidate,[password, _self._secretPath!]);
    BIP32 node = await compute(_computeUnlockMnemonicFromFile, [mnemonic ?? master]);

    Random secure = Random.secure();
    BIP32 derived = node.derivePath("m/44'/60'/0'/0/$index");

    String accountPrivateKey = hex.encode(derived.privateKey!.toList());

    web3c.EthPrivateKey web3Credentials = web3c.EthPrivateKey.fromHex(accountPrivateKey);
    web3c.Wallet wallet = web3c.Wallet.createNew(web3Credentials, password, secure);
    Map entry = {
      "slot": index,
      "title": title ?? "Derived $index",
      "derived": index,
      "data": jsonDecode(wallet.toJson())
    };

    bool didAddAccount = await Account.add(entry, wallet);

    return didAddAccount;
  }

  static Future<BIP32> _computeUnlockMnemonicFromFile(List args) async
  {
    String secret = args[0];
    ///Checking if a mnemonic was passed
    if (PhraseGenerator.isValid(secret) == false) {
      throw '''
Error at Wallet -> _computeUnlockMnemonicFromFile: Invalid mnemonic
Details:
String secret = $secret;
int secret.length = ${secret.length}''';
    }
    Uint8List seed = mnemonicToSeed(secret);
    return BIP32.fromSeed(seed);
  }

  static Future<String> makeTransaction(String receiver, String token, BigInt amount, int maxGas, BigInt bigIntGasPrice) async
  {
    /*
    ProgressDialog progress = ProgressPopup.display();
    for(double i = 0; i < 100; i++)
    {
      Random random = Random();
      int index = random.nextInt(WORDLIST.length - 1);
      progress.percentage.value = i;
      progress.label.value = WORDLIST[index];
      await Future.delayed(Duration(milliseconds: 40));
    }
    ProgressPopup.dismiss();
    */

    // ProgressDialog progress = await ProgressPopup.display();
    // progress.percentage.value = 10;
    // progress.label.value = "futabu";
    // await Future.delayed(Duration(seconds: 1));
    // progress.percentage.value = 100;
    // progress.label.value = "anal sex";
    // await Future.delayed(Duration(seconds: 2));
    // ProgressPopup.dismiss();

    ProgressDialog progress = await ProgressPopup.display();
    Client httpClient = Client();
    web3.Web3Client ethClient = web3.Web3Client(_self.url, httpClient);

    /*OLD CODE*/

    web3.EtherAmount gasPrice = web3.EtherAmount.inWei(bigIntGasPrice);

    // Map<String, List> contracts = Contracts.getInstance().contracts;
    // List<CoinData> contracts = Coins.list;
    AccountData currentAccount = Account.current();
    web3c.Credentials accountCredentials = currentAccount.data.privateKey;
    CoinData contract = Coins.list.firstWhere((coinData) => coinData.symbol == token) as CoinData;
    web3.Transaction transaction = web3.Transaction(
      to: web3c.EthereumAddress.fromHex(receiver),
      maxGas: maxGas,
      gasPrice: gasPrice,
      value: web3.EtherAmount.inWei(amount),
    );

    progress.percentage.value = 40;
    progress.label.value = "Signing Transaction";

    String? transactionHash;
    web3.Web3Client? transactionClient;
    if (token == dotenv.env["PLATFORM_SYMBOL"]) {
      Print.mark("AVAX - MAINNET");

      ///Get the chainId
      // int chainId = (await ethClient.getChainId()).toInt();
      int chainId = int.tryParse(dotenv.get("CHAIN_ID")) ?? 43114;
      Print.mark("MEU CHAIN ID $chainId");
      // web3c.Credentials accountCredentials = appState.currentAccount.walletObj.privateKey;
      Uint8List signedTransaction = await ethClient.signTransaction(
        accountCredentials,
        transaction,
        chainId: chainId,
      );

      progress.percentage.value = 60;
      progress.label.value = "Sending Transaction";

      Print.mark("[signedTransaction]\b\n $signedTransaction");
      transactionHash = await ethClient.sendRawTransaction(signedTransaction);
      Print.mark("[transactionHash] $transactionHash");

      transactionClient = ethClient;
    } else {
      // if going to uncomment this, fix maxGas to be widget's parameter
      web3.Transaction transaction = web3.Transaction(maxGas: 70000, gasPrice: gasPrice);
      web3c.EthereumAddress contractAddress = web3c.EthereumAddress.fromHex(contract.contractAddress);
      int chainId = int.tryParse(dotenv.get("CHAIN_ID")) ?? 43114;

      Erc20 erc20 = Erc20(
        address: contractAddress,
        client: ethClient,
        chainId: chainId
      );

      progress.percentage.value = 60;
      progress.label.value = "Sending Transaction";

      try {
        transactionHash = await erc20.transfer(
          web3c.EthereumAddress.fromHex(receiver),
          amount, credentials: accountCredentials, transaction: transaction
        );

        print("[transactionHash]$transactionHash");
        transactionClient = erc20.client;
      } catch (e) {
        print(e);
      }

      // transactionHash =
      //     await contract.transfer(EthereumAddress.fromHex(receiverAddress), amount, credentials: accountCredentials, transaction: transaction);
      // print("[transactionHash]$transactionHash");
      // transactionClient = contract.client;
    }
    print(transactionHash);

    progress.percentage.value = 90;
    progress.label.value = "Confirming Transaction";

    int secondsPassed = 0;
    while (true) {
      try {
        await Future.delayed(Duration(seconds: 1));
        web3.TransactionReceipt? transactionReceipt = await transactionClient?.getTransactionReceipt(transactionHash!);
        print("[info] Receipt: $transactionReceipt");
        if (transactionReceipt != null) {
          if(transactionReceipt.status != null) {
            web3.TransactionInformation transactionInformation = await transactionClient!
              .getTransactionByHash(transactionHash!);
            print("[Info] seconds passed: $secondsPassed, and returned $transactionInformation");
            //TODO: Implement transactions history
            // if (transactionInformation != null) {
            //   appState.lastTransactionWasSucessful
            //       .setLastTransactionInformation(
            //       transactionInformation, tokenValue: web3.EtherAmount.inWei(amount),
            //       to: receiverAddress,
            //       tokenName: token);
            //   appState.lastTransactionWasSucessful.writeTransaction();
            //   break;
            // }
            break;
          }
        }
      } catch (e) {
        print("ERROR $e");
      }
    }
    progress.percentage.value = 100;
    progress.label.value = "Done";
    ProgressPopup.dismiss();
    return "https://snowtrace.io/tx/$transactionHash";

    /*END OLD CODE*/
  }
}