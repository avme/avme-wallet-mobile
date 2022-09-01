import 'package:avme_wallet/app/src/controller/wallet/token/coins.dart';
import 'package:avme_wallet/app/src/controller/wallet/token/token.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

class TokenTest {
  static void main() {
    Coins coins = Coins();
    CoinData coin = CoinData(
      "BANANA",
      "BAN",
      "0x0",
      "",
      18,
      "",
      "",
    );
    group("Token Test", () {
      test("Coins initializer", () async {
        expect(await coins.init.future, true);
      });

      test("Add new Coin Token", () async {
        Print.warning("active initialized? ${coin.active}");
        bool didAdd = await Coins.add(coin);
        expect(didAdd, true);
      });

      test("Remove previously added Coin", () async {
        bool didAdd = await Coins.remove(coin);
        expect(didAdd, true);
      });

      test("Update value of AVME Coin/Token", () async {
        String syb = "AVME";
        double oldValue = Coins.list.where((coin) => coin.name == syb).first.value;
        Coins.updateValue(1, "AVME", 10.0, BigInt.from(10));
        double newValue = Coins.list.where((coin) => coin.name == syb).first.value;
        expect(newValue, greaterThan(oldValue));
      });

      test("Listen to Coin updates", () async {
        Coins().addListener(() {
          Print.mark("[Listen] Coins/Tokens: ${Coins.list.toString()}");
        });
      });
    });
  }
}