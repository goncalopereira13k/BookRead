import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageProvider extends ChangeNotifier {
  Locale _appLocale = const Locale('pt');

  Locale get appLocale => _appLocale;

  Future<void> fetchLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'pt';
    _appLocale = Locale(code);
    notifyListeners();
  }

  Future<void> changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    _appLocale = locale;
    await prefs.setString('locale', locale.languageCode);
    notifyListeners();
  }
}
