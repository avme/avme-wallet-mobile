import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// /// Default Colors
//
// const Color primaryColor = Color(0xFF258CF3);
// const Color secondaryColor = Color(0xFF7238AD);
// const Color accentColor = Color(0xFF7238AD);
// const Color blue1 =  Color(0xFF1E2C3B);
// const Color blue2 = Color.fromRGBO(64, 75, 96, .9);
// const Color lightBlue1 = Color(0xFF77C2EC);
// const Color loading1 = Color(0x607684BA);
// const Color loading2 = Color(0x607F8CC2);

/// Default Colors

///Prototype Colors

// const Color purple = Color(0xff8A0DF2);
//
// const Color colors = Colors.black45;

class AppColors {
    static const primaryColor = Color(0xFF258CF3);
    static const secondaryColor = Color(0xFF258CF3);
    static const blue1 =  Color(0xFF1E2C3B);
    static const blue2 = Color.fromRGBO(64, 75, 96, .9);
    static const lightBlue1 = Color(0xFF77C2EC);
    static const loading1 = Color(0x607684BA);
    static const loading2 = Color(0x607F8CC2);
    static const lightBlue = Color(0xFF2CE8F4);
    static const purple = Color(0xFF9300F5);
    static const purpleVariant1 = Color(0xFF8a0df2);
    static const purpleVariant2 = Color(0xffab01f9);
    static const purpleDark1 = Color(0xFF7238AD);
    static const purpleDark2 = Color(0xFF12013A);
    static const purpleBlue = Color(0xFF2C0092);
    static const cardBlue = Color(0xFF151420);
    // static const darkBlue = Color.fromRGBO(22, 20, 32, 1.0);
    static const darkBlue = Color(0xFF16141F);
    static const labelDefaultColor = Color(0xFF8077A3);
    static const labelDisabledColor = Color(0xFF88878E);
    static const labelDisabledTransparent = Color(0xCCFFFFFF);
    // static const cardDefaultColor = Color(0xFF201E2C);
    static const cardDefaultColor = Color(0xFF201E2B);

    Map<int,Color> pickedColors = {};

    List<Color> availableColors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.deepOrange,
        AppColors.lightBlue,
        AppColors.purple,
        Colors.deepOrangeAccent,
        Colors.pinkAccent,
        // Colors.lightGreenAccent
        AppColors.purpleBlue
    ];

    Color randomColor({bool ignore = false})
    {
        Random random = Random();
        int tries = 0;
        if(ignore)
            return availableColors[random.nextInt(availableColors.length)];
        else
        while(true)
        {
            if (tries >= availableColors.length) return Colors.black;
            int key = random.nextInt(availableColors.length);
            // pickedColors[key] = availableColors[key];
            // return availableColors[key];
            if (pickedColors[key] == null)
            {
                pickedColors[key] = availableColors[key];
                return availableColors[key];
            }
            else tries++;
        }
    }
}


/// Shimmer Data

const shimmerGradientDefault = LinearGradient(
    colors: [
        AppColors.loading1,
        AppColors.loading2,
        AppColors.loading1,
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
    primaryColor: AppColors.purple,
    accentColor: AppColors.purpleDark1,
    // Define the default font family.
    fontFamily:  'Roboto Mono',
    // scaffoldBackgroundColor: AppColors.blue1,
    scaffoldBackgroundColor: AppColors.darkBlue,
    indicatorColor: AppColors.lightBlue1,
    cardColor: AppColors.blue2,
    cardTheme: CardTheme(
      color:AppColors.blue2,
    ),
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.purple,
        selectionColor: AppColors.purple
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor:MaterialStateProperty.all<Color>(AppColors.purple),
        )
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            primary: AppColors.purple, // This is a custom color variable
        ),
    ),
    appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBlue
    ),
    canvasColor: AppColors.cardBlue
);