import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/credentials.dart';

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

Image resolveImage(String res, {
  double height = 128,
  double width = 128,
  BoxFit fit = BoxFit.contain
}) {
  double _default = 128;

  if(height != _default)
    width = height;
  else if(width != _default)
    height = width;

  if (res.contains('http')){
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
    return Image.file(File(res), fit: fit, height: height, width: width);
}

CachedNetworkImage cachedImage(String res, {
  double height = 128,
  double width = 128,
  BoxFit fit = BoxFit.contain,
  bool ignoreSize = false
}) {
  double _default = 128;
  if(!ignoreSize)
  {
    if(height != _default)
      width = height;
    else if(width != _default)
      height = width;
  }
  else
  {
    width = null;
    height = null;
  }
  return CachedNetworkImage(
    imageUrl: res,
    fit: fit,
    width: width,
    height: height,
    placeholder: (context, url) =>
      Center(
        child: SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            color: AppColors.purple,
            strokeWidth: 6,
          ),
        ),
      ),
    errorWidget: (context, url, error) => Expanded(child: Icon(Icons.error, color: Colors.red,)),
  );
  /*
  return Image(image: CachedNetworkImageProvider(
    res,
    maxHeight: height.ceil(),
    maxWidth: width.ceil(),
  ), fit: fit, height: height, width: width);
  */

}

Future<String> httpGetRequest(
  String urlString,
  {
    dynamic body,
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

Future<EthereumAddress> sanitizeAddress(String hex) async
{
  try {
    EthereumAddress address = await Future.value(EthereumAddress.fromHex(hex));
    return address;
  }
  on ArgumentError catch(e,s)
  {
    print("ArgumentError at sanitizeAddress -> Bad address: $e");
    print(s);
  }
  return null;
}

Future<Uint8List> captureWidget(GlobalKey key) async
{
  if(key == null) return null;
  RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
  final image = await boundary.toImage(pixelRatio: 2);
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  final pngBytes = byteData.buffer.asUint8List();
  return pngBytes;
}

void printOk(String text) {
  print('\x1B[34m$text\x1B[0m');
}

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}

void printApprove(String text)
{
  print('\x1B[32m$text\x1B[0m');
}

void printMark(String text)
{
  print('\x1B[36m$text\x1B[0m');
}


int randomRangeInt(int min, int max)
{
  Random random = Random();
  int num = min + random.nextInt(max - min);
  return num;
}

///Simple wrapper to identify later
Future<Map> wrapAsList({String identifier, Future future, String processName}) async {
  dynamic result = false;
  // print("wrapping $identifier");
  try {
    result = await future;
  } catch (e) {
    if (e is RangeError) {
      print("[WARNING -> wrapAsList | $processName] Balance Subscription failed while processing $identifier, \n at $e");
    }
    return {identifier: "empty"};
  }
  return {identifier: result};
}

int abgrToArgb(int argbColor) {
  int r = (argbColor >> 16) & 0xFF;
  int b = argbColor & 0xFF;
  return (argbColor & 0xFF00FF00) | (b << 16) | r;
}