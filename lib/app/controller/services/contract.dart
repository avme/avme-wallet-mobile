import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';
import 'package:avme_wallet/app/lib/utils.dart';
class Contracts {
  static final Contracts _contracts = Contracts._internal();

  Contracts._internal();

  static Contracts getInstance() {
    return _contracts;
  }

  /// This is the simplest/raw list of contracts, used to build widgets
  /// based on the key
  Map<String,Map<String,String>> contractsRaw = {};

  /// We're using the contract name as key, and a list with its data, as follows
  /// {"AVME": [<ContractAbi>"Contract Abi",<String>"ContractAddress", <String>"ChainID"]}
  Map<String, List> contracts = {};

  final String erc20Abi = '[{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_owner","type":"address"},{"indexed":true,"internalType":"address","name":"_spender","type":"address"},{"indexed":false,"internalType":"uint256","name":"_value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"_from","type":"address"},{"indexed":true,"internalType":"address","name":"_to","type":"address"},{"indexed":false,"internalType":"uint256","name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[{"internalType":"address","name":"_owner","type":"address"},{"internalType":"address","name":"_spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_spender","type":"address"},{"internalType":"uint256","name":"_value","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_to","type":"address"},{"internalType":"uint256","name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_from","type":"address"},{"internalType":"address","name":"_to","type":"address"},{"internalType":"uint256","name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"}]';

  static const String avmeWalletTokenUrl= 'https://raw.githubusercontent.com/avme/avme-wallet-tokenlist/main/tokenlist.json';

