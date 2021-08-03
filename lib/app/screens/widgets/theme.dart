import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default Colors

const Color primaryColor = Color(0xFF258CF3);
const Color secondaryColor = Color(0xFF7238AD);
const Color accentColor = Color(0xFF7238AD);
const Color blue1 =  Color(0xFF1E2C3B);
const Color blue2 = Color.fromRGBO(64, 75, 96, .9);
const Color lightBlue1 = Color(0xFF77C2EC);
const Color loading1 = Color(0x607684BA);
const Color loading2 = Color(0x607F8CC2);

/// Shimmer Data

const shimmerGradientDefault = LinearGradient(
    colors: [
        loading1,
        loading2,
        loading1,
    ],
    stops: [
        0.1,
        0.3,
        0.4,
    ],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    tileMode: TileMode.clamp,
);

/// Card Label Params

final double labelHeight = 16;
final double labelSpacing = 6.5;
final BorderRadius labelRadius = BorderRadius.circular(16);
final BorderRadius cardRadius = BorderRadius.all(Radius.circular(4.0));


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
  );