import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:schoolapp/flavor/app_config.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:schoolapp/core/utils/dialog_manager.dart';

class ApiService extends GetxService {
  ApiService init() => this;

  String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  Logger get logger => Logger.root;
  late final d.Dio _client = _buildClient();

  d.Dio _buildClient() {
    final client = d.Dio(
      d.BaseOptions(
        followRedirects: false,
        contentType: 'application/json',
        responseType: d.ResponseType.json,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Charset': 'utf-8',
        },
        baseUrl: baseUrl,
        sendTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
      ),
    );

    client.interceptors.add(
      d.InterceptorsWrapper(
        onRequest: (options, handler) {
          _syncClientState(options);
          final customBaseUrl = options.extra['custom_base_url'];
          if (customBaseUrl is String && customBaseUrl.trim().isNotEmpty) {
            options.baseUrl = customBaseUrl.trim();
          }
          if (kDebugMode) {
            options.extra['started_at'] = DateTime.now();
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            _logTiming(
              response.requestOptions,
              statusCode: response.statusCode,
            );
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          final retryResponse = await _retryIfNeeded(error);
          if (retryResponse != null) {
            handler.resolve(retryResponse);
            return;
          }

          if (_isNetworkError(error)) {
            DialogManager.showTopBanner(
              title: 'Connection',
              message: _friendlyNetworkMessage(error),
              backgroundColor: const Color(0xFFB45309),
            );
          }
          if (kDebugMode) {
            _logTiming(
              error.requestOptions,
              statusCode: error.response?.statusCode,
              error: error.message,
            );
<<<<<<< HEAD
            _logErrorBody(error);
=======
>>>>>>> 74bda71b0166ce92efa14e7395518c52665ecb87
          }
          handler.next(error);
        },
      ),
    );

    return client;
  }

  Future<d.Response<dynamic>?> _retryIfNeeded(d.DioException error) async {
    final request = error.requestOptions;
    final attempt = (request.extra['retry_attempt'] as int?) ?? 0;
    if (attempt >= 1 || !_isRetryableRequest(error)) {
      return null;
    }

    await Future<void>.delayed(const Duration(milliseconds: 700));

    final nextOptions = d.Options(
      method: request.method,
      headers: Map<String, dynamic>.from(request.headers),
      contentType: request.contentType,
      responseType: request.responseType,
      sendTimeout: request.sendTimeout,
      receiveTimeout: request.receiveTimeout,
      extra:
          Map<String, dynamic>.from(request.extra)
            ..['retry_attempt'] = attempt + 1
            ..remove('started_at'),
      validateStatus: request.validateStatus,
      followRedirects: request.followRedirects,
      receiveDataWhenStatusError: request.receiveDataWhenStatusError,
    );

    try {
      return await _client.request<dynamic>(
        request.path,
        data: _prepareRequestData(request.data),
        queryParameters: request.queryParameters,
        options: nextOptions,
        cancelToken: request.cancelToken,
        onReceiveProgress: request.onReceiveProgress,
        onSendProgress: request.onSendProgress,
      );
    } on d.DioException {
      return null;
    }
  }

  bool _isRetryableRequest(d.DioException error) {
    final request = error.requestOptions;
    if (request.method.toUpperCase() != 'GET') {
      return false;
    }
    return _isNetworkError(error);
  }

  bool _isNetworkError(d.DioException error) {
    if (error.type == d.DioExceptionType.connectionTimeout ||
        error.type == d.DioExceptionType.connectionError ||
        error.type == d.DioExceptionType.receiveTimeout) {
      return true;
    }

    final message = (error.message ?? '').toLowerCase();
    return error.type == d.DioExceptionType.unknown &&
        (message.contains('socketexception') ||
            message.contains('connection') ||
            message.contains('timed out'));
  }

  String _friendlyNetworkMessage(d.DioException error) {
    switch (error.type) {
      case d.DioExceptionType.connectionTimeout:
        return 'The server is taking too long to connect. Please try again.';
      case d.DioExceptionType.receiveTimeout:
        return 'The server is responding slowly. Please wait and try again.';
      case d.DioExceptionType.connectionError:
        return 'No internet connection. Check your network and try again.';
      case d.DioExceptionType.unknown:
        return 'Network connection looks unstable. Please try again.';
      default:
        return 'Request failed. Please try again.';
    }
  }

  void _syncClientState(d.RequestOptions options) {
    _client.options.baseUrl = baseUrl;

    final authToken = AppConfig.shared.authorizationToken.trim();
    if (authToken.isEmpty) {
      _client.options.headers.remove('Authorization');
      options.headers.remove('Authorization');
    } else {
      _client.options.headers['Authorization'] = authToken;
      options.headers['Authorization'] = authToken;
    }
  }