  Future<void> initialize(List<String> tokens) async
  {
    contractsRaw.addEntries([
      MapEntry("AVME", {
        "abi":'[{"type":"constructor","stateMutability":"nonpayable","inputs":[]},{"type":"event","name":"Approval","inputs":[{"type":"address","name":"_owner","internalType":"address","indexed":true},{"type":"address","name":"_spender","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Burned","inputs":[{"type":"address","name":"_from","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Minted","inputs":[{"type":"address","name":"_to","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"SwitchedDevfee","inputs":[{"type":"address","name":"_old","internalType":"address","indexed":true},{"type":"address","name":"novo","internalType":"address","indexed":true}],"anonymous":false},{"type":"event","name":"SwitchedMinter","inputs":[{"type":"address","name":"_old","internalType":"address","indexed":true},{"type":"address","name":"novo","internalType":"address","indexed":true}],"anonymous":false},{"type":"event","name":"ToggledDevFee","inputs":[{"type":"bool","name":"_devfeeStatus","internalType":"bool","indexed":false}],"anonymous":false},{"type":"event","name":"Transfer","inputs":[{"type":"address","name":"_from","internalType":"address","indexed":true},{"type":"address","name":"_to","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"function","stateMutability":"view","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"_devFeeEnabled","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"address","name":"","internalType":"address"}],"name":"_dev_fee_address","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"_initialSupply","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"_maxSupply","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"address","name":"","internalType":"address"}],"name":"_minter","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"allowance","inputs":[{"type":"address","name":"_owner","internalType":"address"},{"type":"address","name":"_spender","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"approve","inputs":[{"type":"address","name":"_spender","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"balanceOf","inputs":[{"type":"address","name":"_owner","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"burn","inputs":[{"type":"uint256","name":"_amount","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint8","name":"","internalType":"uint8"}],"name":"decimals","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"mint","inputs":[{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_amount","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"string","name":"","internalType":"string"}],"name":"name","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"switchDevfee","inputs":[{"type":"address","name":"_new_dev_fee_address","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"switchMinter","inputs":[{"type":"address","name":"_newMinter","internalType":"address"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"string","name":"","internalType":"string"}],"name":"symbol","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"toggleDevfee","inputs":[{"type":"bool","name":"_devfeeStatus","internalType":"bool"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"totalSupply","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"transfer","inputs":[{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"transferFrom","inputs":[{"type":"address","name":"_from","internalType":"address"},{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]}]',
        "address":'0x1ecd47ff4d9598f89721a2866bfeb99505a413ed',
        "test-address":'0x02aDedcfe78757C3d0a545CB0Cbd78a7d19eEE4f',
        "decimals":'18',
        // "chainId": '43113',
        "chainId": '43114',
        "symbol": 'AVME',
        "logo":'assets/avme_logo.png'
      }),
      MapEntry("AVME testnet", {
        "abi":'[{"type":"constructor","stateMutability":"nonpayable","inputs":[]},{"type":"event","name":"Approval","inputs":[{"type":"address","name":"_owner","internalType":"address","indexed":true},{"type":"address","name":"_spender","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Burned","inputs":[{"type":"address","name":"_from","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Minted","inputs":[{"type":"address","name":"_to","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"SwitchedDevfee","inputs":[{"type":"address","name":"_old","internalType":"address","indexed":true},{"type":"address","name":"novo","internalType":"address","indexed":true}],"anonymous":false},{"type":"event","name":"SwitchedMinter","inputs":[{"type":"address","name":"_old","internalType":"address","indexed":true},{"type":"address","name":"novo","internalType":"address","indexed":true}],"anonymous":false},{"type":"event","name":"ToggledDevFee","inputs":[{"type":"bool","name":"_devfeeStatus","internalType":"bool","indexed":false}],"anonymous":false},{"type":"event","name":"Transfer","inputs":[{"type":"address","name":"_from","internalType":"address","indexed":true},{"type":"address","name":"_to","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"function","stateMutability":"view","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"_devFeeEnabled","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"address","name":"","internalType":"address"}],"name":"_dev_fee_address","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"_initialSupply","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"_maxSupply","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"address","name":"","internalType":"address"}],"name":"_minter","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"allowance","inputs":[{"type":"address","name":"_owner","internalType":"address"},{"type":"address","name":"_spender","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"approve","inputs":[{"type":"address","name":"_spender","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"balanceOf","inputs":[{"type":"address","name":"_owner","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"burn","inputs":[{"type":"uint256","name":"_amount","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint8","name":"","internalType":"uint8"}],"name":"decimals","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"mint","inputs":[{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_amount","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"string","name":"","internalType":"string"}],"name":"name","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"switchDevfee","inputs":[{"type":"address","name":"_new_dev_fee_address","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"switchMinter","inputs":[{"type":"address","name":"_newMinter","internalType":"address"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"string","name":"","internalType":"string"}],"name":"symbol","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"toggleDevfee","inputs":[{"type":"bool","name":"_devfeeStatus","internalType":"bool"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"totalSupply","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"transfer","inputs":[{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"transferFrom","inputs":[{"type":"address","name":"_from","internalType":"address"},{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]}]',
        "address":'0x5FbDB2315678afecb367f032d93F642f64180aa3',
        // "address":'0x02aDedcfe78757C3d0a545CB0Cbd78a7d19eEE4f',
        "decimals":'18',
        "chainId": '43114',
        "symbol": 'AVME',
        "logo":'assets/avme_logo.png'
      }),
      MapEntry("Local testnet", {
        "abi": erc20Abi,
        "address":'0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
        "decimals":'18',
        "chainId": '43114',
        "symbol": 'ITA',
        "logo":'https://static.wikia.nocookie.net/dont-starve-game/images/c/cb/Glommer.png'
      }),
    ]);

    String response = await httpGetRequest(avmeWalletTokenUrl, method: "GET");
    List avmeWalletTokenList = json.decode(response)["tokens"];
    avmeWalletTokenList.forEach((element) {
      Map data = element;
      contractsRaw[data["name"]] = {
        "abi" : erc20Abi,
        "address" : data["contract-address"],
        "decimals" : data["decimals"].toString(),
        "chainId" : data["chainId"].toString(),
        "symbol" : data["symbol"],
        "logo" : data["logoURI"],
      };
    });
    // contractsRaw.forEach((key, value) => print("$key - ${value["address"]}"));
    tokens.forEach((token) {
      contracts[token] = [
        mountAbi(contractsRaw[token]["abi"], token), //ContractAbi
        contractsRaw[token]["address"],
        contractsRaw[token]["chainId"]
      ];
    });
  }

  bool enableContract(String token)
  {
    try
    {
      contracts[token] = [mountAbi(contractsRaw[token]["abi"], token),contractsRaw[token]["address"],contractsRaw[token]["chainId"]];
    }
    catch(e)
    {
      debugPrint("Error: $e");
      return false;
    }
    return true;
  }

  ContractAbi mountAbi(String abi, String name)=> ContractAbi.fromJson(abi, name);
}