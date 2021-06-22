import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Color primaryColor = Color(0xFF258CF3);
const Color secondaryColor = Color(0xFF7238AD);
const Color accentColor = Color(0xFF7238AD);
const Color blue1 =  Color(0xFF1E2C3B);
const Color blue2 = Color.fromRGBO(64, 75, 96, .9);
const Color lightBlue1 = Color(0xFF77C2EC);
const Color loading1 = Color(0x607684BA);
const Color loading2 = Color(0x607F8CC2);

BoxDecoration backgroundImage = BoxDecoration(
    image: DecorationImage(
        image: AssetImage("assets/bg2_alt.jpg"),
        fit: BoxFit.cover
    )
);

ThemeData avmeTheme = ThemeData(
    // Define the default brightness and colors.
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    accentColor: accentColor,
    // Define the default font family.
    fontFamily:  'Roboto Mono',
    scaffoldBackgroundColor: blue1,
    indicatorColor: lightBlue1,
    cardColor: blue2,
    cardTheme: CardTheme(
      color:blue2,
    ),
    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
    ),
  );