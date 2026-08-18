import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:schoolapp/core/libraries/shared_preferences.dart';
import 'package:schoolapp/core/repositories/user.dart';
import 'package:schoolapp/core/services/fcm_token_sync_service.dart';

class ClassTopicSubscriptionService {
  ClassTopicSubscriptionService._();

  static final ClassTopicSubscriptionService instance =
      ClassTopicSubscriptionService._();

  static const String _lastTopicKey = 'last_class_topic_subscription';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  Future<void> syncSelectedClassTopic() async {
    final notificationsEnabled =
        ((await SharedPreferencesManager.get(_notificationsEnabledKey) ?? 'true')
                .toString()
                .trim()
                .toLowerCase() !=
            'false');
    if (!notificationsEnabled) {
      await _unsubscribePreviousTopic();
      return;
    }

    if (!UserRepository.shared.isParent) {
      await _unsubscribePreviousTopic();
      return;
    }

    final classId =
        (await SharedPreferencesManager.get('selected_child_class_id') ?? '')
            .toString()
            .trim();
    final nextTopic = classId.isEmpty ? '' : 'class_$classId';
    final previousTopic =
        (await SharedPreferencesManager.get(_lastTopicKey) ?? '')
            .toString()
            .trim();

    if (previousTopic.isNotEmpty && previousTopic != nextTopic) {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic(previousTopic);
      } catch (e) {
        debugPrint('Failed to unsubscribe from topic $previousTopic: $e');
      }
    }

    if (nextTopic.isEmpty) {
      await SharedPreferencesManager.setValue(_lastTopicKey, '');
      return;
    }

    try {
      await FcmTokenSyncService.instance.waitForApnsTokenIfNeeded();
      await FirebaseMessaging.instance.subscribeToTopic(nextTopic);
      await SharedPreferencesManager.setValue(_lastTopicKey, nextTopic);
      debugPrint('Subscribed to class topic: $nextTopic');
    } catch (e) {
      debugPrint('Failed to subscribe to topic $nextTopic: $e');
    }
  }

  Future<void> clearSubscription() async {
    await _unsubscribePreviousTopic();
  }

  Future<void> _unsubscribePreviousTopic() async {
    final previousTopic =
        (await SharedPreferencesManager.get(_lastTopicKey) ?? '')
            .toString()
            .trim();
    if (previousTopic.isEmpty) {
      return;
    }
    

    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(previousTopic);
    } catch (e) {
      debugPrint('Failed to unsubscribe from topic $previousTopic: $e');
    }
    await SharedPreferencesManager.setValue(_lastTopicKey, '');
  }
}
