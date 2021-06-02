import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class FileManager
{
  String documentsFolder;
  String ext = ".json";
  String folder = "AVME-Wallet/";
  String filename = "account-";

  // Android: /data/user/0/com.avme.avme_wallet/app_flutter
  // TODO ASAP: FIX THIS FUNCTION, CANNOT BE CALLED IN THREAD
  Future<void> getDocumentsFolder() async
  {
    final directory = await getApplicationDocumentsDirectory();
    documentsFolder = directory.path+"/";
    print(documentsFolder);
  }

  String filesFolder()
  {
    final path = this.documentsFolder;
    return "$path$folder";
  }

  // SETTING THE FILE PATH TO THE ACCOUNT
  Future<File> accountFile ({String position}) async
  {
    String fullPath;

    final bool exists = await checkPath(filesFolder());
    if(exists)
    {
      if(position == null)
      {
        fullPath = filesFolder()+"$filename"+"0"+"$ext";
      }
      else
      {
        fullPath = filesFolder()+"$filename$position$ext";
      }
    }
    return File(fullPath);
  }

  Future<bool> checkPath(path) async
  {
    bool exists = await Directory(path).exists();
    if(exists.toString() == "false")
    {
      Directory dir = await Directory(path).create(recursive: true);
      print("CREATING THE DIRECTORY: " + dir.path);
      exists = true;
    }
    return exists;
  }
}