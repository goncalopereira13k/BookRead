import 'package:flutter/material.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/components/settings_tile.dart';
import 'package:bookread/models/auth.dart';
import 'package:bookread/providers/theme_provider.dart';
import 'package:bookread/screens/about_us_screen.dart';
import 'package:bookread/screens/language_screen.dart';
import 'package:bookread/screens/login_screen.dart';
import 'package:bookread/screens/notifications_screen.dart';
import 'package:bookread/screens/profile_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static const String id = 'settings_screen';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(
      context,
      listen: false,
    );
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(t.translate('settingsTitle')),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.person,
                      title: t.translate('profile'),
                      onTap: () {
                        Navigator.pushNamed(context, ProfileScreen.id);
                      },
                    ),
                    SettingsTile(
                      icon: Icons.notifications,
                      title: t.translate('notifications'),
                      onTap: () {
                        Navigator.pushNamed(context, NotificationsScreen.id);
                      },
                    ),
                    SettingsTile(
                      icon: Icons.dark_mode,
                      title: t.translate('darkMode'),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (bool value) {
                          themeProvider.toggleTheme(value: value);
                        },
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.language,
                      title: t.translate('language'),
                      onTap: () {
                        Navigator.pushNamed(context, LanguageScreen.id);
                      },
                    ),
                    SettingsTile(
                      icon: Icons.logout,
                      title: t.translate('signout'),
                      color: Colors.red,
                      onTap: () async {
                        // Implement logout functionality here
                        await AuthApi.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            LoginScreen.id,
                          );
                        }
                      },
                    ),
                    SettingsTile(
                      icon: Icons.info_outline,
                      title: t.translate('aboutUs'),
                      onTap: () {
                        Navigator.pushNamed(context, AboutUsScreen.id);
                      },
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        children: [
                          Image.asset(
                            themeProvider.isDarkMode
                                ? 'assets/images/logo_night.png'
                                : 'assets/images/logo_day.png',
                            height: 250,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'BookRead',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            t.translate('developedBy'),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
