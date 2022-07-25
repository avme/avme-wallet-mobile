import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';

import 'package:avme_wallet/app/src/helper/print.dart';

class Balance {
  final int id; ///ID do Token em Coins.list
  double total = 0.0;
  BigInt raw = BigInt.zero;
  String name = "";
  String address = "";
  String symbol = "";
  int decimals = 0;

  Balance(this.id, [bool copy = false]){
    if(copy) { return; }
    this.name = Coins.list[id].name;
    this.address = Coins.list[id].address;
    this.symbol = Coins.list[id].symbol;
    this.decimals = Coins.list[id].decimals;
  }

  CoinData token (){
    return Coins.list.firstWhere((coin) => coin.name == this.name);
  }

  static from(Balance origin)
  {
    Balance balance = Balance(origin.id, true);
    balance.name = origin.name;
    balance.address = origin.address;
    balance.symbol = origin.symbol;
    balance.decimals = origin.decimals;
    Print.warning("Balance.from ($balance)");
    return balance;
  }

  @override
  String toString()
  {
    return "Balance(id:\"${this.id}\", total:\"${this.total}\", raw:\"${this.raw}\" name:\"${this.name}\", address:\"${this.address}\", symbol:\"${this.symbol}\", decimals:\"${this.decimals}\")";
  }
}

class PlatformBalance{
  double total = 0.0;
  BigInt raw = BigInt.zero;
  String name = "Avalanche";
  String address = "0x0";
  String symbol = "AVAX";
  int decimals = 1;

  @override
  String toString()
  {
    return "PlatformBalance(total:\"${this.total}\", raw:\"${this.raw}\" name:\"${this.name}\", address:\"${this.address}\", symbol:\"${this.symbol}\", decimals:\"${this.decimals}\")";
  }

  Platform token()
  {
    return Coins.platform;
  }
}