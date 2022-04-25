import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';

import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:avme_wallet/external/contracts/erc20_contract.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:http/http.dart' as http;

class Contracts {
  static final Contracts _contracts = Contracts._internal();

  Contracts._internal();

  static Contracts getInstance() {
    return _contracts;
  }

  /// This is the simplest/raw list of contracts, used to build widgets
  /// based on the key
  Map<String, Map> contractsRaw = {};

  /// We're using the contract name as key, and a list with its data, as follows
  /// {"AVME": [<ContractAbi>"Contract Abi",<String>"ContractAddress", <String>"ChainID"]}
  Map<String, List> contracts = {};

  final String erc20Abi =
      '[{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_owner","type":"address"},{"indexed":true,"internalType":"address","name":"_spender","type":"address"},{"indexed":false,"internalType":"uint256","name":"_value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_from","type":"address"},{"indexed":true,"internalType":"address","name":"_to","type":"address"},{"indexed":false,"internalType":"uint256","name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[{"internalType":"address","name":"_owner","type":"address"},{"internalType":"address","name":"_spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_spender","type":"address"},{"internalType":"uint256","name":"_value","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_to","type":"address"},{"internalType":"uint256","name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_from","type":"address"},{"internalType":"address","name":"_to","type":"address"},{"internalType":"uint256","name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"}]';

  static const String avmeWalletTokenUrl = 'https://raw.githubusercontent.com/avme/avme-wallet-tokenlist/main/tokenlist.json';

