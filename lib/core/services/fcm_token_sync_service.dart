import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:dio/dio.dart' as d;
import 'package:schoolapp/core/constants/storage_key.dart';
import 'package:schoolapp/core/libraries/shared_preferences.dart';
import 'package:schoolapp/core/services/api_service.dart';
import 'package:schoolapp/core/services/end_points.dart';
import 'package:schoolapp/flavor/app_config.dart';

class FcmTokenSyncService {
  FcmTokenSyncService._();

  static final FcmTokenSyncService instance = FcmTokenSyncService._();

  static const String _lastSyncedTokenKey = 'last_synced_fcm_token';
  static const bool _backendTokenSyncEndpointEnabled = false;
  static const int _apnsTokenRetries = 6;
  static const Duration _apnsTokenRetryDelay = Duration(seconds: 2);

  final Logger _logger = Logger('FcmTokenSyncService');
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) {
        unawaited(syncToken(token, force: true));
      },
      onError: (Object error, StackTrace stackTrace) {
        _logger.warning(
          'Unable to listen for FCM token refresh',
          error,
          stackTrace,
        );
      },
    );

    _initialized = true;
    unawaited(syncCurrentTokenIfAuthenticated());
  }

  Future<void> syncCurrentTokenIfAuthenticated({bool force = false}) async {
    try {
      final token = await getCurrentToken();
      if (token == null || token.trim().isEmpty) return;
      debugPrint('FCM token: ${token.trim()}');
      await syncToken(token, force: force);
    } on FirebaseException catch (error, stackTrace) {
      if (_isApnsTokenUnavailable(error)) {
        if (kDebugMode) {
          debugPrint('FCM token sync skipped: APNS token is not ready yet.');
        }
        return;
      }
      _logger.warning('Unable to read FCM token', error, stackTrace);
    } catch (error, stackTrace) {
      _logger.warning('Unable to read FCM token', error, stackTrace);
    }
  }

  Future<String?> getCurrentToken({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    await waitForApnsTokenIfNeeded();
    return FirebaseMessaging.instance.getToken().timeout(
      timeout,
      onTimeout: () => null,
    );
  }

  Future<void> syncToken(String token, {bool force = false}) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) return;
    debugPrint('FCM token: $normalizedToken');

    if (!_backendTokenSyncEndpointEnabled) {
      if (kDebugMode) {
        debugPrint(
          'FCM token sync endpoint disabled; token is sent during login.',
        );
      }
      return;
    }

    final authToken = await _ensureAccessToken();
    if (authToken.isEmpty) return;

    final lastSyncedToken =
        (await SharedPreferencesManager.get(_lastSyncedTokenKey) ?? '')
            .toString()
            .trim();
    if (!force && lastSyncedToken == normalizedToken) return;

    try {
      final api = Get.find<ApiService>();
      await api.post(EndPoints.registerFcmToken, {
        'fcm_token': normalizedToken,
        'platform': _platformName,
        'device_name': _platformName,
      });
      await SharedPreferencesManager.setValue(
        _lastSyncedTokenKey,
        normalizedToken,
      );
    } catch (error, stackTrace) {
      if (error is d.DioException) {
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        _logger.warning(
          'Unable to sync FCM token to backend '
          '(status=$statusCode, response=$responseData)',
          error,
          stackTrace,
        );
        return;
      }
      _logger.warning('Unable to sync FCM token to backend', error, stackTrace);
    }
  }

  Future<String> _ensureAccessToken() async {
    if (AppConfig.shared.authorizationToken.isNotEmpty) {
      return AppConfig.shared.authorizationToken;
    }

    final rawToken =
        (await SharedPreferencesManager.get(Credential.token.name) ?? '')
            .toString()
            .trim();
    if (rawToken.isEmpty) return '';

    AppConfig.shared.token = rawToken;
    return AppConfig.shared.authorizationToken;
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  bool _isApnsTokenUnavailable(FirebaseException error) {
    return error.plugin == 'firebase_messaging' &&
        error.code == 'apns-token-not-set';
  }

  Future<void> waitForApnsTokenIfNeeded() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    for (var attempt = 0; attempt < _apnsTokenRetries; attempt++) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null && apnsToken.trim().isNotEmpty) {
        debugPrint('APNS token: ${apnsToken.trim()}');
        return;
      }
      await Future<void>.delayed(_apnsTokenRetryDelay);
    }

    if (kDebugMode) {
      debugPrint('APNS token is still not ready after waiting.');
    }
  }
}
