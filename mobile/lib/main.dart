import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/models/auth.dart';
import 'package:bookread/providers/language_provider.dart';
import 'package:bookread/providers/theme_provider.dart';
import 'package:bookread/providers/timer_provider.dart';
import 'package:bookread/screens/about_us_screen.dart';
import 'package:bookread/screens/goals_screen.dart';
import 'package:bookread/screens/language_screen.dart';
import 'package:bookread/screens/login_screen.dart';
import 'package:bookread/screens/main_screen.dart';
import 'package:bookread/screens/notifications_screen.dart';
import 'package:bookread/screens/offline_screen.dart';
import 'package:bookread/screens/profile_screen.dart';
import 'package:bookread/screens/register_screen.dart';
import 'package:bookread/screens/settings_screen.dart';
import 'package:bookread/screens/timer_screen.dart';
import 'package:bookread/services/background.dart';
import 'package:bookread/services/notification.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/system.dart';
import 'package:bookread/utilities/task_response.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  System.instance.init();
  await NotificationService.instance.init();
  BackgroundService.init();

  String initialRoute = LoginScreen.id;
  final TaskResponse response = await AuthApi.tryLogin();
  if (response is TaskOkResponse) {
    initialRoute = MainScreen.id;
  } else if (response is TaskBadResponse &&
      response.errorCode != ErrorCode.unauthorized) {
    initialRoute = OfflineScreen.id;
  }
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppLanguageProvider()..fetchLocale(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: Consumer<AppLanguageProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            locale: provider.appLocale,
            supportedLocales: const [Locale('en'), Locale('pt')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode:
                Provider.of<ThemeProvider>(context).isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            initialRoute: initialRoute,
            routes: {
              AboutUsScreen.id: (context) => AboutUsScreen(),
              GoalsScreen.id: (context) => GoalsScreen(),
              LanguageScreen.id: (context) => LanguageScreen(),
              LoginScreen.id: (context) => LoginScreen(),
              MainScreen.id: (context) => MainScreen(),
              NotificationsScreen.id: (context) => NotificationsScreen(),
              OfflineScreen.id: (context) => OfflineScreen(),
              ProfileScreen.id: (context) => ProfileScreen(),
              RegisterScreen.id: (context) => RegisterScreen(),
              SettingsScreen.id: (context) => SettingsScreen(),
              TimerScreen.id: (context) => TimerScreen(),
            },
          );
        },
      ),
    );
  }
}
