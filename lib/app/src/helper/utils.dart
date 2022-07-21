import 'dart:math';
import 'dart:io';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:flutter/services.dart';

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
}