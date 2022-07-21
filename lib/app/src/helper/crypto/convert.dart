import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Convert {
  static String weiToFixedPoint(String amount, {int digits = 18})
  {
    String result = "";
    if (amount.length <= digits) {
      int valueToPoint = digits - amount.length;
      result += "0.";

      for (int i = 0; i < valueToPoint; ++i) {
        result += "0";
      }
      result += amount;
    }
    else
    {
      result = amount;
      int pointToPlace = result.length - digits;
      result = result.substring(0, pointToPlace) + "." + result.substring(pointToPlace);
    }
    if (result == "") result = "0";
    return result;
  }

  ///Receives an String of hex or an integer to convert it to bigInt
  static BigInt bigIntFromUnit(String hex, {EtherUnit unit = EtherUnit.wei})
  {
    BigInt plainBigInt = hexToInt(hex);
    return EtherAmount.fromUnitAndValue(unit, plainBigInt).getInWei;
  }

  static String bigIntReadable(BigInt bigInt)
  {
    String? data;
    if(bigInt.toDouble() > 0.0)
    {
      data = weiToFixedPoint(bigInt.toString());
    }
    return data ?? "0";
  }

  static String decimalToReadable(String hex, {EtherUnit unit = EtherUnit.wei})
  {
    return bigIntReadable(bigIntFromUnit(hex, unit: unit));
  }
}