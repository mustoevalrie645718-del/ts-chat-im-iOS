import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:getuiflut/getuiflut.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';
import 'package:openim_common/openim_common.dart';

import 'firebase_options.dart';

enum PushType { getui, fcm, jPush, none }

class PushConfig {
  final String appID;
  final String appKey;
  final String appSecret;
  final String channel;
  final bool production;
  final bool debug;

  const PushConfig({
    required this.appID,
    required this.appKey,
    required this.appSecret,
    this.channel = '',
    this.production = true,
    this.debug = true,
  });
}

abstract class IPushService {
  Future<void> initialize();
  Future<void> login(String alias, {void Function(String token)? onTokenRefresh});
  Future<void> logout();
  Future<void> setBadge(int badge);
  Future<void> resetBadge();
  Future<void> dispose();
}

class PushServiceFactory {
  static IPushService createService(PushType type, PushConfig config) {
    switch (type) {
      case PushType.getui:
        return GetuiPushService(config);
      case PushType.fcm:
        return FCMPushService(config);
      case PushType.jPush:
        return JPushService(config);
      case PushType.none:
        return NonePushService();
    }
  }
}

class PushController extends GetxService {
  late final IPushService _pushService;
  final PushType _pushType;
  final PushConfig _config;

  PushController({
    required PushType pushType,
    required PushConfig config,
  })  : _pushType = pushType,
        _config = config;

  @override
  void onInit() {
    super.onInit();
    _pushService = PushServiceFactory.createService(_pushType, _config);
    _initializePushService();
  }

  @override
  void onClose() {
    _pushService.dispose();
    super.onClose();
  }

  Future<void> _initializePushService() async {
    try {
      await _pushService.initialize();
    } catch (e) {
      Logger.print('Failed to initialize push service: $e');
    }
  }

  Future<void> login(String alias, {void Function(String token)? onTokenRefresh}) async {
    if (alias.isEmpty) {
      throw ArgumentError('Alias cannot be empty');
    }

    try {
      await _pushService.login(alias, onTokenRefresh: onTokenRefresh);
    } catch (e) {
      Logger.print('Push login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _pushService.logout();
    } catch (e) {
      Logger.print('Push logout error: $e');
      rethrow;
    }
  }

  Future<void> setBadge(int badge) async {
    try {
      await _pushService.setBadge(badge);
    } catch (e) {
      Logger.print('Set badge error: $e');
      rethrow;
    }
  }

  Future<void> resetBadge() async {
    try {
      await _pushService.resetBadge();
    } catch (e) {
      Logger.print('Reset badge error: $e');
      rethrow;
    }
  }

  PushType get pushType => _pushType;
}

class GetuiPushService implements IPushService {
  final PushConfig _config;
  final Getuiflut _sdk = Getuiflut();
  bool _isInitialized = false;

  GetuiPushService(this._config);

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final isGranted = await Permissions.notification();
      if (!isGranted) {
        throw Exception('Notification permission not granted');
      }

      if (Platform.isIOS) {
        _sdk.startSdk(
          appId: _config.appID,
          appKey: _config.appKey,
          appSecret: _config.appSecret,
        );
        _sdk.runBackgroundEnable(0);
      }

