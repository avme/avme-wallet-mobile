import 'dart:convert';
import 'dart:io';

import 'package:avme_wallet/app/controller/file_manager.dart';
import 'package:flutter/widgets.dart';

///Thank Daniele Cambi - @dancamdev from Medium for writing the article!
///src: https://medium.com/flutter-community/flutter-effectively-scale-ui-according-to-different-screen-sizes-2cb7c115ea0a

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  static double titleSize;
  static double labelSize;
  static double labelSizeSmall;
  static double fontSizeHuge;
  static double fontSizeLarge;
  static double fontSize;
  static double fontSizeSmall;
  static double spanSize;

  static String deviceGroup; //Default based on device size
  static List<String> deviceGroups = ["SMALL", "MEDIUM", "LARGE"];

  static final List<int> deviceGroupsSize = [0, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
  //0 = default
  static int deviceGroupCustom = 0;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    ///Discovering device group
    if (blockSizeHorizontal <= 3.5)
      deviceGroup = deviceGroups[0];
    else if (blockSizeHorizontal > 3.5 && blockSizeHorizontal <= 4.40)
      deviceGroup = deviceGroups[1];
    else
      deviceGroup = deviceGroups[2];

    //Get settings.json value
    final FileManager fileManager = FileManager();
    Future<File> settingsFile() async {
      await fileManager.getDocumentsFolder();
      String fileFolder = "${fileManager.documentsFolder}";
      await fileManager.checkPath(fileFolder);
      File file = File("${fileFolder}settings${fileManager.ext}");
      if (!await file.exists()) {
        await file.writeAsString(fileManager.encoder.convert({
          "display": {"deviceGroupCustom": "0"},
          "options": {"fingerprintAuth": false}
        }));
      }
      return file;
    }

    Future<File> fileContacts = settingsFile();
    fileContacts.then((File file) async {
      Map contents = jsonDecode(await file.readAsString());
      Map<String, dynamic> deviceGroupCustomMap = Map<String, dynamic>.from(contents["display"]);
      deviceGroupCustom = int.tryParse(deviceGroupCustomMap["deviceGroupCustom"]);
    });

    double variation = 1.0;

    if (deviceGroupCustom == 0) //default
    {
      ///Default font size, will check for the device's size
      if (deviceGroup == 'MEDIUM') {
        ///Font Size Default/Medium
        variation = 1.0;
      } else if (deviceGroup == 'SMALL') {
        ///Font Size Default/Small
        variation = 0.9;
      } else if (deviceGroup == 'LARGE') {
        ///Font Size Default/Large
        variation = 1.1;
      }
    } else {
      ///This will check for the user's input on size, if the value isn't Default
      variation = deviceGroupCustom / 10;
    }

    titleSize = (safeBlockHorizontal * 7) * variation;
    labelSize = (safeBlockHorizontal * 6) * variation;
    labelSizeSmall = (safeBlockHorizontal * 4) * variation;
    fontSizeHuge = (safeBlockHorizontal * 5) * variation;
    fontSizeLarge = (safeBlockHorizontal * 4) * variation;
    fontSize = (safeBlockHorizontal * 3) * variation;
    fontSizeSmall = (safeBlockHorizontal * 2.5) * variation;
    spanSize = (safeBlockHorizontal * 2) * variation;

    ///This is an example for more specific styling with grouping,
    ///you can use anywhere you want
    // if(deviceGroup == "SMALL")
    // {
    //   titleSize = safeBlockHorizontal * 7;
    //   labelSize = safeBlockHorizontal * 6;
    //   labelSizeSmall = safeBlockHorizontal * 4;
    //   fontSize = safeBlockHorizontal * 3;
    //   fontSizeSmall = safeBlockHorizontal * 2.5;
    //   spanSize = safeBlockHorizontal * 2;
    // }
  }
}
