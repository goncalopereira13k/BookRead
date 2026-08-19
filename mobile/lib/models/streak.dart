import 'dart:convert';

import 'package:bookread/services/api_paths.dart';
import 'package:bookread/services/network.dart';
import 'package:bookread/utilities/task_response.dart';

mixin StreakFields {
  static const String userId = 'userId';
  static const String start = 'start';
  static const String end = 'end';
  static const String length = 'length';
}

class Streak {
  Streak({
    required this.userId,
    required this.start,
    required this.end,
    required this.length,
  });

  factory Streak.fromJson(Map<String, dynamic> json) => Streak(
    userId: BigInt.parse(json[StreakFields.userId] as String),
    start: DateTime.parse(json[StreakFields.start] as String),
    end: DateTime.parse(json[StreakFields.end] as String),
    length: json[StreakFields.length] as int,
  );

  BigInt userId;
  DateTime start;
  DateTime end;
  int length;

  Map<String, dynamic> toJson() => {
    StreakFields.userId: userId.toString(),
    StreakFields.start: start.toIso8601String(),
    StreakFields.end: end.toIso8601String(),
    StreakFields.length: length,
  };
}

mixin StreakApi {
  static Future<Streak?> getStreak() async {
    final String url = ApiPaths.streak();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.getData();
    if (response is TaskOkResponse) {
      final String? result = response.result;
      if (result == null || result.isEmpty) return null;

      final json = jsonDecode(result) as Map<String, dynamic>;

      return Streak.fromJson(json);
    } else {
      return null;
    }
  }
}