      _addEventHandlers();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Getui SDK: $e');
    }
  }

  void _addEventHandlers() {
    _sdk.addEventHandler(
      onReceiveClientId: (String message) async {
        Logger.print("Getui onReceiveClientId: $message");
      },
      onRegisterDeviceToken: (String message) async {
        Logger.print("Getui onRegisterDeviceToken: $message");
      },
      onReceivePayload: (Map<String, dynamic> message) async {
        Logger.print("Getui onReceivePayload: $message");
      },
      onReceiveNotificationResponse: (Map<String, dynamic> message) async {
        Logger.print("Getui onReceiveNotificationResponse: $message");
      },
      onAppLinkPayload: (String message) async {
        Logger.print("Getui onAppLinkPayload: $message");
      },
      onReceiveOnlineState: (online) async {
        Logger.print("Getui onReceiveOnlineState: $online");
      },
      onPushModeResult: (Map<String, dynamic> message) async {
        Logger.print("Getui onPushModeResult: $message");
      },
      onSetTagResult: (Map<String, dynamic> message) async {
        Logger.print("Getui onSetTagResult: $message");
      },
      onAliasResult: (Map<String, dynamic> message) async {
        Logger.print("Getui onAliasResult: $message");
      },
      onQueryTagResult: (Map<String, dynamic> message) async {
        Logger.print("Getui onQueryTagResult: $message");
      },
      onWillPresentNotification: (Map<String, dynamic> message) async {
        Logger.print("Getui onWillPresentNotification: $message");
      },
      onOpenSettingsForNotification: (Map<String, dynamic> message) async {
        Logger.print("Getui onOpenSettingsForNotification: $message");
      },
      onGrantAuthorization: (String granted) async {
        Logger.print("Getui onGrantAuthorization: $granted");
      },
      onNotificationMessageArrived: (Map<String, dynamic> event) async {
        Logger.print("Getui onNotificationMessageArrived: $event");
      },
      onNotificationMessageClicked: (Map<String, dynamic> event) async {
        Logger.print("Getui onNotificationMessageClicked: $event");
      },
      onTransmitUserMessageReceive: (Map<String, dynamic> event) async {
        Logger.print("Getui onTransmitUserMessageReceive: $event");
      },
      onLiveActivityResult: (Map<String, dynamic> event) async {
        Logger.print("Getui onLiveActivityResult: $event");
      },
      onRegisterPushToStartTokenResult: (Map<String, dynamic> event) async {
        Logger.print("Getui onRegisterPushToStartTokenResult: $event");
      },
    );
  }

  @override
  Future<void> login(String alias, {void Function(String token)? onTokenRefresh}) async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }

    try {
      final clientId = await _sdk.getClientId;
      Logger.print('Getui login user ID: $alias, client id: $clientId');
      _sdk.bindAlias(alias, 'openim');
    } catch (e) {
      throw Exception('Failed to login to Getui: $e');
    }
  }

  @override
  Future<void> logout() async {
    if (!_isInitialized) return;

    try {
      _sdk.unbindAlias(OpenIM.iMManager.userID, 'openim', true);
    } catch (e) {
      Logger.print('Getui logout error: $e');
    }
  }

  @override
  Future<void> setBadge(int badge) async {
    if (!_isInitialized) return;

    try {
      _sdk.setBadge(badge);
    } catch (e) {
      Logger.print('Getui setBadge error: $e');
    }
  }

  @override
  Future<void> resetBadge() async {
    if (!_isInitialized) return;

    try {
      _sdk.resetBadge();
    } catch (e) {
      Logger.print('Getui resetBadge error: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}

class FCMPushService implements IPushService {
  bool _isInitialized = false;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _backgroundSubscription;

  FCMPushService(PushConfig config);

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Platform.isAndroid) {
        final availability = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
        if (availability != GooglePlayServicesAvailability.success) {
          throw Exception('Google Play Services not available');
        }
      }

      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      await _requestPermission();
      _configureNotifications();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize FCM: $e');
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      Logger.print('FCM permission status: ${settings.authorizationStatus}');
    } catch (e) {
      Logger.print('Failed to request FCM permission: $e');
    }
  }

  void _configureNotifications() {
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        Logger.print('FCM foreground message: ${message.notification?.title}');
      },
      onError: (e) {
        Logger.print('FCM foreground message error: $e');
      },
    );

    _backgroundSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        Logger.print('FCM background message opened: ${message.notification?.title}');
      },
      onError: (e) {
        Logger.print('FCM background message error: $e');
      },
    );
  }

  @override
  Future<void> login(String alias, {void Function(String token)? onTokenRefresh}) async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      Logger.print('FCM token: $token');

      if (onTokenRefresh != null && token != null) {
        onTokenRefresh(token);
      }

      if (onTokenRefresh != null) {
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          Logger.print('FCM token refreshed: $newToken');
          onTokenRefresh(newToken);
        });
      }
    } catch (e) {
      throw Exception('Failed to get FCM token: $e');
    }
  }

  @override
  Future<void> logout() async {
    if (!_isInitialized) return;

    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      Logger.print('FCM logout error: $e');
    }
  }

  @override
  Future<void> setBadge(int badge) async {
    Logger.print('FCM setBadge not supported directly');
  }

  @override
  Future<void> resetBadge() async {
    Logger.print('FCM resetBadge not supported directly');
  }

  @override
  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _backgroundSubscription?.cancel();
    _isInitialized = false;
  }
}