  Future<void> initialize(List<String> tokens) async {
    contractsRaw.addEntries([
      MapEntry("AVME", {
        "abi":
        '[{"type":"constructor","stateMutability":"nonpayable","inputs":[]},{"type":"event","name":"Approval","inputs":[{"type":"address","name":"_owner","internalType":"address","indexed":true},{"type":"address","name":"_spender","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Burned","inputs":[{"type":"address","name":"_from","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Minted","inputs":[{"type":"address","name":"_to","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"SwitchedDevfee","inputs":[{"type":"address","name":"_old","internalType":"address","indexed":true},{"type":"address","name":"novo","internalType":"address","indexed":true}],"anonymous":false},{"type":"event","name":"SwitchedMinter","inputs":[{"type":"address","name":"_old","internalType":"address","indexed":true},{"type":"address","name":"novo","internalType":"address","indexed":true}],"anonymous":false},{"type":"event","name":"ToggledDevFee","inputs":[{"type":"bool","name":"_devfeeStatus","internalType":"bool","indexed":false}],"anonymous":false},{"type":"event","name":"Transfer","inputs":[{"type":"address","name":"_from","internalType":"address","indexed":true},{"type":"address","name":"_to","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"function","stateMutability":"view","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"_devFeeEnabled","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"address","name":"","internalType":"address"}],"name":"_dev_fee_address","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"_initialSupply","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"_maxSupply","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"address","name":"","internalType":"address"}],"name":"_minter","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"allowance","inputs":[{"type":"address","name":"_owner","internalType":"address"},{"type":"address","name":"_spender","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"approve","inputs":[{"type":"address","name":"_spender","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"balanceOf","inputs":[{"type":"address","name":"_owner","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"burn","inputs":[{"type":"uint256","name":"_amount","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint8","name":"","internalType":"uint8"}],"name":"decimals","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"mint","inputs":[{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_amount","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"string","name":"","internalType":"string"}],"name":"name","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"switchDevfee","inputs":[{"type":"address","name":"_new_dev_fee_address","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"switchMinter","inputs":[{"type":"address","name":"_newMinter","internalType":"address"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"string","name":"","internalType":"string"}],"name":"symbol","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"toggleDevfee","inputs":[{"type":"bool","name":"_devfeeStatus","internalType":"bool"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"totalSupply","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"transfer","inputs":[{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"transferFrom","inputs":[{"type":"address","name":"_from","internalType":"address"},{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]}]',
        "address": '0x1ecd47ff4d9598f89721a2866bfeb99505a413ed',
        "test-address": '0x02aDedcfe78757C3d0a545CB0Cbd78a7d19eEE4f',
        "decimals": '18',
        // "chainId": '43113',
        "chainId": '43114',
        "symbol": 'AVME',
        "logo": 'assets/avme_logo.png'
      }),
      MapEntry("AVME testnet", {
        "abi":
        '[{"type":"constructor","stateMutability":"nonpayable","inputs":[]},{"type":"event","name":"Approval","inputs":[{"type":"address","name":"_owner","internalType":"address","indexed":true},{"type":"address","name":"_spender","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Burned","inputs":[{"type":"address","name":"_from","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Minted","inputs":[{"type":"address","name":"_to","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"SwitchedDevfee","inputs":[{"type":"address","name":"_old","internalType":"address","indexed":true},{"type":"address","name":"novo","internalType":"address","indexed":true}],"anonymous":false},{"type":"event","name":"SwitchedMinter","inputs":[{"type":"address","name":"_old","internalType":"address","indexed":true},{"type":"address","name":"novo","internalType":"address","indexed":true}],"anonymous":false},{"type":"event","name":"ToggledDevFee","inputs":[{"type":"bool","name":"_devfeeStatus","internalType":"bool","indexed":false}],"anonymous":false},{"type":"event","name":"Transfer","inputs":[{"type":"address","name":"_from","internalType":"address","indexed":true},{"type":"address","name":"_to","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"function","stateMutability":"view","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"_devFeeEnabled","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"address","name":"","internalType":"address"}],"name":"_dev_fee_address","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"_initialSupply","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"_maxSupply","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"address","name":"","internalType":"address"}],"name":"_minter","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"allowance","inputs":[{"type":"address","name":"_owner","internalType":"address"},{"type":"address","name":"_spender","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"approve","inputs":[{"type":"address","name":"_spender","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"balanceOf","inputs":[{"type":"address","name":"_owner","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"burn","inputs":[{"type":"uint256","name":"_amount","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint8","name":"","internalType":"uint8"}],"name":"decimals","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"mint","inputs":[{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_amount","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"string","name":"","internalType":"string"}],"name":"name","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"switchDevfee","inputs":[{"type":"address","name":"_new_dev_fee_address","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"switchMinter","inputs":[{"type":"address","name":"_newMinter","internalType":"address"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"string","name":"","internalType":"string"}],"name":"symbol","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"toggleDevfee","inputs":[{"type":"bool","name":"_devfeeStatus","internalType":"bool"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"totalSupply","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"transfer","inputs":[{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"transferFrom","inputs":[{"type":"address","name":"_from","internalType":"address"},{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]}]',
        "address": '0x82A47d986a4c0480e899aA595b59779e3E0840Bc',
        // "address":'0x02aDedcfe78757C3d0a545CB0Cbd78a7d19eEE4f',
        "decimals": '18',
        "chainId": '43114',
        "symbol": 'AVME',
        "logo": 'assets/avme_logo.png'
      }),
      MapEntry("Local testnet", {
        "abi": erc20Abi,
        "address": '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
        "decimals": '18',
        "chainId": '43114',
        "symbol": 'ITA',
        "logo": 'https://static.wikia.nocookie.net/dont-starve-game/images/c/cb/Glommer.png'
      }),
    ]);

    String response = await httpGetRequest(avmeWalletTokenUrl, method: "GET");
    List avmeWalletTokenList = json.decode(response)["tokens"];
    avmeWalletTokenList.forEach((element) {
      Map data = element;
      contractsRaw[data["name"]] = {
        "abi": erc20Abi,
        "address": data["contract-address"],
        "decimals": data["decimals"].toString(),
        "chainId": data["chainId"].toString(),
        "symbol": data["symbol"],
        "logo": data["logoURI"],
      };
    });

    List<String> pendingList = [];

    tokens.forEach((token) {
      if (!contractsRaw.containsKey(token))
        pendingList.add(token);
      else
        contracts[token] = [
          mountAbi(contractsRaw[token]["abi"], token), //ContractAbi
          contractsRaw[token]["address"],
          contractsRaw[token]["chainId"]
        ];
    });

    if (pendingList.length > 0) {
      FileManager fm = FileManager();
      String path = await fm.getDocumentsFolder();
      path = "${path}CustomTokens/";
      bool fileExists = await fm.checkPath(path);
      if (!fileExists)
        throw Exception('Exception at "Contracts.initialize"-> pending ${pendingList.toString()} but the folder "$path" does not exist.');
      path = "${path}tokens.json";

      File file = File(path);
      List customTokens = [];

      if (await file.exists()) {
        customTokens = jsonDecode(await file.readAsString()) as List;
        pendingList.forEach((pending) {
          customTokens.forEach((map) {
            Map entry = map;
            if (entry.containsKey(pending)) {
              contractsRaw[pending] = entry[pending];
              contracts[pending] = [
                mountAbi(contractsRaw[pending]["abi"], pending), //ContractAbi
                contractsRaw[pending]["address"],
                contractsRaw[pending]["chainId"]
              ];
            }
          });
        });
      } else
        throw Exception('Exception at "Contracts.initialize" -> pending ${pendingList.toString()} but the file "$path" does not exist.');
    }
  }

