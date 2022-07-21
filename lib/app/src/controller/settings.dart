import 'dart:async';

import 'package:avme_wallet/app/src/helper/file_manager.dart';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/helper/enums.dart';
import 'package:avme_wallet/app/src/helper/utils.dart';
import 'package:flutter/foundation.dart';

class Settings extends ChangeNotifier {
  static final Settings _self = Settings._internal();

  factory Settings() => _self;

  static const String _file = "settings.json";
  static bool pendingSave = false;

  ///Settings
  Map<String, dynamic> properties = {};
  Completer<bool> init = Completer();


  Settings._internal(){
    _init();
  }

  void _init() async {
    bool exists = await FileManager.fileExists(AppRootFolder.Root.name, _file);
    ///Default values
    if (!exists) {
      properties.addEntries([
        MapEntry("display", {"deviceGroupCustom":"0"}),
        MapEntry("security", {"fingerprint": false}),
      ]);

      await FileManager.writeString(AppRootFolder.Root.name, _file, properties);
    }
    else {
      properties = await FileManager.readFile(AppRootFolder.Root.name, _file) as Map<String, dynamic>;
    }
    init.complete(true);
  }
  
  static dynamic get(String key, {bool includePath = false})
  {
    List? request;
    request = Utils.queryMap(_self.properties, key);
    if(request[0] == null)
    {
      throw "Error at Settings.get: Key \"$key\" not found";
    }
    return includePath ? request : request[0];
  }

  static dynamic set(String key, dynamic value)
  {
    List request = get(key, includePath: true);
    Iterable keys = request[1];
    Map? reference;
    // Print.warning("Keys $keys");
    for(String _key in keys)
    {
      // Print.warning("_key $_key");
      // Print.warning("${_self.properties}");
      // Print.warning("${_self.properties[_key]}");
      if(reference == null)
      {
        reference = _self.properties[_key];
      }
      else
      {
        // Print.warning("$reference = ${reference[_key]};");
        if(_key == key)
        {
          break;
        }
        reference = reference[_key];
      }
      // Print.mark("Reference: $reference");
    }
    if(reference == null)
    {
      throw "Error at Settings.set: Key \"$key\" not found";
    }
    reference[key] = value;
    // Print.mark("properties: ${_self.properties}");
    pendingSave = true;
    return reference;
  }
}