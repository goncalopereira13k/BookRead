import 'package:flutter/material.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/models/user.dart';
import 'package:bookread/services/validator.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/helper.dart';
import 'package:bookread/utilities/system.dart';
import 'package:bookread/utilities/task_response.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String id = 'profile_screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _detailsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passFormKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  DateTime? birthdate;
  Gender? gender;

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void setup() {
    User? user = System.instance.activeUser;
    if (user == null) {
      System.instance.logout();
    }

    _usernameController.text = user!.username;
    _emailController.text = user.email;
    _birthdateController.text = Helper.getLocalDateString(user.birthdate);
    birthdate = user.birthdate;
    gender = user.gender;
  }

  Future<void> _selectBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthdate,
      firstDate: DateTime(1100),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != birthdate) {
      birthdate = picked;
      _birthdateController.text = Helper.getLocalDateString(birthdate);
    }
  }

  Future<void> updateDetails() async {
    final t = AppLocalizations.of(context)!;
    // Validate the form fields
    if (!_detailsFormKey.currentState!.validate() || gender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.translate('fillAllFields'))));
      return;
    }

    User updatedUser = User(
      username: _usernameController.text,
      email: _emailController.text,
      birthdate: birthdate!,
      gender: gender!,
    );

    final TaskResponse response = await UserApi.updateUser(updatedUser);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
    }

    if (response is TaskOkResponse) {
      updatedUser = response.result;
      _usernameController.text = updatedUser.username;
      _emailController.text = updatedUser.email;
      _birthdateController.text = Helper.getLocalDateString(
        updatedUser.birthdate,
      );
      birthdate = updatedUser.birthdate;
      gender = updatedUser.gender;

      System.instance.activeUser?.username = updatedUser.username;
      System.instance.activeUser?.email = updatedUser.email;
      System.instance.activeUser?.birthdate = updatedUser.birthdate;
      System.instance.activeUser?.gender = updatedUser.gender;
    }
  }

  Future<void> changePassword() async {
    final t = AppLocalizations.of(context)!;
    // Validate the form fields
    if (!_passFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.translate('fillAllFields'))));
      return;
    }

    final TaskResponse response = await UserApi.changePassword(
      _passwordController.text,
      _newPasswordController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
    }

    if (response is TaskOkResponse) {
      Future.delayed(Duration(seconds: 2), () => System.instance.logout());
    }
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

  String? validateBirthdate(String? value) {
    final t = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return t.translate('fillBirth');
    }
    if (birthdate == null) {
      return t.translate('fillValidBirth');
    }
    if (birthdate!.isAfter(DateTime.now())) {
      return t.translate('fillPastBirth');
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
    return null;
  }

  String? validateNewPassword(String? value) {
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
    if (value != _newPasswordController.text) {
      return t.translate('passwordsDontMatch');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(t.translate('profileScreenTitle')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          children: [
            Row(children: [Text(t.translate('updateDetailsMessage'))]),
            const SizedBox(height: kSpaceSizeBetweenWidgets),
            Form(
              key: _detailsFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      label: Text(t.translate('username')),
                      hintText: t.translate('username'),
                    ),
                    validator: validateUsername,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      label: Text(t.translate('email')),
                      hintText: t.translate('email'),
                    ),
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _birthdateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      label: Text(t.translate('birthdate')),
                      hintText: t.translate('birthdate'),
                    ),
                    validator: validateBirthdate,
                    onTap: _selectBirthdate,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  DropdownButtonFormField<Gender>(
                    hint: Text(t.translate('gender')),
                    value: gender,
                    isExpanded: true,
                    decoration: InputDecoration(
                      label: Text(t.translate('gender')),
                      hintText: t.translate('gender'),
                    ),
                    onChanged: (Gender? value) {
                      setState(() {
                        gender = value!;
                      });
                    },
                    items:
                        Gender.values.map<DropdownMenuItem<Gender>>((
                          Gender gender,
                        ) {
                          return DropdownMenuItem<Gender>(
                            value: gender,
                            child: Text(t.translate('gender.${gender.name}')),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  ElevatedButton(
                    onPressed: updateDetails,
                    child: Text(t.translate('updateDetails')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kSpaceSizeBetweenWidgets),
            Row(children: [Text(t.translate('changePasswordMessage'))]),
            const SizedBox(height: kSpaceSizeBetweenWidgets),
            Form(
              key: _passFormKey,
              child: Column(
                children: [
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
                    validator: validatePassword,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  TextFormField(
                    controller: _newPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    obscuringCharacter: '●',
                    maxLength: 20,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      counter: const Offstage(),
                      label: Text(t.translate('newPassword')),
                      hintText: t.translate('newPassword'),
                    ),
                    validator: validateNewPassword,
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
                    validator: validateConfirmPassword,
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  ElevatedButton(
                    onPressed: changePassword,
                    child: Text(t.translate('changePassword')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