  Future<bool> enableContract(String token) async {
    try {
      if (!contractsRaw.containsKey(token)) {
        FileManager fm = FileManager();
        String path = await fm.getDocumentsFolder();
        path = "${path}CustomTokens/";
        bool fileExists = await fm.checkPath(path);
        if (!fileExists) throw Exception('Exception at "enableContract" -> Path not created "$path"');
        path = "${path}tokens.json";

        File file = File(path);
        List customTokens = [];

        if (await file.exists()) {
          customTokens = jsonDecode(await file.readAsString()) as List;
          customTokens.forEach((map) {
            Map entry = map;
            if (entry.containsKey(token)) contractsRaw[token] = entry[token];
          });
        } else
          throw Exception('Exception at "enableContract" -> No Contract found named "$token"');
      }
      contracts[token] = [mountAbi(contractsRaw[token]["abi"], token), contractsRaw[token]["address"], contractsRaw[token]["chainId"]];
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
    return true;
  }

  ContractAbi mountAbi(String abi, String name) => ContractAbi.fromJson(abi, name);

  Future<List> addTokenFromAddress({
    String contractAddress,
    String accountAddress,
  }) async {
    String name = "erc20_contract";
    int chainId = 43114;
    EthereumAddress selectedAccount = await sanitizeAddress(accountAddress);
    http.Client httpClient = http.Client();

    Web3Client web3client = Web3Client(env['NETWORK_URL'], httpClient);

    ERC20 erc20Contract = ERC20(mountAbi(erc20Abi, name), address: await sanitizeAddress(contractAddress), client: web3client, chainId: chainId);

    ///Token Fields
    BigInt balance = BigInt.zero;
    BigInt totalSupply = BigInt.zero;
    String symbol = "";
    String tokenName = "";
    int decimals = 0;
    Duration timeoutDuration = Duration(seconds: 5);
    try {
      ///Symbol check
      Future fSymbol = erc20Contract.symbol();
      fSymbol.timeout(timeoutDuration, onTimeout: () => throw TimeoutException("Timeout Exception at addTokenFromAddress -> Symbol timeout"));
      symbol = await fSymbol as String;
      print("symbol $symbol");

      ///Balance check
      Future fBalance = erc20Contract.balanceOf(selectedAccount);
      // Future fBalance = Future.delayed(Duration(seconds: 5), () => erc20Contract.balanceOf(selectedAccount));
      fBalance.timeout(timeoutDuration, onTimeout: () => throw TimeoutException("Timeout Exception at addTokenFromAddress -> Balance timeout"));
      balance = await fBalance as BigInt;
      print("balance $balance");

      ///Total supply
      Future fSupply = erc20Contract.totalSupply();
      fSupply.timeout(timeoutDuration, onTimeout: () => throw TimeoutException("Timeout Exception at addTokenFromAddress -> Total Supply timeout"));
      totalSupply = await fSupply as BigInt;
      print("Total Supply $totalSupply");

      ///Token Name
      Future fName = erc20Contract.name();
      fName.timeout(timeoutDuration, onTimeout: () => throw TimeoutException("Timeout Exception at addTokenFromAddress -> Total Token Name timeout"));
      tokenName = await fName as String;
      print("Token Name $tokenName");

      ///Decimals
      Future fDecimals = erc20Contract.decimals();
      fDecimals.timeout(timeoutDuration,
          onTimeout: () => throw TimeoutException("Timeout Exception at addTokenFromAddress -> Total Token Name timeout"));
      decimals = (await fDecimals as BigInt).toInt();
      print("Token Name $decimals");

      // return true;
    } catch (e, s) {
      print(e);
      print(s);
      return [];
    }

    FileManager fm = FileManager();
    String path = await fm.getDocumentsFolder();
    path = "${path}CustomTokens/";
    await fm.checkPath(path);
    String imagePath = "$path$contractAddress.png";
    path = "${path}tokens.json";

    File file = File(path);
    List tokens = [];
    if (await file.exists()) {
      tokens = jsonDecode(await file.readAsString()) as List;
      print(tokens);
    }

    bool contains = false;
    tokens.forEach((element) {
      print(element.keys);
      if (element.containsKey(tokenName)) contains = true;
    });

    Map newToken = {
      "abi": erc20Abi,
      "address": contractAddress,
      "decimals": decimals.toString(),
      "chainId": chainId.toString(),
      "symbol": symbol,
      "logo": imagePath
    };

    if (!contains) {
      tokens.add({tokenName: newToken});

      ///Saving the new Token
      file.writeAsString(fm.encoder.convert(tokens));
    }
    return [tokenName, symbol, contractAddress, decimals];
  }

  Future<bool> saveTokenLogo(Uint8List bytes, String address) async {
    try {
      FileManager fm = FileManager();
      String path = await fm.getDocumentsFolder();

      path = "${path}CustomTokens/";
      await fm.checkPath(path);
      path = "$path$address.png";

      File file = File(path);
      if (await file.exists()) return true;
      file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      print('Exception at "saveTokenLogo": $e');
      return false;
    }
  }
}
