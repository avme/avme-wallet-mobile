import 'package:flutter/material.dart';

TextStyle alertDialogText()
{
  return TextStyle(
      fontWeight: FontWeight.w500,
      color: Colors.white,
      decoration: TextDecoration.underline,
      // decorationThickness: 1
    // color: Colors.red
  );
}

ThemeData defaultTheme()
{
  TextTheme _defaultTextTheme(TextTheme base)
  {
    // Copies and overwrite as new ThemeData
    return base.copyWith(
      bodyText1: base.headline.copyWith(
        fontSize: 50,
        color: Colors.pinkAccent,
        fontFamily: 'Roboto Mono'
      )
    );
  }
  
  ColorScheme _defaultColorScheme(ColorScheme base)
  {
    return base.copyWith(
      primary: Colors.blueGrey,
      secondaryVariant: Colors.red,
    );
  }

  final ThemeData base = ThemeData.dark();
  return base.copyWith(
    textTheme: _defaultTextTheme(base.textTheme),
    brightness: Brightness.dark,
    // primaryColor: Colors.red,
    // accentColor: Color(0xFF7238AD),
    // accentColor: Color(0xFFFFFFFF),
    colorScheme: _defaultColorScheme(base.colorScheme),
    indicatorColor: Color(0xFF77C2EC),
  );
}