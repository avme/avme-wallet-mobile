import 'package:flutter/material.dart';

abstract class Token extends ChangeNotifier {
  final String name;
  final String symbol;
  final String address;
  final String testAddress;
  final int decimals;
  final String image;
  final String abi;
  final bool active;
  final bool inTestnet;

  BigInt _ether = BigInt.zero;
  double _value = 0;

  BigInt get ether => _ether;
  set ether(BigInt newValue) {
    if(_ether != newValue)
    {
      print("$name| Token.ether from \"$_ether\" to \"$newValue\"");
      _ether = newValue;
      notifyListeners();
    }
  }

  double get value => _value;

  set value(double newValue) {
    if(_value != newValue)
    {
      print("$name| Token.value from \"$_value\" to \"$newValue\"");
      _value = newValue;
      notifyListeners();
    }
  }

  ///Default Constructor
  Token(this.name, this.symbol, this.address, this.testAddress, this.decimals, this.image, this.abi, {this.active = false, this.inTestnet = false});

  ///Obligatory method to avoid repeating definitions
  factory Token.fromMap(Map data) {
    throw UnimplementedError("Token.fromMap called");
  }

  ///When initializing is not obligatory to say if is in Testnet
  ///by default it will be false and return 'contractAddress'.
  ///
  ///'ContractAddress' getter should always be considered first
  ///instead of address or testAddress, this rule only applies
  ///when mounting requests for the network
  String get contractAddress {
    if(!this.inTestnet) { return this.address; }
    return this.testAddress;
  }

  @override
  String toString()
  {
    return "Token("
      "name: "
      "'${this.name}', "
      "symbol: "
      "'${this.symbol}', "
      "address: "
      "'${this.address}', "
      "testAddress: "
      "'${this.testAddress}', "
      "decimals: "
      "'${this.decimals}', "
      "image: "
      "'${this.image}', "
      "abi: "
      "'${this.abi}', "
      "active: "
      "'${this.active}'"
      ")"
    ;
  }
}