import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:bookread/app_localizations.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/system.dart';
import 'package:bookread/utilities/task_response.dart';

class Network {
  Network(this.url);

  final String url;

  static String _translate(String key, [Map<String, String>? args]) {
    final context = navigatorKey.currentContext;
    return context != null
        ? AppLocalizations.of(context)!.translate('serverError', args)
        : '';
  }

  static TaskResponse _handleApiError(http.Response response) {
    if (response.statusCode == 401) {
      System.instance.logout();
      return TaskBadResponse(
        errorCode: ErrorCode.unauthorized,
        message: _translate('unauthorized'),
      );
    } else if (response.statusCode == 403) {
      System.instance.logout();
      return TaskBadResponse(
        errorCode: ErrorCode.forbidden,
        message: _translate('forbidden'),
      );
    } else if (response.statusCode == 500) {
      return TaskBadResponse(
        errorCode: ErrorCode.serverError,
        message: _translate('serverError'),
      );
    } else {
      try {
        final json = jsonDecode(response.body);
        if (json == null) throw Error();
        if (json['message'] == null) throw Error();

        return TaskBadResponse(
          errorCode: ErrorCode.unknown,
          message: json['message'],
        );
      } catch (_) {
        return TaskBadResponse(
          errorCode: ErrorCode.unknown,
          message: _translate('unknownError'),
        );
      }
    }
  }

