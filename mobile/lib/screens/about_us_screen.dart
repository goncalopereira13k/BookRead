import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/system.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});
  static const String id = 'about_us_screen';

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('aboutUs')),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/logo_day.png'),
            ),
            const SizedBox(height: 24),
            Text(
              t.translate('version', {'version': System.instance.version}),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: kSpaceSizeBetweenWidgets),
            Text(
              t.translate('aboutUsDescription'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(kRadiusLarge),
              ),
              child: Column(
                children: [
                  _buildLinkTile(
                    icon: FontAwesomeIcons.github,
                    text: t.translate('githubDiogo'),
                    onTap: () => _launchURL('https://github.com/drcor'),
                  ),
                  _buildLinkTile(
                    icon: FontAwesomeIcons.github,
                    text: t.translate('githubGoncalo'),
                    onTap:
                        () =>
                            _launchURL('https://github.com/goncalopereira13k'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
