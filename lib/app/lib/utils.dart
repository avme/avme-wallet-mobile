import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void snack(texto, BuildContext context)
{
  print('$texto');
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$texto')));
}

String hexRandBytes({int size = 4}) {
  final rng = Random.secure();
  final bytes = Uint8List(size);
  for (var i = 0; i < size; i++) {
    bytes[i] = rng.nextInt(255);
  }
  return HEX.encode(bytes);
}

String shortAmount(String amount, {int length = 6, bool comma = false})
{
  try {
    if (amount == null || double.tryParse(amount) == 0) {
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

BigInt bigIntFixedPointToWei(String amount, {int decimals = 18})
{
  return BigInt.tryParse(fixedPointToWei(amount, decimals));
}

//Thank Itamar for the snipet

String fixedPointToWei(String amount, int decimals) {

  if(double.tryParse(amount) == 0)
    return amount;

  String digitPadding = "";
  String valuestr = "";

  RegExp hasDot = new RegExp(r"\.", caseSensitive: false, multiLine: false);
  
  if(!hasDot.hasMatch(amount)) amount += ".0";

  RegExp validate = new RegExp(r"^[0-9.]*$", caseSensitive: false, multiLine:  false);

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
  // Check if fixed point exists
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

String weiToFixedPoint(String amount, {int digits = 18})
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

bool isHex(String hex)
{
  RegExp regIsAddress = new RegExp(r"^(0x)[a-zA-Z0-9]*$",multiLine: false);
  return regIsAddress.hasMatch(hex);
}

void closeApp()
{
  if(Platform.isAndroid)
    SystemNavigator.pop();
  else if (Platform.isIOS)
    exit(0);
}

Image resolveImage(String res, {double height, double width})
{
  BoxFit fit = BoxFit.contain;
  return res.contains("http")
    // ? Image.network(res, fit: fit, height: height, width: width,)
    ? Image(image: CachedNetworkImageProvider(
        res,
        maxHeight: 128,
        maxWidth: 128,
      ), fit: fit, height: height, width: width)
    : Image.asset(res, fit: fit, height: height, width: width,);
}

Future<String> httpGetRequest(
    String urlString,
    {
      Map body,
      Map<String,String> headers = const {"Content-Type": "application/json"},
      String method = "POST"
    }) async
{
  Uri url = Uri.parse(urlString);
  http.Response response;
  if(method.toUpperCase() == "POST")
    response = await http.post(url,
        body: json.encode(body),
        headers: headers);
  else if(method.toUpperCase() == "GET")
    response = await http.get(url,
        headers: headers);
  return response.body;
}