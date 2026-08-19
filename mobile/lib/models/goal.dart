import 'dart:convert';

import 'package:bookread/services/api_paths.dart';
import 'package:bookread/services/network.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/task_response.dart';

mixin GoalFields {
  static const String userId = 'userId';
  static const String type = 'type';
  static const String value = 'value';
}

class Goal {
  Goal({required this.type, required this.value}) {
    if (value < 1) {
      throw ArgumentError('O valor deve ser maior ou igual a 1.');
    }
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      type: GoalType.values[json[GoalFields.type] as int],
      value: json[GoalFields.value],
    );
  }

  final GoalType type;
  final int value;

  Map<String, dynamic> toJson() {
    return {GoalFields.type: type.index, GoalFields.value: value};
  }
}

class GoalApi {
  static Future<TaskResponse> getDailyGoal() async {
    final String url = ApiPaths.dailyGoal();
    final Network response = Network(url);
    final TaskResponse taskResponse = await response.getData();

    if (taskResponse is! TaskOkResponse) {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: 'Failed to fetch daily goal: ${taskResponse.message}',
      );
    }
    final String? result = taskResponse.result;
    if (result == null || result.isEmpty) {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: 'Daily goal not found',
      );
    }
    final json = jsonDecode(taskResponse.result);
    final Goal goal = Goal.fromJson(json);

    return TaskOkResponse(
      result: goal,
      message: 'Daily goal fetched successfully',
    );
  }

  static Future<TaskResponse> getYearlyGoal() async {
    final String url = ApiPaths.yearlyGoal();
    final Network response = Network(url);
    final TaskResponse taskResponse = await response.getData();

    if (taskResponse is! TaskOkResponse) {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: 'Failed to fetch yearly goal: ${taskResponse.message}',
      );
    }
    final String? result = taskResponse.result;
    if (result == null || result.isEmpty) {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: 'Yearly goal not found',
      );
    }
    final json = jsonDecode(taskResponse.result);
    final Goal goal = Goal.fromJson(json);

    return TaskOkResponse(
      result: goal,
      message: 'Yearly goal fetched successfully',
    );
  }

  static Future<TaskResponse> setDailyGoal(int value) async {
    final String url = ApiPaths.dailyGoal();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.postData(
      body: {GoalFields.value: value},
    );

    if (response is TaskOkResponse) {
      final Map<String, dynamic> json = jsonDecode(response.result);
      return TaskOkResponse(result: Goal.fromJson(json));
    } else {
      return response;
    }
  }

  static Future<TaskResponse> setYearlyGoal(int value) async {
    final String url = ApiPaths.yearlyGoal();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.postData(
      body: {GoalFields.value: value},
    );

    if (response is TaskOkResponse) {
      final Map<String, dynamic> json = jsonDecode(response.result);
      return TaskOkResponse(result: Goal.fromJson(json));
    } else {
      return response;
    }
  }
}
