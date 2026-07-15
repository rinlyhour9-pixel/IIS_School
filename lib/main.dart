import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:schoolapp/core/core.dart';
import 'package:schoolapp/firebase_options.dart';
import 'package:schoolapp/flavor/flavor.dart';
import 'package:schoolapp/routes.dart';
import 'package:logging/logging.dart';
import 'package:upgrader/upgrader.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await dotenv.load(fileName: '.env');
      if (kDebugMode) {
        debugPrint("ENV BASE_URL: ${dotenv.env['BASE_URL']}");
      }

      final isFirebaseReady = await _initializeFirebase();
      if (isFirebaseReady) {
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
      }
      await _initEnvironment();
      await _setAppSystemPreferences();
      await _initServices();

      if (kDebugMode) {
        Logger.root.level = Level.ALL;
        Logger.root.onRecord.listen(customPrint);
      } else {
        Logger.root.level = Level.OFF;
      }
      runApp(const MyApp());
      if (isFirebaseReady) {
        unawaited(_bootstrapDeferredServices());
      }
    },
    (exception, trace) {
      ExceptionHandler.handleException(exception);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'IIS School',
      translationsKeys: AppTranslation.translations,
      locale: AppConfig.shared.languageLocale,
      fallbackLocale: const Locale('KM', 'KH'),
      debugShowCheckedModeBanner: false,
      theme: AppStyle.themeData(
        fontFamily: AppFontFamily.forLanguage(AppConfig.shared.language),
      ),
      //initialRoute: Routes.start,
      initialRoute:
          AppConfig.shared.token.isNotEmpty ? Routes.root : Routes.login,
      getPages: Routes.pages,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);

        return UpgradeAlert(
          barrierDismissible: false,
          showLater: false,
          showIgnore: false,
          dialogStyle:
              Platform.isIOS
                  ? UpgradeDialogStyle.cupertino
                  : UpgradeDialogStyle.material,
          child: GestureDetector(
            onTap: () => KeyboardHelper.dismissKeyboard(),
            child: MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: TextScaler.linear(
                  mediaQueryData.textScaler.scale(1.0).clamp(1.0, 1.125),
                ),
              ),
              child: child!,
            ),
          ),
        );
      },
    );
  }
}

void customPrint(dynamic value) {
  if (kDebugMode) {
    debugPrint('[INFO] : $value');
  }
}

Future<bool> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 8));
    }
    return true;
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('Firebase initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return false;
  }
}

Future<void> _setAppSystemPreferences() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> _initEnvironment() async {
  await AppConfig.shared.setLanguage(Language.kh.key);
}

Future<void> _initServices() async {
  AppConfig.shared;
  await _restoreUserSessionFromStorage();
  Get.put<ApiService>(ApiService());
  await Get.put<SelectedStudentService>(SelectedStudentService()).initialize();
}

Future<void> _restoreUserSessionFromStorage() async {
  final token =
      (await SharedPreferencesManager.get(Credential.token.name) ?? '')
          .toString()
          .trim();
  AppConfig.shared.token = token;

  await UserRepository.shared.restoreUserTypeFromStorage();
}

Future<void> _bootstrapDeferredServices() async {
  try {
    await FirebaseMessaging.instance.requestPermission();
    await HomeworkNotificationService.instance.initialize();
    await FcmTokenSyncService.instance.initialize();

    unawaited(ClassTopicSubscriptionService.instance.syncSelectedClassTopic());
    unawaited(HomeworkNotificationService.instance.handleInitialMessage());
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('Deferred service bootstrap failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