class JPushService implements IPushService {
  final PushConfig _config;
  final JPushFlutterInterface _sdk = JPush.newJPush();
  bool _isInitialized = false;

  JPushService(this._config);

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _addEventHandlers();

      _sdk.setAuth(enable: true);
      _sdk.setup(
        appKey: _config.appKey,
        channel: _config.channel,
        production: _config.production,
        debug: _config.debug,
      );

      if (Platform.isIOS) {
        _sdk.applyPushAuthority(const NotificationSettingsIOS(
          sound: true,
          alert: true,
          badge: true,
        ));
      }

      final rid = await _sdk.getRegistrationID();
      Logger.print('JPush registration ID: $rid');

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize JPush: $e');
    }
  }

  void _addEventHandlers() {
    try {
      _sdk.setCallBackHarmony((eventName, data) {
        Logger.print('JPush harmony callback: $eventName, $data');
      });

      _sdk.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
          Logger.print('JPush onReceiveNotification: $message');
        },
        onOpenNotification: (Map<String, dynamic> message) async {
          Logger.print('JPush onOpenNotification: $message');
        },
        onReceiveMessage: (Map<String, dynamic> message) async {
          Logger.print('JPush onReceiveMessage: $message');
        },
        onReceiveNotificationAuthorization: (Map<String, dynamic> message) async {
          Logger.print('JPush onReceiveNotificationAuthorization: $message');
        },
        onNotifyMessageUnShow: (Map<String, dynamic> message) async {
          Logger.print('JPush onNotifyMessageUnShow: $message');
        },
        onInAppMessageShow: (Map<String, dynamic> message) async {
          Logger.print('JPush onInAppMessageShow: $message');
        },
        onCommandResult: (Map<String, dynamic> message) async {
          Logger.print('JPush onCommandResult: $message');
        },
        onInAppMessageClick: (Map<String, dynamic> message) async {
          Logger.print('JPush onInAppMessageClick: $message');
        },
        onConnected: (Map<String, dynamic> message) async {
          Logger.print('JPush onConnected: $message');
        },
      );
    } on PlatformException catch (e) {
      Logger.print('JPush event handler setup failed: $e');
    }
  }

  @override
  Future<void> login(String alias, {void Function(String token)? onTokenRefresh}) async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }

    try {
      await _sdk.setAlias(alias);
      Logger.print('JPush login with alias: $alias');
    } catch (e) {
      throw Exception('Failed to login to JPush: $e');
    }
  }

  @override
  Future<void> logout() async {
    if (!_isInitialized) return;

    try {
      await _sdk.deleteAlias();
      Logger.print('JPush logout completed');
    } catch (e) {
      Logger.print('JPush logout error: $e');
    }
  }

  @override
  Future<void> setBadge(int badge) async {
    if (!_isInitialized) return;

    try {
      _sdk.setBadge(badge);
    } catch (e) {
      Logger.print('JPush setBadge error: $e');
    }
  }

  @override
  Future<void> resetBadge() async {
    if (!_isInitialized) return;

    try {
      _sdk.clearAllNotifications();
    } catch (e) {
      Logger.print('JPush resetBadge error: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}

class NonePushService implements IPushService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> login(String alias, {void Function(String token)? onTokenRefresh}) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> setBadge(int badge) async {}

  @override
  Future<void> resetBadge() async {}

  @override
  Future<void> dispose() async {}
}