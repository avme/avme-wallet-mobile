import 'dart:math';
import 'dart:io';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Utils {
  ///Returns both the key where it was found and the value
  static List queryMap(Map group, String find, {List? keys})
  {
    keys = keys ?? [];
    Print.mark("Querying $group");
    Print.warning("keys: $keys");
    dynamic request;
    for(MapEntry entry in group.entries)
    {
      if(entry.key == find)
      {
        request = entry.value;
        keys.add(entry.key);
        Print.mark("found in group \"${entry.value}\"");
        break;
      }
      else if(entry.value is Map)
      {
        List query = queryMap(entry.value, find, keys: keys);
        if(query[0] != null)
        {
          keys.add(entry.key);
          request = query[0];
        }
      }
    }
    return [request, keys.reversed];
  }

  static int randomRangeInt(int min, int max)
  {
    Random random = Random.secure();
    int num = min + random.nextInt(max - min);
    return num;
  }

  static int lowest(List<int> list)
  {
    return list.reduce(min);
  }

  static int highest(List<int> list)
  {
    return list.reduce(max);
  }

  static String shortReadable(String amount, {int length = 6, bool comma = false})
  {
    try {
      if (double.tryParse(amount) == 0) {
        String ret = "0";
        ret += comma ? "," : ".";
        for (int i = 0; i < length; i++)
          ret += "0";
        return ret;
      }
      int dotIndex = amount.indexOf(".");
      // int maxSize = dotIndex + (length ?? 6);
      int maxSize = dotIndex + length;
      return comma ? amount.substring(0, maxSize).replaceAll(r".", ",") : amount
          .substring(0, maxSize);
    }
    catch(e) {
      if(e is RangeError)
      {
        print("[WARNING -> shortAmount] Error when working with the following data:");
        print("amount $amount, length $length, comma $comma");
      }
      return amount;
    }
  }

  static void shutdown()
  {
    if(Platform.isAndroid)
    {
      SystemNavigator.pop();
    }
    else
    {
      if (Platform.isIOS)
      exit(0);
    }
  }

  static Image resolveImage(String res, {
    double height = 128,
    double width = 128,
    BoxFit fit = BoxFit.contain
  }) {
    double _default = 128;

    if(height != _default)
    {
      width = height;
    }
    else if(width != _default)
    {
      height = width;
    }

    if (res.contains('http'))
    {
      return Image(image: CachedNetworkImageProvider(
        res,
        maxHeight: height.ceil(),
        maxWidth: width.ceil(),
      ), fit: fit, height: height, width: width);
    }
    else if (res.contains('assets/'))
    {
      return Image.asset(res, fit: fit, height: height, width: width);
    }
    else
    {
      return Image.file(File(res), fit: fit, height: height, width: width);
    }
  }

  static bool isHex(String hex)
  {
    RegExp regIsAddress = new RegExp(r"^(0x)[a-zA-Z\d]*$",multiLine: false);
    return regIsAddress.hasMatch(hex);
  }

  static BigInt bigIntFixedPointToWei(String amount, {int decimals = 18})
  {
    return BigInt.tryParse(fixedPointToWei(amount, decimals)) ?? BigInt.zero;
  }

  //Thank Itamar for the snippet
  static String fixedPointToWei(String amount, int decimals) {

    if(double.tryParse(amount) == 0) {
      return amount;
    }

    String digitPadding = "";
    String valuestr = "";
    RegExp validate = new RegExp(r"^[0-9.]*$", caseSensitive: false, multiLine:  false);
    RegExp hasDot = new RegExp(r"\.", caseSensitive: false, multiLine: false);

    if(!hasDot.hasMatch(amount)) {
      amount += ".0";
    }

    // Check if input is valid
    if(!validate.hasMatch(amount))
    {
      return "";
    }

    // Read value from input String
    int index = 0;
    while (index < amount.length && amount[index] != '.') {
      valuestr += amount[index];
      print(amount[index]);
      ++index;
    }

    // Jump fixed point.
    ++index;
    if (amount[index-1] == '.' && (amount.length - (index)) > decimals)
    {
      return "";
    }

    // Check if input precision matches digit precision
    if (index < amount.length) {
      // Read precision point into digitPadding
      while (index < amount.length)
      {
        digitPadding += amount[index];
        ++index;
      }
    }

    // Create padding if there are missing decimals
    while(digitPadding.length < decimals)
    {
      digitPadding += '0';
    }
    valuestr += digitPadding;
    while(valuestr[0] == '0')
      valuestr = valuestr.substring(1);

    if (valuestr == "") valuestr = "0";
    return valuestr;
  }

  //Thank Itamar for the snipet
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

  static bool inTestnet()
  {
    String envTestnet = dotenv.env["TESTNET_MODE"] ?? "FALSE";
    if(envTestnet == "TRUE") { return true; }
    return false;
  }
}