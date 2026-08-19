import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/models/auth.dart';
import 'package:bookread/providers/theme_provider.dart';
import 'package:bookread/screens/login_screen.dart';
import 'package:bookread/screens/main_screen.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/task_response.dart';
import 'package:provider/provider.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  static const String id = 'offline_screen';

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  bool _isLoading = false;
  int _cooldownSeconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void unsetLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> retryConnection() async {
    if (_isLoading || _cooldownSeconds > 0) return;

    setLoading();
    final TaskResponse response = await AuthApi.tryLogin();

    if (response is TaskOkResponse) {
      Navigator.pushReplacementNamed(context, MainScreen.id);
    } else if (response is TaskBadResponse &&
        response.errorCode == ErrorCode.unauthorized) {
      Navigator.pushReplacementNamed(context, LoginScreen.id);
    }
    unsetLoading();
    startCooldown();
  }

  void startCooldown() {
    setState(() {
      _cooldownSeconds = 5;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _cooldownSeconds = 0;
        });
      } else {
        setState(() {
          _cooldownSeconds--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Image.asset(
                  themeProvider.isDarkMode
                      ? 'assets/images/logo_night.png'
                      : 'assets/images/logo_day.png',
                ),
                Text(
                  t.translate('offlineMessage'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: kSpaceSizeBetweenWidgets),
                if (_isLoading) const CircularProgressIndicator(),
                const SizedBox(height: kSpaceSizeBetweenWidgets),
                ElevatedButton(
                  onPressed:
                      (_cooldownSeconds == 0 && !_isLoading)
                          ? retryConnection
                          : null,
                  child: Text(
                    _cooldownSeconds > 0
                        ? '${t.translate('retryConnection')} ($_cooldownSeconds s)'
                        : t.translate('retryConnection'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
