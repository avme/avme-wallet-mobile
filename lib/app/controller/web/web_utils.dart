// @dart=2.12
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:avme_wallet/app/lib/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import '../file_manager.dart';

import 'package:image/image.dart' as im;

import '../threads.dart';

class AllowedUrls
{
  FileManager fileManager = FileManager();
  List _hosts = [];
  AllowedUrls()
  {
    Future<File> _f = this.getFile();
    _f.then((File file) async {
      _hosts = jsonDecode(file.readAsStringSync());
    });
  }

  Future<File> getFile() async
  {
    await this.fileManager.getDocumentsFolder();
    String folder = "${this.fileManager.documentsFolder}Browser";
    String path = "$folder/sites.json";
    this.fileManager.checkPath(folder);
    File file = File(path);
    if(!await file.exists())
    {
      await file.writeAsString(this.fileManager.encoder.convert([]));
    }
    return file;
  }

  Future<List> getSites() async{
    if(_hosts.length > 0)
      return _hosts;
    return jsonDecode(await (await this.getFile()).readAsString()) as List;
  }

  Future<int> isAllowed(String origin) async
  {
    int allowed = 0;
    for (List site in await getSites())
    {
      printMark("${site[1]}: ${site[0]} == $origin;");
      if(site[0] == origin && site[1])
      {
        allowed = 1;
      }
      else if(site[0] == origin && !site[1])
      {
        allowed = 2;
      }
    }
    return allowed;
  }

  List allowSite(String origin) {
    List _s = [];
    this.getFile().then((File value) {
      _s = jsonDecode(value.readAsStringSync())
          ?? [];
      printMark("$_s");
      _s.add([origin, true]);
      try
      {
        value.writeAsString(jsonEncode(_s));
      }
      catch(e) {printError("$e");}
    });
    return _s;
  }

  List blockSite(String origin) {
    List _s = [];
    this.getFile().then((File value) {
      _s = jsonDecode(value.readAsStringSync())
          ?? [];
      printMark("$_s");
      _s.remove([origin, true]);
      _s.add([origin, false]);
      try
      {
        value.writeAsString(jsonEncode(_s));
      }
      catch(e) {printError("$e");}
    });
    return _s;
  }
}


class Favorites
{
  FileManager fileManager = FileManager();
  List _sites = [];
  Favorites()
  {
    Future<File> _f = this.getFile();
    _f.then((File file) async {
      _sites = jsonDecode(file.readAsStringSync()) as List;
    });
  }

  Future<File> getFile() async
  {
    await this.fileManager.getDocumentsFolder();
    String folder = "${this.fileManager.documentsFolder}Browser";
    String path = "$folder/favorites.json";
    this.fileManager.checkPath(folder);
    File file = File(path);
    if(!await file.exists())
    {
      await file.writeAsString(this.fileManager.encoder.convert([]));
    }
    return file;
  }

  Future<List> getSites() async{
    if(_sites.length > 0)
      return _sites;
    return jsonDecode(await (await this.getFile()).readAsString()) as List;
  }