  d.Options _buildOptions({
    Map<String, dynamic>? headers,
    String? contentType,
    String? baseUrl,
<<<<<<< HEAD
    Duration? sendTimeout,
=======
>>>>>>> 74bda71b0166ce92efa14e7395518c52665ecb87
  }) {
    final mergedHeaders = <String, dynamic>{
      ..._client.options.headers,
      if (headers != null) ...headers,
    };

    return d.Options(
      headers: mergedHeaders,
      contentType: contentType ?? _client.options.contentType,
      responseType: _client.options.responseType,
<<<<<<< HEAD
      sendTimeout: sendTimeout ?? _client.options.sendTimeout,
=======
      sendTimeout: _client.options.sendTimeout,
>>>>>>> 74bda71b0166ce92efa14e7395518c52665ecb87
      receiveTimeout: _client.options.receiveTimeout,
      extra: {if (baseUrl != null) 'custom_base_url': baseUrl},
    );
  }

  dynamic _prepareRequestData(dynamic data) {
    if (data is d.FormData) {
      return data.clone();
    }
    return data;
  }

<<<<<<< HEAD
  /// Prints the server's error body on a failed request. A Laravel 500 with
  /// debug enabled carries `exception`, `file` and `line`, which pinpoint a
  /// server-side crash far better than the surfaced `message` alone.
  void _logErrorBody(d.DioException error) {
    final data = error.response?.data;
    if (data == null) return;
    final text = data.toString();
    debugPrint(
      '[API-ERROR] ${error.requestOptions.method} '
      '${error.requestOptions.uri}\n'
      '${text.length > 2000 ? '${text.substring(0, 2000)}…(truncated)' : text}',
    );
  }

=======
>>>>>>> 74bda71b0166ce92efa14e7395518c52665ecb87
  void _logTiming(d.RequestOptions options, {int? statusCode, String? error}) {
    final startedAt = options.extra['started_at'];
    if (startedAt is! DateTime) {
      return;
    }
    final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
    debugPrint(
      '[API] ${options.method} ${options.uri} '
      'status=${statusCode ?? '-'} '
      'time=${elapsedMs}ms'
      '${error == null ? '' : ' error=$error'}',
    );
  }

  Future<d.Response> get(
    String? path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool? isShowLoading,
    String? customBaseUrl,
  }) async {
    if (path == null) {
      throw 'Path is null';
    }
    final client = _client;

    return client.get(
      path,
      queryParameters: queryParameters,
      options: _buildOptions(headers: headers, baseUrl: customBaseUrl),
    );
  }

  Future<d.Response> post(
    String path,
    dynamic formData, {
    int? retries,
    String? customBaseUrl,
    bool encode = true,
    Map<String, dynamic>? cusHeaders,
    bool? isShowLoading,
<<<<<<< HEAD
    Duration? sendTimeout,
=======
>>>>>>> 74bda71b0166ce92efa14e7395518c52665ecb87
  }) async {
    final client = _client;

    final isMultipart = formData is d.FormData;
    final headers = <String, dynamic>{
      if (cusHeaders != null) ...cusHeaders,
      if (isMultipart) 'Accept': 'application/json',
    };
    if (isMultipart) {
      headers.remove('Content-Type');
      headers.remove('Content-type');
    }

    return client.post(
      path,
      data:
          isMultipart
              ? _prepareRequestData(formData)
              : encode
              ? jsonEncode(formData)
              : formData,
      options: _buildOptions(
        headers: headers,
        contentType: isMultipart ? null : 'application/json',
        baseUrl: customBaseUrl,
<<<<<<< HEAD
        sendTimeout: sendTimeout,
=======
>>>>>>> 74bda71b0166ce92efa14e7395518c52665ecb87
      ),
    );
  }

  Future<d.Response> put(String path, {dynamic formData}) async {
    final client = _client;
    final isMultipart = formData is d.FormData;
    final headers = <String, dynamic>{};
    if (isMultipart) {
      headers['Accept'] = 'application/json';
    }

    return client.put(
      path,
      data: isMultipart ? _prepareRequestData(formData) : jsonEncode(formData),
      options: _buildOptions(
        headers: headers,
        contentType: isMultipart ? null : 'application/json',
      ),
    );
  }

  Future<d.Response> delete(String path, {dynamic data}) async {
    final client = _client;

    return client.delete(path, data: data);
  }

  Future<d.Response> patch(String path, {dynamic formData}) async {
    final client = _client;
    final isMultipart = formData is d.FormData;
    final headers = <String, dynamic>{};
    if (isMultipart) {
      headers['Accept'] = 'application/json';
    }

    return client.patch(
      path,
      data: isMultipart ? _prepareRequestData(formData) : jsonEncode(formData),
      options: _buildOptions(
        headers: headers,
        contentType: isMultipart ? null : 'application/json',
      ),
    );
  }
}
