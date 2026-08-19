import 'package:bookread/utilities/constants.dart';

/// This class is used to represent the response of a task
class TaskResponse {
  TaskResponse({required this.success, this.message = ''});

  bool success;
  String message;

  bool get isSuccess => success;
  bool get isFailure => !success;

  @override
  String toString() {
    return 'TaskResponse: success: $success, message: $message';
  }
}

/// This class is used to represent a successful task response
class TaskOkResponse extends TaskResponse {
  TaskOkResponse({this.result, super.message}) : super(success: true);

  dynamic result;

  bool get isEmpty => result == null;

  @override
  String toString() {
    return 'TaskSuccessResponse: $result, message: $message';
  }
}

/// This class is used to represent a failed task response
class TaskBadResponse extends TaskResponse {
  TaskBadResponse({required this.errorCode, required super.message})
    : super(success: false);

  ErrorCode errorCode;

  @override
  String toString() {
    return 'TaskBadResponse: $errorCode, message: $message';
  }
}
