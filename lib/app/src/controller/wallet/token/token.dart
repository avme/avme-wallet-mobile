abstract class Token {
  final String name;
  final String symbol;
  final String address;
  final String testAddress;
  final int decimals;
  final String image;
  final String abi;
  final bool active;
  final bool inTestnet;

  BigInt ether = BigInt.zero;
  double value = 0;

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