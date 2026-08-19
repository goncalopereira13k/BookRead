import 'package:flutter/material.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/models/auth.dart';
import 'package:bookread/providers/theme_provider.dart';
import 'package:bookread/screens/login_screen.dart';
import 'package:bookread/services/validator.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/task_response.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String id = 'register_screen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  bool _isLoading = false;

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

  Future<void> performRegister() async {
    if (_isLoading) return; // Prevent multiple submissions
    setLoading();
    final t = AppLocalizations.of(context)!;
    // Validate the form fields
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.translate('fillAllFields'))));
      unsetLoading();
      return;
    }

    final TaskResponse response = await AuthApi.register(
      username,
      email,
      DateTime(2004, 03, 09),
      Gender.notSet,
      password,
    );

    // Show message
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
    }

    if (response.isFailure) {
      unsetLoading();
      return;
    }

    // Navigate to login screen
    Future.delayed(Duration(seconds: 2), () {
      unsetLoading();
      if (mounted) {
        Navigator.pushReplacementNamed(context, LoginScreen.id);
      }
    });
  }

  String? validateUsername(String? value) {
    final t = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return t.translate('fillUsername');
    }
    if (!Validator.isValidUsername(value)) {
      return t.translate('fillValidUsername');
    }
    return null;
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
    if (value.length < 8) {
      return t.translate('fillPasswordLength');
    }
    if (!Validator.isValidPassword(value)) {
      return t.translate('fillPasswordComplexity');
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    final t = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return t.translate('fillConfirmPassword');
    }
    if (value != password) {
      return t.translate('passwordsDontMatch');
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
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      label: Text(t.translate('username')),
                      hintText: t.translate('username'),
                    ),
                    onChanged: (String value) {
                      username = value;
                    },
                    validator: validateUsername,
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
                  TextFormField(
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    obscuringCharacter: '●',
                    maxLength: 20,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      counter: const Offstage(),
                      label: Text(t.translate('confirmPassword')),
                      hintText: t.translate('confirmPassword'),
                    ),
                    onChanged: (String value) {
                      confirmPassword = value;
                    },
                    validator: validateConfirmPassword,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  ElevatedButton(
                    onPressed: performRegister,
                    child: Text(t.translate('register')),
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              // Navegar para a tela de login
                              Navigator.pushReplacementNamed(
                                context,
                                LoginScreen.id,
                              );
                            },
                    child: Text(t.translate('loginMessage')),
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  Text(
                    t.translate('registerTerm'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
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
