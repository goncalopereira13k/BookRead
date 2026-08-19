import 'dart:convert';

import 'package:bookread/models/auth.dart';
import 'package:bookread/services/api_paths.dart';
import 'package:bookread/services/network.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/system.dart';
import 'package:bookread/utilities/task_response.dart';

mixin UserFields {
  static final List<String> allValues = [
    id,
    username,
    email,
    birthdate,
    gender,
    avatar,
    createdAt,
  ];

  static const String id = 'id';
  static const String username = 'username';
  static const String email = 'email';
  static const String birthdate = 'birthdate';
  static const String gender = 'gender';
  static const String avatar = 'avatar';
  static const String password = 'password';
  static const String newPassword = 'newPassword';
  static const String createdAt = 'createdAt';
}

class User {
  User({
    this.id,
    required this.username,
    required this.email,
    required this.birthdate,
    required this.gender,
    this.avatar,
    this.password,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id:
        json[UserFields.id] != null
            ? BigInt.parse(json[UserFields.id].toString())
            : null,
    username: json[UserFields.username],
    email: json[UserFields.email],
    birthdate: DateTime.parse(json[UserFields.birthdate]),
    gender: Gender.values[json[UserFields.gender] as int],
    avatar: json[UserFields.avatar],
    createdAt: json[UserFields.createdAt] != null
        ? DateTime.tryParse(json[UserFields.createdAt])
        : null,
  );

  BigInt? id;
  String username;
  String email;
  DateTime birthdate;
  Gender gender;
  String? avatar;
  String? password;
  DateTime? createdAt;

  Map<String, dynamic> toJson() => {
    UserFields.id: id?.toString(),
    UserFields.username: username,
    UserFields.email: email,
    UserFields.birthdate: birthdate.toIso8601String(),
    UserFields.gender: gender.index,
    UserFields.avatar: avatar,
    UserFields.createdAt: createdAt?.toIso8601String(),
  };
}

mixin UserApi {
  static Future<TaskResponse> getUser() async {
    final String url = ApiPaths.user();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.getData(
      timeoutSeconds: 5,
    );
    if (response is TaskOkResponse) {
      final Map<String, dynamic> json = jsonDecode(response.result);
      final AuthResponse authResponse = AuthResponse.fromJson(json);

      System.instance.loginSetup(authResponse);

      return TaskOkResponse(
        result: System.instance.activeUser,
        message: 'User successful',
      );
    } else if (response is TaskBadResponse &&
        response.errorCode == ErrorCode.unauthorized) {
      // Handle error
      return TaskBadResponse(
        errorCode: ErrorCode.unauthorized,
        message: 'User failed: ${response.message}',
      );
    } else {
      return response;
    }
  }

  static Future<TaskResponse> updateUser(User user) async {
    final String url = ApiPaths.user();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.updateData(
      body: user.toJson(),
    );

    if (response is TaskOkResponse) {
      final Map<String, dynamic> json = jsonDecode(response.result);
      return TaskOkResponse(
        message: response.message,
        result: User.fromJson(json),
      );
    } else {
      return response;
    }
  }

  static Future<TaskResponse> changePassword(
    String password,
    String newPassword,
  ) async {
    final String url = ApiPaths.changePassword();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.updateData(
      body: {
        UserFields.password: password,
        UserFields.newPassword: newPassword,
      },
    );

    return response;
  }
}
