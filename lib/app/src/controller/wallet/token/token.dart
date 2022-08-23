abstract class Token {
  late String name;
  late String symbol;
  late String address;
  late String testAddress;
  late int decimals;
  late String image;
  late String abi;
  late bool active;

  BigInt ether = BigInt.zero;
  double value = 0;

  ///Default Constructor
  Token(this.name, this.symbol, this.address, this.testAddress, this.decimals, this.image, this.abi, {this.active = false});

  ///Obligatory method to avoid repeating definitions
  Token fromMap(Map data);

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