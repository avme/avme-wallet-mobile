import 'dart:io';

import 'package:avme_wallet/app/src/helper/enums.dart';
import 'package:avme_wallet/app/src/helper/file_manager.dart';
import 'package:flutter_test/flutter_test.dart';

class FileManagerTest
{
  static void main()
  {
    FileManager fileManager = FileManager();
    String folder = AppRootFolder.Root.name;
    String filename = 'test.txt';
    String content = 'Lorem ipsum';
    group('FileManager', () {
      test('Is the Documents Directory accessible', () async {
        completion(FileManager.documents());
      });

      test('Can generate structure', () async {
        bool didGenerateStructure = await fileManager.structureOk.future;
        expect(didGenerateStructure, true);
      });

      test('File doesn\'t exists', () async {
        bool notExists = await FileManager.fileExists(folder, filename);
        expect(notExists, false);
      });
      
      test('Can Write file', () async {
        bool canWrite = await FileManager.writeString(folder, filename, content);
        expect(canWrite, true);
      });

      test('Can Read file', () async {
        Object data = await FileManager.readFile(folder, filename);
        if(data is String)
        {
          expect(data, content);
        }
        else
        {
          fail("Data returned from FileManager.readFile is not type of String");
        }
      });

      test('Can Remove file', () async {
        bool canRemove = await FileManager.removeFile(folder, filename);
        expect(canRemove, true);
      });
    });
  }
}
