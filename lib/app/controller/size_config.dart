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
  static double smallLabel;
  static double fontSize;
  static double fontSizeSmall;
  static double spanSize;


  void init(BuildContext context){

    //TODO: Implement setting "FontSize" to define between the enum
    //{small, normal, large}

    _mediaQueryData = MediaQuery.of(context);

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    ///Font Size
    // titleSize = safeBlockVertical * 6;
    // labelSize = safeBlockVertical * 4;
    // fontSize = safeBlockVertical * 3;
    // fontSizeSmall = safeBlockVertical * 2.5;
    // spanSize = safeBlockVertical * 2;


    titleSize = safeBlockHorizontal * 7;
    labelSize = safeBlockHorizontal * 6;
    smallLabel = safeBlockHorizontal * 4;
    fontSize = safeBlockHorizontal * 3;
    fontSizeSmall = safeBlockHorizontal * 2.5;
    spanSize = safeBlockHorizontal * 2;
  }
}