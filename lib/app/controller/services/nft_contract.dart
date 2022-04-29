import 'dart:async';
import 'dart:convert';

import 'package:avme_wallet/app/controller/database/nfts.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/external/contracts/erc721_full.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class NFTContracts {
  static final NFTContracts _contracts = NFTContracts._internal();

  NFTContracts._internal();

  static NFTContracts getInstance() {
    return _contracts;
  }

  /// This is the simplest/raw list of contracts, used to build widgets
  /// based on the key
  Map<String,Map> contractsRaw = {};

  /// We're using the contract name as key, and a list with its data, as follows
  /// {"AVME": [<ContractAbi>"Contract Abi",<String>"ContractAddress"]}
  Map<String, List> contracts = {};

  final String erc721abi = '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"approved","type":"address"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"operator","type":"address"},{"indexed":false,"internalType":"bool","name":"approved","type":"bool"}],"name":"ApprovalForAll","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"approve","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"getApproved","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"operator","type":"address"}],"name":"isApprovedForAll","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ownerOf","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"bytes","name":"_data","type":"bytes"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"operator","type":"address"},{"internalType":"bool","name":"approved","type":"bool"}],"name":"setApprovalForAll","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"uint256","name":"index","type":"uint256"}],"name":"tokenByIndex","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"uint256","name":"index","type":"uint256"}],"name":"tokenOfOwnerByIndex","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"transferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"_color","type":"string"}],"name":"mint","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes4","name":"interfaceId","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function","constant":true},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"tokenURI","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true}]';

  TableNFT _tableNFT;

  String chainId = dotenv.get('CHAIN_ID');
  
  Future<Map> initialize() async
  {
    // contractsRaw.addEntries([
    //   MapEntry("Color", {
    //     "abi": erc721abi,
    //     "address":'0x190111aE1879aB5d0D7dB31B74Ca64Cd06F5Aad6',
    //     "chainId": '43114',
    //     "symbol": 'COLOR',
    //     "logo":'https://static.wikia.nocookie.net/dont-starve-game/images/c/cb/Glommer.png'
    //   }),
    // ]);
    //
    // contractsRaw.addEntries([
    //   MapEntry("Orakel", {
    //     "abi": erc721abi,
    //     "address":'0x7E15f881882D2D5deb75360099245317F8C3a07E',
    //     "chainId": '43114',
    //     "symbol": 'ORA',
    //     "logo":'https://static.wikia.nocookie.net/lobotomycorp/images/9/97/TheChildofGalaxyPortrait.png'
    //   }),
    // ]);

    _tableNFT = TableNFT.instance;
    List<Map> queryResult = await _tableNFT.savedContracts() as List<Map<String, dynamic>>;
    
    queryResult.forEach((Map column) {
      contractsRaw[column['name']] = {
        "abi" : erc721abi,
        "address" : column['address'],
        "symbol" : column['symbol'],
        "logo" : column["logo"]
      };
    });
    
    contractsRaw.forEach((token, Map map) {
      contracts[token] = [
        mountAbi(map['abi'], token), //ContractAbi
        map['address']
      ];
    });
    return contractsRaw;
  }

  ContractAbi mountAbi(String abi, String name)=> ContractAbi.fromJson(abi, name);

  Future<Map<String,dynamic>> metadata(String url, BigInt id)
  async
  {
    url = url.replaceFirst('ipfs://ipfs/', 'https://ipfs.io/ipfs/');
    String data = await httpGetRequest(url, method: 'GET');
    Map _map = jsonDecode(data);
    _map['tokenId'] = id.toInt();
    _map['imageUrl'] = _map['imageUrl'].replaceFirst('ipfs://ipfs/', 'https://ipfs.io/ipfs/');
    return _map as Map<String, dynamic>;
  }

  Future<Map> addTokenFromAddress({
    String contractAddress,
    String accountAddress,
  }) async {

    String name = "erc721_contract";
    EthereumAddress selectedAccount = await sanitizeAddress(accountAddress);
    http.Client httpClient = http.Client();

    Web3Client web3client = Web3Client(dotenv.get('NETWORK_URL'), httpClient);
    EthereumAddress eAddress = await sanitizeAddress(contractAddress);
    ERC721 nftContract = ERC721(
        mountAbi(erc721abi, name),
        address: eAddress,
        client: web3client,
        chainId: int.parse(chainId)
    );

    ///Token Fields
    BigInt balance = BigInt.zero;
    BigInt totalSupply = BigInt.zero;
    String symbol = "";
    String tokenName = "";
    BigInt testingTokenId = BigInt.from(-1);
    String tokenUri = "";

    Duration timeoutDuration = Duration(seconds: 5);
    try
    {
      ///Symbol check
      Future fSymbol = nftContract.symbol();
      fSymbol.timeout(timeoutDuration, onTimeout: () =>
      throw TimeoutException("Timeout Exception at addTokenFromAddress -> Symbol timeout"));
      symbol = await fSymbol as String;
      print("symbol $symbol");

      ///Balance check
      Future fBalance = nftContract.balanceOf(selectedAccount);
      // Future fBalance = Future.delayed(Duration(seconds: 5), () => erc20Contract.balanceOf(selectedAccount));
      fBalance.timeout(timeoutDuration, onTimeout: () =>
      throw TimeoutException("Timeout Exception at addTokenFromAddress -> Balance timeout"));
      balance = await fBalance as BigInt;
      print("balance $balance");

      ///Total supply
      Future fSupply = nftContract.totalSupply();
      fSupply.timeout(timeoutDuration, onTimeout: () =>
      throw TimeoutException("Timeout Exception at addTokenFromAddress -> Total Supply timeout"));
      totalSupply = await fSupply as BigInt;
      print("Total Supply $totalSupply");

      ///Token Name
      Future fName = nftContract.name();
      fName.timeout(timeoutDuration, onTimeout: () =>
      throw TimeoutException("Timeout Exception at addTokenFromAddress -> Total Token Name timeout"));
      tokenName = await fName as String;
      print("Token Name $tokenName");

      ///NFTListing
      Future ftList = nftContract.tokenByIndex(BigInt.from(0));
      ftList.timeout(timeoutDuration, onTimeout: () =>
        throw TimeoutException("Timeout Exception at addTokenFromAddress -> No token Id was recovered"));
      testingTokenId = (await ftList as BigInt);
      print("First token Id of Contract Address by address $testingTokenId");

      if(testingTokenId == BigInt.from(-1))
        throw Exception("Token ID Exception at addTokenFromAddress -> Token Id cannot be less than zero");

      ///TokenURI
      Future ftUri = nftContract.tokenURI(testingTokenId);
      ftUri.timeout(timeoutDuration, onTimeout: () =>
        throw TimeoutException("Timeout Exception at addTokenFromAddress -> No tokenURI was recovered"));
      tokenUri = (await ftUri as String);
      print("Token Id $testingTokenId's URI: $tokenUri");
      
      ///Acceptable JSON
      Future ftMetadata = metadata(tokenUri, testingTokenId);
      ftMetadata.timeout(Duration(seconds: 30), onTimeout: () =>
        throw TimeoutException("Timeout Exception at addTokenFromAddress -> No image was recovered"));
      Map mdata = await ftMetadata;
      bool validImage = mdata.containsKey("imageUrl");
      if(!validImage)
        throw Exception("Invalid metadata: No valid \"imageUrl\" key in metadata");
      print("Image URL: ${mdata["imageUrl"]}");

    }
    catch(e,s)
    {
      print(e); print(s);
      return {};
    }

    Map<String, String> map = {
      'address' : contractAddress,
      'symbol' : symbol,
      'name' : tokenName,
      'logo' : 'assets/avax_logo.png'
    };

    bool inserted = await _tableNFT.addNFT(map);
    if(!inserted)
    {
      print("Failed to insert");
      return {};
    }
    contractsRaw[tokenName] = {
      'address' : contractAddress,
      'symbol' : symbol,
      'name' : tokenName,
      'logo' : 'assets/avax_logo.png',
    };
    contracts[tokenName] = [
      mountAbi(erc721abi, tokenName),
      contractAddress
    ];

    print("[NFT TESTING DONE]");
    return map;
  }
}