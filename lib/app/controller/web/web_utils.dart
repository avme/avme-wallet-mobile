
import 'dart:convert';
import 'dart:io';

import 'package:avme_wallet/app/lib/utils.dart';

import '../file_manager.dart';

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
  Map _sites = {};
  Favorites()
  {
    Future<File> _f = this.getFile();
    _f.then((File file) async {
      _sites = jsonDecode(file.readAsStringSync());
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
      await file.writeAsString(this.fileManager.encoder.convert({}));
    }
    return file;
  }

  Future<Map> getSites() async{
    if(_sites.length > 0)
      return _sites;
    return jsonDecode(await (await this.getFile()).readAsString()) as Map;
  }

  Map add(String title, String url) {
    Map _s = {};
    this.getFile().then((File value) {
      _s = jsonDecode(value.readAsStringSync())
          ?? {};
      printMark("$_s");
      _s[title] = url;
      try
      {
        value.writeAsString(jsonEncode(_s));
      }
      catch(e) {printError("$e");}
    });
    return _s;
  }

  Map remove(String title) {
    Map _s = {};
    this.getFile().then((File value) {
      _s = jsonDecode(value.readAsStringSync())
          ?? {};
      printMark("$_s");
      _s.removeWhere((key, value) => key.toString().toUpperCase() == title.toUpperCase());
      try
      {
        value.writeAsString(jsonEncode(_s));
      }
      catch(e) {printError("$e");}
    });
    return _s;
  }
}
