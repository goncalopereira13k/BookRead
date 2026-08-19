import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const kTypingDelay = Duration(milliseconds: 500);

const kRadiusLarge = 15.0;
const kRadiusMedium = 10.0;
const kRadiusSmall = 5.0;
const kPadding = 16.0;
const kSpaceSizeBetweenWidgets = 10.0;

const kCheckedColor = Colors.green;
const kUncheckedColor = Color.fromRGBO(229, 115, 115, 1);

const kPrimaryColor = Color.fromARGB(255, 136, 98, 202);
const kLightSecondaryColor = Colors.white;
const kLightTextColor = Colors.black;
const kLightHintTextColor = Color.fromARGB(255, 36, 0, 66);
const kLightBackgroundColor = Color(0xFFE0D9F0);
const kLightIconColor = Color(0xFF3F3D3D);

const kDarkSecondaryColor = Color(0xFF212121);
const kDarkTextColor = Colors.white;
const kDarkHintTextColor = Color.fromARGB(255, 211, 207, 207);
const kDarkBackgroundColor = Color(0xFF212121);
const kDarkSurfaceColor = Color(0xFF7A66A3);
const kDarkIconColor = Colors.white;
const kDarkCardColor = Color(0xFF18181C);

const kLightColorScheme = ColorScheme(
  primary: kPrimaryColor,
  secondary: kLightSecondaryColor,
  surface: kLightBackgroundColor,
  error: Colors.red,
  onPrimary: kLightTextColor,
  onSecondary: kLightTextColor,
  onSurface: kLightTextColor,
  onError: Colors.white,
  brightness: Brightness.light,
);
const kDarkColorScheme = ColorScheme(
  primary: kPrimaryColor,
  secondary: kDarkSecondaryColor,
  surface: kDarkSurfaceColor,
  error: Colors.red,
  onPrimary: kDarkTextColor,
  onSecondary: kLightTextColor,
  onSurface: kLightTextColor,
  onError: Colors.white,
  brightness: Brightness.dark,
);

final lightTheme = ThemeData(
  iconTheme: IconThemeData(color: kLightIconColor),
  colorScheme: kLightColorScheme,
  scaffoldBackgroundColor: kLightSecondaryColor,
  listTileTheme: ListTileThemeData(
    iconColor: kLightIconColor,
    textColor: kLightTextColor,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kLightBackgroundColor,
    hintStyle: TextStyle(color: kLightHintTextColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusMedium),
      borderSide: BorderSide(color: kDarkTextColor),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(kPrimaryColor),
      foregroundColor: WidgetStateProperty.all<Color>(kDarkTextColor),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusMedium),
        ),
      ),
    ),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: kLightTextColor),
    displayMedium: TextStyle(color: kLightTextColor),
    displaySmall: TextStyle(color: kLightTextColor),
    headlineLarge: TextStyle(color: kLightTextColor),
    headlineMedium: TextStyle(color: kLightTextColor),
    headlineSmall: TextStyle(color: kLightTextColor),
    titleLarge: TextStyle(color: kLightTextColor),
    titleMedium: TextStyle(color: kLightTextColor),
    titleSmall: TextStyle(color: kLightTextColor),
    bodyLarge: TextStyle(color: kLightTextColor),
    bodyMedium: TextStyle(color: kLightTextColor),
    bodySmall: TextStyle(color: kLightTextColor),
    labelLarge: TextStyle(color: kLightTextColor),
    labelMedium: TextStyle(color: kLightTextColor),
    labelSmall: TextStyle(color: kLightTextColor),
  ),
  primaryIconTheme: IconThemeData(color: kLightIconColor),
  appBarTheme: AppBarTheme(
    backgroundColor: kLightBackgroundColor,
    iconTheme: IconThemeData(color: kLightTextColor),
    titleTextStyle: TextStyle(
      color: kLightTextColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color.fromARGB(255, 173, 107, 30),
    selectedItemColor: kPrimaryColor,
    unselectedItemColor: kLightIconColor,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: kDarkBackgroundColor,
    contentTextStyle: TextStyle(color: kDarkTextColor),
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: kPrimaryColor,
    unselectedLabelColor: kLightIconColor,
    indicatorColor: kPrimaryColor,
  ),
);

final darkTheme = ThemeData(
  iconTheme: IconThemeData(color: kDarkIconColor),
  colorScheme: kDarkColorScheme,
  scaffoldBackgroundColor: kDarkSecondaryColor,
  cardColor: kDarkCardColor,
  listTileTheme: ListTileThemeData(
    iconColor: kDarkIconColor,
    textColor: kDarkTextColor,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kDarkSurfaceColor,
    hintStyle: TextStyle(color: kDarkHintTextColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusMedium),
      borderSide: BorderSide(color: kDarkTextColor),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(kPrimaryColor),
      foregroundColor: WidgetStateProperty.all<Color>(kDarkTextColor),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusMedium),
        ),
      ),
    ),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: kDarkTextColor),
    displayMedium: TextStyle(color: kDarkTextColor),
    displaySmall: TextStyle(color: kDarkTextColor),
    headlineLarge: TextStyle(color: kDarkTextColor),
    headlineMedium: TextStyle(color: kDarkTextColor),
    headlineSmall: TextStyle(color: kDarkTextColor),
    titleLarge: TextStyle(color: kDarkTextColor),
    titleMedium: TextStyle(color: kDarkTextColor),
    titleSmall: TextStyle(color: kDarkTextColor),
    bodyLarge: TextStyle(color: kDarkTextColor),
    bodyMedium: TextStyle(color: kDarkTextColor),
    bodySmall: TextStyle(color: kDarkTextColor),
    labelLarge: TextStyle(color: kDarkTextColor),
    labelMedium: TextStyle(color: kDarkTextColor),
    labelSmall: TextStyle(color: kDarkTextColor),
  ),
  primaryIconTheme: IconThemeData(color: kLightIconColor),
  appBarTheme: AppBarTheme(
    backgroundColor: kDarkSurfaceColor,
    iconTheme: IconThemeData(color: kDarkTextColor),
    titleTextStyle: TextStyle(
      color: kDarkTextColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: kDarkSurfaceColor,
    selectedItemColor: kLightSecondaryColor,
    unselectedItemColor: kLightIconColor,
    selectedIconTheme: IconThemeData(color: kLightSecondaryColor),
    unselectedIconTheme: IconThemeData(color: kLightIconColor),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: kDarkBackgroundColor,
    contentTextStyle: TextStyle(color: kDarkTextColor),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: kDarkBackgroundColor,
    titleTextStyle: TextStyle(color: kDarkTextColor),
    contentTextStyle: TextStyle(color: kDarkTextColor),
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: kPrimaryColor,
    unselectedLabelColor: kDarkTextColor,
    indicatorColor: kPrimaryColor,
  ),
  expansionTileTheme: ExpansionTileThemeData(
    iconColor: kDarkIconColor,
    collapsedIconColor: kDarkIconColor,
    textColor: kDarkTextColor,
    collapsedTextColor: kDarkTextColor,
  ),
);

enum MainScreenPage { home, goals, library, search, settings }

enum ErrorCode {
  none,
  noInternet,
  connection,
  timeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  server,
  unknown,
  serverError,
  nullArgument,
  permissionDenied,
}

enum Gender { notSet, male, female }

enum BookStatusType { wanted, reading, readed, archived }

enum GoalType { daily, yearly }