  Future<List> add(String title, String url) async{
    List _s = [];
    File file = await this.getFile();
    _s = jsonDecode(file.readAsStringSync()) ?? [];

    Completer imageCompleter = Completer<List>();
    Threads threads = Threads.getInstance();
    ThreadMessage task = ThreadMessage(
      caller: "processImage",
      function: processImage,
      params: [url]
    );
    threads.addToPool(id: 0, task: task)
        .listen((message) async {
      ///In this case, if is a map is requesting something
      if(message is Map)
      {
        if(message.containsKey("responseBytes"))
        {
          Uint8List bodyBytes = message["responseBytes"];
          SendPort port = message["sendPort"];
          ui.Codec codec = await ui.instantiateImageCodec(bodyBytes);
          ui.FrameInfo frameInfo = await codec.getNextFrame();
          ByteData? imageByteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
          if(imageByteData == null)
            throw "FrameInfo.image returned null when converting to byte data";
          printOk("sending back the data");
          await Future.delayed(Duration(seconds: 2));
          port.send(imageByteData.buffer.asUint8List());
        }
      }
      ///Case the message is a List it means the process is finished!
      else if(message is Uint8List)
      {
        imageCompleter.complete(message);
      }
    });
    Uint8List imageBytes = await imageCompleter.future;

    ImageProvider imageProvider = Image.memory(imageBytes).image;
    PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider
    );
    _s.add({
      "title":title,
      "url":url,
      "color": paletteGenerator.dominantColor!.color.value.toString(),
      "ico": base64.encode(imageBytes)
    });
    try
    {
      await file.writeAsString(jsonEncode(_s));
    }
    catch(e) {printError("$e");}
    return _s;
  }

  List remove(String title, String url) {
    List _s = [];
    this.getFile().then((File value) {
      _s = jsonDecode(value.readAsStringSync())
          ?? [];
      _s.removeWhere((element) => element["title"] == title && element["url"] == url);
      printMark("$_s");
      try
      {
        value.writeAsString(jsonEncode(_s));
      }
      catch(e) {printError("$e");}
    });
    return _s;
  }
}


Future<int> processImage(List<dynamic> params, {
  required ThreadData threadData,
  required int id,
  required ThreadMessage threadMessage}) async
{
  Uint8List? byteNew;
  ReceivePort toProcess = ReceivePort();

  String url = params[0];
  String sanitizedUrl = Uri.parse(url)
    .origin.replaceAll("https:\/\/", "")
    .replaceAll("http:\/\/", "")
    .replaceAll("app.", "");

  String imgUrl = "https://icons.duckduckgo.com/ip2/$sanitizedUrl.ico";
  Uri uri = Uri.parse(imgUrl);
  http.Response response = await http.get(uri);
  Completer c = Completer<Uint8List>();

  toProcess.listen((data) {
    if(data is Uint8List) {
      if(!c.isCompleted) c.complete(data);
    }
  });

  threadMessage.payload = {"responseBytes": response.bodyBytes, "sendPort": toProcess.sendPort};
  threadData.sendPort.send(threadMessage);

  byteNew = await c.future;
  if(byteNew == null)
    throw "[T#${threadData.id} P#$id] Uint8List \"byteNew\" cannot be null.";
  toProcess.close();

  im.Image? image = im.decodePng(byteNew);
  if(image == null)
    throw "im.decodePng returned null";
  int lowerY = 0;
  int lowerX = 0;
  int higherY = 0;
  int higherX = 0;
  // String visualizer = "${widget.title} \n\b";
  for(int y = 0; y <= image.height; y++)
  {
    for(int x = 0; x <= image.width; x++)
    {
      // String marker = "";
      double opacity = Color(abgrToArgb(image.getPixelSafe(x, y))).opacity;
      if(opacity > 0)
      {
        ///Checando o maior X
        if((higherX < x) || higherX == 0)
        {
          higherX = x;
          // marker = "2";
        }
        if((higherY < y) || higherY == 0)
        {
          higherY = y;
          // marker = "3";
        }
        ///Checando o menor X
        if(lowerX > x || lowerX == 0) {
          lowerX = x;
          // marker = "0";
        }
        ///Checando o menor Y
        if(lowerY > y || lowerY == 0)
        {
          lowerY = y;
          // marker = "1";
        }
        // if(marker.length == 0)
        //   marker = "X";
        // visualizer += marker;
      }
      // else
      //   visualizer += "-";
      // if(x == image.width)
      //   visualizer += "\n\b";
    }
  }
  printApprove("Dimensions: $lowerX, $lowerY | $higherX, $higherY");
  int width = ((image.width - (image.width - higherX)) - (lowerX - 1)).abs();
  int height = ((image.height - (image.height - higherY)) - (lowerY - 1)).abs();
  printWarning("width: $width, height: $height");
  // printOk(visualizer);

  im.Image interp = im.copyCrop(image, lowerX, lowerY, width, height);
  im.Image crop = im.copyResize(interp, height: 120);

  threadMessage.payload = im.encodePng(crop) as Uint8List;
  threadData.sendPort.send(threadMessage);
  return 1;
}