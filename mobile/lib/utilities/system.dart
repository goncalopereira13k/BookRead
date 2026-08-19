import 'package:flutter/material.dart';
import 'package:bookread/models/auth.dart';
import 'package:bookread/models/goal.dart';
import 'package:bookread/models/settings.dart';
import 'package:bookread/models/user.dart';
import 'package:bookread/screens/login_screen.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

class System {
  System();
  System._init();

  static System instance = System._init();

  bool isInDebug = true;
  User? activeUser;
  Goal? dailyGoal;
  Goal? yearlyGoal;
  Settings? settings;
  String? token;
  String version = '';

  Future<void> init() async {
    // Initialize the system
    PackageInfo.fromPlatform().then((value) {
      version = value.data['version'];
    });
  }

  void loginSetup(AuthResponse authResponse) {
    token = authResponse.token ?? token;
    activeUser = authResponse.user;
    dailyGoal = authResponse.goals.firstWhere((g) => g.type == GoalType.daily);
    yearlyGoal = authResponse.goals.firstWhere(
      (g) => g.type == GoalType.yearly,
    );
    settings = authResponse.settings;
  }

  void clear() {
    // Clear the system
    activeUser = null;
    dailyGoal = null;
    yearlyGoal = null;
    settings = null;
    token = null;
  }

  void logout() {
    clear();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
      (Route<dynamic> route) => false, // This removes all previous routes
    );
  }
}
