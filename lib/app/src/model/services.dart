import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:flutter/foundation.dart';

import 'package:avme_wallet/app/src/controller/threads.dart';

class Services extends ChangeNotifier {
  static final Services _self = Services._internal();
  Services._internal();

  factory Services() => _self;

  ///Processes and services in threads
  Map<String, List<ThreadReference>> processList = {};

  /// Adds a threadReference with processID and designated key
  /// Reminder: Any key pair in processList can contain references
  ///of an infinity of processes with the same name, and they won't
  ///repeat the id, example:
  ///
  /// {
  ///   "processVideo": [
  ///     ThreadReference(
  ///       thread = 1;
  ///       processId = 1000;
  ///       ...other properties
  ///     ),
  ///     ThreadReference(
  ///       thread = 2;
  ///       processId = 2000;
  ///       ...other properties
  ///     ),
  ///     ThreadReference(
  ///       thread = 3;
  ///       processId = 87411266;
  ///       ...other properties
  ///     ),
  ///   ]
  /// }
  ///
  static void add(String key, ThreadReference reference)
  {
    if(_self.processList.containsKey(key))
    {
      _self.processList[key]!.add(reference);
    }
    else
    {
      _self.processList[key] = [ reference ];
    }
  }

  ///Removes "Named" process from every thread
  static void remove(String key)
  {
    if(!contains(key))
    {
      throw "Error at Services.remove: Service with name \"$key\" not found";
    }
    Threads threads = Threads();
    List<ThreadReference> removeNamed = _self.processList[key]!;

    for(ThreadReference reference in removeNamed)
    {
      Print.warning("[App.State] Killing process \"$key\" at T#${reference.thread} P#${reference.processId}");
      threads.cancelProcess(reference);
    }
    _self.processList.removeWhere((_key, value) => _key == key);
    Print.error("killIdProcess");
  }

  static bool contains(String key)
  {
    return _self.processList.containsKey(key);
  }
}