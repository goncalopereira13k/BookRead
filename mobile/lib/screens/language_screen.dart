import 'package:flutter/material.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/providers/language_provider.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const String id = 'language_screen';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('languageTitle')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(t.translate('languageSubtitle')),
            const SizedBox(height: 40),
            _languageButton(
              context,
              t.translate('portuguese'),
              const Locale('pt'),
            ),
            const SizedBox(height: kSpaceSizeBetweenWidgets),
            _languageButton(
              context,
              t.translate('english'),
              const Locale('en'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageButton(BuildContext context, String label, Locale locale) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Provider.of<AppLanguageProvider>(
            context,
            listen: false,
          ).changeLanguage(locale);
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusMedium),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
