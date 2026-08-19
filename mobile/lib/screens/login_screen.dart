import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/models/auth.dart';
import 'package:bookread/providers/theme_provider.dart';
import 'package:bookread/screens/main_screen.dart';
import 'package:bookread/screens/register_screen.dart';
import 'package:bookread/services/validator.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/task_response.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String email = '';
  String password = '';

  Future<void> performLogin() async {
    final t = AppLocalizations.of(context)!;
    // Validate the form fields
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.translate('fillAllFields'))));
      return;
    }

    final TaskResponse response = await AuthApi.login(email, password);

    // Show message
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
    }

    if (response.isFailure) {
      return;
    }

    // Navigate to the main screen
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, MainScreen.id);
    });
  }

  String? validateEmail(String? value) {
    final t = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return t.translate('fillEmail');
    }
    if (!Validator.isValidEmail(value)) {
      return t.translate('fillValidEmail');
    }
    return null;
  }

  String? validatePassword(String? value) {
    final t = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return t.translate('fillPassword');
    }
    return null;
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
            child: Form(
              key: _formKey,
              onPopInvokedWithResult: (bool didPop, Object? result) {
                return;
              },
              child: Column(
                children: [
                  Image.asset(
                    themeProvider.isDarkMode
                        ? 'assets/images/logo_night.png'
                        : 'assets/images/logo_day.png',
                  ),
                  Text(
                    t.translate('welcomeMessage'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      label: Text(t.translate('email')),
                      hintText: t.translate('email'),
                    ),
                    onChanged: (String value) {
                      email = value;
                    },
                    validator: validateEmail,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    obscuringCharacter: '●',
                    maxLength: 20,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      counter: const Offstage(),
                      label: Text(t.translate('password')),
                      hintText: t.translate('password'),
                    ),
                    onChanged: (String value) {
                      password = value;
                    },
                    validator: validatePassword,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  ElevatedButton(
                    onPressed: performLogin,
                    child: Text(t.translate('login')),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RegisterScreen.id);
                    },
                    child: Text(t.translate('registerMessage')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