  Future<TaskResponse> getDataNoAuth({int timeoutSeconds = 10}) async {
    final Duration timeout = Duration(seconds: timeoutSeconds);
    final Uri urlParsed = Uri.parse(url);

    try {
      final http.Response response = await http.get(urlParsed).timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return TaskOkResponse(
          result: response.body,
          message: _translate('requestSuccess'),
        );
      }

      return _handleApiError(response);
    } on TimeoutException {
      return TaskBadResponse(
        errorCode: ErrorCode.timeout,
        message: _translate('timedOut'),
      );
    } on SocketException {
      return TaskBadResponse(
        errorCode: ErrorCode.noInternet,
        message: _translate('noServerConnection'),
      );
    } on http.ClientException {
      return TaskBadResponse(
        errorCode: ErrorCode.connection,
        message: _translate('serverInterrupted'),
      );
    } on FormatException {
      return TaskBadResponse(
        errorCode: ErrorCode.badRequest,
        message: _translate('badRequest'),
      );
    } catch (e) {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: _translate('unknownErrorMessage', {'error': e.toString()}),
      );
    }
  }

  Future<TaskResponse> getData({int timeoutSeconds = 10}) async {
    final Duration timeout = Duration(seconds: timeoutSeconds);
    final Uri urlParsed = Uri.parse(url);
    final String? token = System.instance.token;

    if (token == null) {
      return TaskBadResponse(
        errorCode: ErrorCode.unauthorized,
        message: _translate('noTokenProvided'),
      );
    }

    try {
      final http.Response response = await http
          .get(urlParsed, headers: {'Authorization': 'Bearer $token'})
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return TaskOkResponse(
          result: response.body,
          message: _translate('requestSuccess'),
        );
      }

      return _handleApiError(response);
    } on TimeoutException {
      return TaskBadResponse(
        errorCode: ErrorCode.timeout,
        message: _translate('timedOut'),
      );
    } on SocketException {
      return TaskBadResponse(
        errorCode: ErrorCode.noInternet,
        message: _translate('noServerConnection'),
      );
    } on http.ClientException {
      return TaskBadResponse(
        errorCode: ErrorCode.connection,
        message: _translate('serverInterrupted'),
      );
    } on FormatException {
      return TaskBadResponse(
        errorCode: ErrorCode.badRequest,
        message: _translate('badRequest'),
      );
    } catch (e) {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: _translate('unknownErrorMessage', {'error': e.toString()}),
      );
    }
  }

  Future<TaskResponse> postDataNoAuth({
    Map<String, dynamic>? body,
    int timeoutSeconds = 10,
  }) async {
    final Duration timeout = Duration(seconds: timeoutSeconds);
    final Uri urlParsed = Uri.parse(url);

    try {
      final http.Response response = await http
          .post(
            urlParsed,
            headers: {'Content-Type': 'application/json'},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskOkResponse(
          result: response.body,
          message: _translate('requestSuccess'),
        );
      }

      return _handleApiError(response);
    } on TimeoutException {
      return TaskBadResponse(
        errorCode: ErrorCode.timeout,
        message: _translate('timedOut'),
      );
    } on SocketException {
      return TaskBadResponse(
        errorCode: ErrorCode.noInternet,
        message: _translate('noServerConnection'),
      );
    } on http.ClientException {
      return TaskBadResponse(
        errorCode: ErrorCode.connection,
        message: _translate('serverInterrupted'),
      );
    } on FormatException {
      return TaskBadResponse(
        errorCode: ErrorCode.badRequest,
        message: _translate('badRequest'),
      );
    } catch (e) {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: _translate('unknownErrorMessage', {'error': e.toString()}),
      );
    }
  }

  Future<TaskResponse> postData({
    Map<String, dynamic>? body,
    int timeoutSeconds = 10,
  }) async {
    final Duration timeout = Duration(seconds: timeoutSeconds);
    final Uri urlParsed = Uri.parse(url);
    final String? token = System.instance.token;

    if (token == null) {
      return TaskBadResponse(
        errorCode: ErrorCode.unauthorized,
        message: _translate('noTokenProvided'),
      );
    }

    try {
      final http.Response response = await http
          .post(
            urlParsed,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskOkResponse(
          result: response.body,
          message: _translate('requestSuccess'),
        );
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final String message = json['message'] ?? _translate('notFound');
        return TaskBadResponse(
          errorCode: ErrorCode.forbidden,
          message: message,
        );
      }

      return _handleApiError(response);
    } on TimeoutException {
      return TaskBadResponse(
        errorCode: ErrorCode.timeout,
        message: _translate('timedOut'),
      );
    } on SocketException {
      return TaskBadResponse(
        errorCode: ErrorCode.noInternet,
        message: _translate('noServerConnection'),
      );
    } on http.ClientException {
      return TaskBadResponse(
        errorCode: ErrorCode.connection,
        message: _translate('serverInterrupted'),
      );
    } on FormatException {
      return TaskBadResponse(
        errorCode: ErrorCode.badRequest,
        message: _translate('badRequest'),
      );
    } catch (e) {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: _translate('unknownErrorMessage', {'error': e.toString()}),
      );
    }
  }

  Future<TaskResponse> updateData({
    Map<String, dynamic>? body,
    int timeoutSeconds = 10,
  }) async {
    final Duration timeout = Duration(seconds: timeoutSeconds);
    final Uri urlParsed = Uri.parse(url);
    final String? token = System.instance.token;

    if (token == null) {
      return TaskBadResponse(
        errorCode: ErrorCode.unauthorized,
        message: _translate('noTokenProvided'),
      );
    }

    try {
      final http.Response response = await http
          .put(
            urlParsed,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskOkResponse(
          result: response.body,
          message: _translate('requestSuccess'),
        );
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final String message = json['message'] ?? _translate('notFound');
        return TaskBadResponse(
          errorCode: ErrorCode.forbidden,
          message: message,
        );
      }

      return _handleApiError(response);
    } on TimeoutException {
      return TaskBadResponse(
        errorCode: ErrorCode.timeout,
        message: _translate('timedOut'),
      );
    } on SocketException {
      return TaskBadResponse(
        errorCode: ErrorCode.noInternet,
        message: _translate('noServerConnection'),
      );
    } on http.ClientException {
      return TaskBadResponse(
        errorCode: ErrorCode.connection,
        message: _translate('serverInterrupted'),
      );
    } on FormatException {
      return TaskBadResponse(
        errorCode: ErrorCode.badRequest,
        message: _translate('badRequest'),
      );
    } catch (e) {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: _translate('unknownErrorMessage', {'error': e.toString()}),
      );
    }
  }

  Future<TaskResponse> deleteData({
    Map<String, dynamic>? body,
    int timeoutSeconds = 10,
  }) async {
    final Duration timeout = Duration(seconds: timeoutSeconds);
    final Uri urlParsed = Uri.parse(url);
    final String? token = System.instance.token;

    if (token == null) {
      return TaskBadResponse(
        errorCode: ErrorCode.unauthorized,
        message: _translate('noTokenProvided'),
      );
    }

    try {
      final http.Response response = await http
          .delete(
            urlParsed,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskOkResponse(
          result: response.body,
          message: _translate('requestSuccess'),
        );
      }

      return _handleApiError(response);
    } on TimeoutException {
      return TaskBadResponse(
        errorCode: ErrorCode.timeout,
        message: _translate('timedOut'),
      );
    } on SocketException {
      return TaskBadResponse(
        errorCode: ErrorCode.noInternet,
        message: _translate('noServerConnection'),
      );
    } on http.ClientException {
      return TaskBadResponse(
        errorCode: ErrorCode.connection,
        message: _translate('serverInterrupted'),
      );
    } on FormatException {
      return TaskBadResponse(
        errorCode: ErrorCode.badRequest,
        message: _translate('badRequest'),
      );
    } catch (e) {
      return TaskBadResponse(
        errorCode: ErrorCode.unknown,
        message: _translate('unknownErrorMessage', {'error': e.toString()}),
      );
    }
  }
}
