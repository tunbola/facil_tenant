import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData shedAppThemeData() {
  final base = ThemeData.light();
  return base.copyWith(
      tabBarTheme: base.tabBarTheme.copyWith(
        indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: shedAppYellow300, width: 2.0),
            insets: EdgeInsets.symmetric(horizontal: 10.0)),
        labelColor: Colors.white,
        labelStyle: base.textTheme.headline6.copyWith(color: Colors.white),
        unselectedLabelStyle:
            base.textTheme.bodyText2.copyWith(color: Colors.white),
      ),
      brightness: Brightness.light,
      accentColor: shedAppBlue400,
      primaryColor: Colors.white,
      buttonTheme: base.buttonTheme.copyWith(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        buttonColor: shedAppBlue400,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: shedAppYellow400,
        foregroundColor: shedAppBodyBlack,
      ),
      scaffoldBackgroundColor: Colors.white,
      backgroundColor: Colors.white,
      cardColor: Colors.white,
      textSelectionColor: shedAppSelectionBlack,
      errorColor: shedAppErrorRed,
      textTheme: base.textTheme.copyWith(
        headline5: TextStyle(
          fontFamily: "Octin",
          fontSize: 40.0,
          color: shedAppBlue400,
          fontWeight: FontWeight.bold,
        ),
        headline6: TextStyle(
          fontFamily: 'Ubuntu',
          // fontSize: 20.0,
          color: shedAppBodyBlack,
          fontWeight: FontWeight.bold,
        ),
        subtitle2: TextStyle(
          fontFamily: 'Ubuntu',
          // fontSize: 18.0,
          color: shedAppBodyBlack,
          fontStyle: FontStyle.italic,
        ),
        bodyText2: TextStyle(
          fontFamily: "Ubuntu",
          // fontSize: 16.0,
          color: shedAppBodyBlack,
        ),
        headline4: TextStyle(
          fontFamily: "Ubuntu",
          // fontSize: 30.0,
          color: shedAppBlue100,
        ),
        caption: TextStyle(
          fontFamily: "Ubuntu",
          // fontSize: 14.0,
          color: shedAppBodyBlack,
        ).copyWith(
          fontFamily: "Ubuntu",
        ),
      ),
      primaryIconTheme: base.iconTheme.copyWith(
        size: 30,
        color: shedAppBlue400,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        suffixStyle: TextStyle(color: shedAppBodyBlack),
        labelStyle: TextStyle(
          color: Color(0xCC25333D),
          fontFamily: "Ubuntu",
          // fontSize: 15.0
        ),
        hintStyle: TextStyle(
          color: Color(0xCC25333D),
          fontFamily: "Ubuntu",
          // fontSize: 15.0
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: shedAppBlue300,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: shedAppErrorRed,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: shedAppErrorRed,
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: shedAppBlue300,
            width: 2.0,
          ),
        ),
      ),
      iconTheme: base.iconTheme.copyWith(
        color: shedAppBlue400,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(shedAppBlue400),
              elevation: MaterialStateProperty.all(5.0),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      side: BorderSide(color: shedAppBlue100))),
              padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(vertical: 17.0, horizontal: 30.0)))));
}
