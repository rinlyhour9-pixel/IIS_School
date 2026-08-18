import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:schoolapp/core/utils/utils.dart';

class ExceptionHandler {
  ExceptionHandler._();
  static DateTime? _lastDialogAt;
  static String _lastDialogMessage = '';

  static void handleException(
    dynamic error, {
    bool alert = true,
    Function(dynamic)? onValue,
  }) {
    if (!alert) {
      return;
    }

    const String title = 'Error';
    String subTitle = 'Unknown error';

    if (error is DioException) {
      if (_shouldSilenceDio(error)) {
        final transientMessage = _mapDioException(error).trim();
        if (transientMessage.isNotEmpty) {
          DialogManager.showTopBanner(
            title: 'Network',
            message: transientMessage,
            backgroundColor: const Color(0xFFB45309),
          );
        }
        return;
      }

      final mapped = _mapDioException(error);
      if (mapped.isNotEmpty) {
        subTitle = mapped;
      }

      final res = error.response;
      if (res != null) {
        if (res.data is Map) {
          final data = Map<String, dynamic>.from(res.data);
          final message =
              data['message']?.toString().trim() ??
              data['error']?.toString().trim() ??
              data['detail']?.toString().trim() ??
              '';
          subTitle = message.isEmpty ? subTitle : message;
        } else {
          final raw = res.data?.toString().trim() ?? '';
          subTitle = raw.isEmpty ? subTitle : raw;
        }
      }
    } else if (error is String) {
      subTitle = error.trim();
    } else {
      subTitle = 'Something went wrong ($error)';
    }

    final message = subTitle.trim();
    if (_shouldSilenceMessage(message)) {
      return;
    }

    try {
      DialogManager.showDialog(
        title: title,
        subTitle: message.isEmpty ? 'Something went wrong' : message,
      ).then((value) {
        if (onValue == null) {
          return;
        }
        onValue(value);
      });
    } catch (dialogError, stackTrace) {
      if (kDebugMode) {
        debugPrint('Failed to present error dialog: $dialogError');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  static String _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check internet and try again.';
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Server is taking too long to respond. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        final msg = error.message?.trim() ?? '';
        if (msg.contains('SocketException')) {
          return 'No internet connection. Please check your network.';
        }
        return msg;
    }
  }

  static bool _shouldSilenceDio(DioException error) {
    if (error.type == DioExceptionType.cancel) {
      return true;
    }

    final hasNoResponse = error.response == null;
    final isTransientNetwork =
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown;

    if (!hasNoResponse || !isTransientNetwork) {
      return false;
    }

    final raw = (error.message ?? '').toLowerCase();
    return raw.contains('socketexception') ||
        raw.contains('timed out') ||
        raw.contains('connection');
  }

  static bool _shouldSilenceMessage(String message) {
    if (message.isEmpty || message.toLowerCase() == 'unknown error') {
      return true;
    }

    final now = DateTime.now();
    final isDuplicate =
        _lastDialogMessage == message &&
        _lastDialogAt != null &&
        now.difference(_lastDialogAt!) < const Duration(seconds: 4);
    if (isDuplicate) {
      return true;
    }

    _lastDialogMessage = message;
    _lastDialogAt = now;
    return false;
  }
}
