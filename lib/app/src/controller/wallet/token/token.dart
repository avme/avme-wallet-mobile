abstract class Token {
  final String name;
  final String symbol;
  final String address;
  final String testAddress;
  final int decimals;
  final String image;
  final String abi;
  final bool active;

  BigInt ether = BigInt.zero;
  double value = 0;

  ///Default Constructor
  Token(this.name, this.symbol, this.address, this.testAddress, this.decimals, this.image, this.abi, {this.active = false});

  ///Obligatory method to avoid repeating definitions
  factory Token.fromMap(Map data) {
    throw UnimplementedError("Token.fromMap called");
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