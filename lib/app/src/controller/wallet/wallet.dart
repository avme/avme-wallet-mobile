import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:avme_wallet/app/src/controller/network/network.dart';
import 'package:avme_wallet/app/src/controller/wallet/balance.dart';
import 'package:avme_wallet/app/src/helper/crypto/phrase.dart';
import 'package:bip32/bip32.dart';
import 'package:bip39/bip39.dart';
import 'package:flutter/foundation.dart';
import 'package:convert/convert.dart';
import 'package:web3dart/credentials.dart' as web3c;

import 'package:avme_wallet/app/src/helper/enums.dart';
import 'package:avme_wallet/app/src/helper/file_manager.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/controller/wallet/account.dart';

import '../../model/services.dart';

class Wallet
{
  static final Wallet _self = Wallet._internal();
  factory Wallet() => _self;

  static bool exists = false;
  Completer<bool> init = Completer();
  static const String _file = 'secret';
  String? _secretPath;

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

    Account();
    await Account.rawAccounts.future;
    init.complete(true);
    // if(data is bool && data == false)
    // {}
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
    Print.warning("ACCOUNT CREATED");
    Print.warning(Account.accounts.toString());
    return didAddAccount;
  }

  static Future<bool> auth(String password) async
  {
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

  static Future initializeServices(String password) async
  {
    ///Loading accounts into memory!
    Print.warning("Account.accounts.isEmpty ${Account.accounts.isEmpty}");
    if(Account.accounts.isEmpty)
    {
      await Account.load(password);
      AccountData def = Account.accounts.first;
      await def.hasAddress.future;
    }
    if(!Services.contains("observeBalance"))
    {
      Print.warning("Starting service observe balance");
      await Network.observeBalance();
      for(AccountData account in Account.accounts)
      {
        for(Balance balance in account.balance)
        {
          Print.warning("[${balance.symbol}]${balance.name} \$${balance.inCurrency} Token Amount ${balance.qtd}");
        }
      }
    }
    Print.warning("Wallet.auth done");
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
}