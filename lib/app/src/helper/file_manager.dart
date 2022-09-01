import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:avme_wallet/app/src/helper/print.dart';
import 'package:avme_wallet/app/src/helper/enums.dart';
import 'package:path_provider/path_provider.dart';


class FileManager
{
  static final _self = FileManager._internal();
  Completer<bool> structureOk = Completer();

  FileManager._internal (){
    generateStructure();
  }

  factory FileManager() => _self;

  ///Generate folder inside Flutter's documents using
  ///the enum created above
  void generateStructure() async
  {
    Directory documentsFolder = await documents();
    for(AppRootFolder folderName in AppRootFolder.values)
    {
      if(folderName == AppRootFolder.Root)
      {
        continue;
      }
      Directory folder = Directory(documentsFolder.path + "/" + folderName.name + "/");
      if(folder.existsSync())
      {
        continue;
      }
      folder.createSync(recursive: true);
    }
    structureOk = Completer();
    structureOk.complete(true);
  }

  static Future<Directory> documents({AppRootFolder? rootFolder}) async
  {
    Directory documentsFolder = await getApplicationDocumentsDirectory();
    String path = documentsFolder.path + "/";
    if (Platform.isWindows || Platform.isLinux) {
      path +=  "com.avme.wallet";
    }
    if(rootFolder == null) {
      return Directory(path);
    }
    return Directory(path + rootFolder.name);
  }

  static Future<Directory> checkStructure(String path, {bool create = false}) async
  {
    String? completePath = path;
    List<String> folders = [];
    if(completePath == AppRootFolder.Root.name)
    {
      completePath = null;
    }
    else
    {
      folders = completePath.split("/");
    }
    List<String> structureFolders = AppRootFolder.values.asNameMap().keys.toList();
    String validatingPath = (await documents()).path;
    if(completePath != null) {
      for(int i = 0; i < folders.length; i++)
      {
        // Print.error("folders.lenght ${folders.length}");
        // Print.error("folders ${folders}");
        // Print.error("folders content ${folders[0]}");
        // Print.error("complete isEmpty ${completePath.isEmpty}");
        // Print.error("complete content ${completePath}");
        if(folders[i].contains(r'^.*\.[^\\]+$'))
        {
          /// Checking if the folder name has an extension...
          Print.warning("Found filename \"${folders[i]}\"");
          continue;
        }
        if(i == 0 && structureFolders.contains(folders[i]))
        {
          /// Checking if the folder is a structure folder, since we create on
          ///every initialization of the App, is unnecessary to check it
          validatingPath += "/${folders[i]}";
          continue;
        }
        else if (i == 0)
        {
          throw "Error at FileManager: checkSubfolder is invalid, App is trying to create a new structural folder";
        }
        validatingPath += "/${folders[i]}";
        Directory subfolderPath = Directory(validatingPath);
        if(!subfolderPath.existsSync())
        {
          if(create) {
            subfolderPath.createSync(recursive: true);
          }
          else
          {
            throw 'Error at FileManager: Trying to access an non-existing folder';
          }
        }
        Print.mark(validatingPath);
      }
    }
    return Directory(validatingPath);
  }

  static Future<bool> fileExists(String path, String filename) async
  {
    Directory documentsFolder = await documents();
    String completePath = "${documentsFolder.path}/$path/$filename";
    if(path == AppRootFolder.Root.name)
    {
      completePath = "${documentsFolder.path}/$filename";
    }
    File file = File(completePath);
    return await file.exists();
  }

  static Future<bool> writeString(String path, String filename, dynamic object, {bool create = true}) async
  {
    // Print.printWarning("What is this Object?$object");
    // await Future.delayed(Duration(seconds: 2));
    // return false;
    String content = "";
    if(object is! String) {
      content = jsonEncode(object);
    }
    else
    {
      content = object;
    }
    // Print.printMark("Content $content");
    Directory directory = await checkStructure(path, create: create);
    Print.error("Writting: ${directory.absolute.path}");
    File res = File("${directory.path}/$filename");
    // Print.printWarning(res.absolute.path);
    if(await fileExists(path, filename))
    {
      Print.warning("Overwriting \"$filename\" file at \"${res.absolute.path}\"");
    }
    else
    {
      Print.warning("Creating \"$filename\" file at \"${res.absolute.path}\"");
    }
    try
    {
      await res.create();
      res.writeAsStringSync(content);
    }
    catch(e)
    {
      Print.warning(e.toString());
      return false;
    }
    return true;
  }

  static Future<Object> readFile(String path, String filename, {asBytes = false}) async
  {
    Print.warning("Reading file: \"$path/$filename\"");
    Directory directory = await checkStructure(path);
    File res = File(directory.path + "/$filename");
    if(!(await fileExists(path, filename)))
    {
      // throw "Error at FileManager: File \"$fileName\" doesn't exists.";
      return false;
    }
    Uint8List bytes = res.readAsBytesSync();
    if(asBytes)
    {
      Print.approve("Bytes<Uint8>: $bytes");
      return bytes;
    }
    String _data = utf8.decode(bytes, allowMalformed: true);
    try
    {
      return jsonDecode(_data);
    }
    catch(e)
    {
      return _data;
    }
  }

  static Future<bool> removeFile(String path, String filename, {recursive = false}) async
  {
    Directory directory = await checkStructure(path);
    File res = File(directory.path + "/$filename");
    Print.warning("Removing path ${res.absolute.path}");
    if(!(await fileExists(path, filename)))
    {
      throw "Error at FileManager: File \"$filename\" doesn't exists.";
    }
    res.delete(recursive: recursive);
    return true;
  }
}