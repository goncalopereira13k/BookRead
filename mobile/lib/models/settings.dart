import 'dart:convert';

import 'package:bookread/services/api_paths.dart';
import 'package:bookread/services/network.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/task_response.dart';

mixin SettingsFields {
  static const String notifDaily = 'notifDaily';
  static const String notifGoal = 'notifGoal';
}

class Settings {
  const Settings({required this.notifDaily, required this.notifGoal});

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    notifDaily: json[SettingsFields.notifDaily] as bool,
    notifGoal: json[SettingsFields.notifGoal] as bool,
  );

  final bool notifDaily;
  final bool notifGoal;

  Map<String, dynamic> toJson() => {
    SettingsFields.notifDaily: notifDaily,
    SettingsFields.notifGoal: notifGoal,
  };
}

mixin SettingsApi {
  static Future<TaskResponse> getSettings() async {
    final String url = ApiPaths.settings();
    final Network networkServices = Network(url);

    final TaskResponse response = await networkServices.getData();
    if (response is TaskOkResponse) {
      final String? result = response.result;
      if (result == null || result.isEmpty) {
        return TaskBadResponse(
          errorCode: ErrorCode.unknown,
          message: 'Settings not found',
        );
      }
      final json = jsonDecode(response.result);
      final Settings settings = Settings.fromJson(json);

      return TaskOkResponse(
        result: settings,
        message: 'Settinngs fetched successfully',
      );
    } else {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: 'Failed to fetch settings: ${response.message}',
      );
    }
  }

  static Future<TaskResponse> setSettings(Settings settings) async {
    final String url = ApiPaths.settings();
    final Network networkServices = Network(url);

    final TaskResponse response = await networkServices.updateData(
      body: settings.toJson(),
    );

    if (response is TaskOkResponse) {
      final String? result = response.result;
      if (result == null || result.isEmpty) {
        return TaskBadResponse(
          errorCode: ErrorCode.unknown,
          message: 'Settings not found',
        );
      }
      final json = jsonDecode(response.result);
      final Settings settings = Settings.fromJson(json);

      return TaskOkResponse(
        result: settings,
        message: 'Settings fetched successfully',
      );
    } else {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: 'Failed to fetch settings: ${response.message}',
      );
    }
  }
}
