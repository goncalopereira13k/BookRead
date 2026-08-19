import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bookread/models/goal.dart';
import 'package:bookread/models/settings.dart';
import 'package:bookread/models/user.dart';
import 'package:bookread/services/api_paths.dart';
import 'package:bookread/services/network.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/system.dart';
import 'package:bookread/utilities/task_response.dart';

mixin AuthFields {
  static const String token = 'token';
  static const String user = 'user';
  static const String goals = 'goals';
  static const String settings = 'settings';
  static const String email = 'email';
  static const String password = 'password';
}

class AuthCredentials {
  AuthCredentials({required this.email, required this.password});

  final String? email;
  final String? password;
}

class AuthResponse {
  AuthResponse({
    this.token,
    required this.user,
    required this.goals,
    required this.settings,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json[AuthFields.token] as String?,
    user: User.fromJson(json[AuthFields.user] as Map<String, dynamic>),
    goals: List<Goal>.from(
      (json[AuthFields.goals] as List<dynamic>).map(
        (model) => Goal.fromJson(model as Map<String, dynamic>),
      ),
    ),
    settings: Settings.fromJson(
      json[AuthFields.settings] as Map<String, dynamic>,
    ),
  );
  final String? token;
  final User user;
  final List<Goal> goals;
  final Settings settings;
}

mixin AuthApi {
  static Future<TaskResponse> login(String email, String password) async {
    final String url = ApiPaths.login();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.postDataNoAuth(
      body: {'email': email, 'password': password},
    );

    if (response is TaskOkResponse) {
      final Map<String, dynamic> json = jsonDecode(response.result);
      final AuthResponse authResponse = AuthResponse.fromJson(json);

      if (authResponse.token == null || authResponse.token!.isEmpty) {
        return TaskBadResponse(
          errorCode: ErrorCode.unauthorized,
          message: 'Login failed: Invalid response from server',
        );
      }

      System.instance.loginSetup(authResponse);

      await saveToken(authResponse);

      return TaskOkResponse(
        result: System.instance.activeUser,
        message: 'Login successful',
      );
    } else {
      // Handle error
      return TaskBadResponse(
        errorCode: ErrorCode.unauthorized,
        message: 'Login failed: ${response.message}',
      );
    }
  }

  static Future<TaskResponse> tryLogin() async {
    final String? token = await AuthApi.loadToken();

    if (token == null) {
      return TaskBadResponse(errorCode: ErrorCode.unauthorized, message: '');
    }

    System.instance.token = token;

    final TaskResponse response = await UserApi.getUser();

    if (response is TaskBadResponse &&
        response.errorCode == ErrorCode.unauthorized) {
      await deleteToken();
      System.instance.clear();
      return TaskBadResponse(errorCode: ErrorCode.unauthorized, message: '');
    }

    return response;
  }

  static Future<TaskResponse> register(
    String username,
    String email,
    DateTime birthdate,
    Gender gender,
    String password,
  ) async {
    final String url = ApiPaths.register();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.postDataNoAuth(
      body: {
        'username': username,
        'email': email,
        'birthdate': birthdate.toIso8601String(),
        'gender': gender.index,
        'password': password,
      },
    );

    if (response is! TaskOkResponse) {
      return TaskBadResponse(
        errorCode:
            response is TaskBadResponse
                ? response.errorCode
                : ErrorCode.unauthorized,
        message: 'Registration failed: ${response.message}',
      );
    }

    return TaskResponse(success: true, message: 'Registration successful');
  }

  static Future<void> logout() async {
    await deleteToken();
    System.instance.clear();
  }

  /// Save credentials to secure storage
  static Future<void> saveToken(AuthResponse authResponse) async {
    final FlutterSecureStorage storage = const FlutterSecureStorage();
    await storage.write(key: AuthFields.token, value: authResponse.token);
  }

  /// Load credentials from secure storage
  static Future<String?> loadToken() {
    final FlutterSecureStorage storage = const FlutterSecureStorage();
    return storage.read(key: AuthFields.token);
  }

  /// Delete credentials from secure storage
  static Future<void> deleteToken() async {
    final FlutterSecureStorage storage = const FlutterSecureStorage();
    await storage.delete(key: AuthFields.token);
  }
}
