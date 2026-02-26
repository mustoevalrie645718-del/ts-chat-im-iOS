import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_common/src/utils/api_service.dart';
import 'package:path_provider/path_provider.dart';

class Config {
  // Private constructor to prevent instantiation
  Config._();

  // Constants for UI dimensions and text scaling
  static const double uiWidth = 375.0;
  static const double uiHeight = 812.0;
  static const double textScaleFactor = 1.0;

  // URLs and keys
  static const String discoverPageUrl = 'https://docs.openim.io/';
  static const String allowSendMsgNotFriend = '1';
  static const String webKey = '75a0da9ec836d573102999e99abf4650';
  static const String webServerKey = '835638634b8f9b4bba386eeec94aa7df';
  static const String locationHost = 'http://location.xxx.xx';

  // Schemes for QR codes
  static const String friendScheme = 'io.openim.app/addFriend/';
  static const String groupScheme = 'io.openim.app/joinGroup/';

  // Default offline push configuration
  static final OfflinePushInfo offlinePushInfo = OfflinePushInfo(
    title: 'OpenIM',
    desc: StrRes.offlineMessage,
    iOSBadgeCount: true,
    iOSPushSound: 'default',
  );

  static const PushType pushType = PushType.fcm;
  // getui / jpush
  // should config build.gradle for android 
  static const PushConfig pushConfig = PushConfig(
    appID: 'avwNcfSXbVATxuO6MkYz08',
    appKey: 'VsP3NAEP9L9KMnQizOXm59',
    appSecret: 'AikvZ75Xdl7Fkzz6Rz0qb9',
  );
  // Server configuration
  // web.openim.io
  static const String _defaultHost = 'chat.xmmenye.com';
  // static const String _defaultHost = 'chat.hfvmir.cn';
  // static const String _defaultHost = 'test.rentsoft.cn';
  static const String _ipRegex = r'((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)';
  static late String cachePath;

  // Initialize global configurations
  static Future<void> init(VoidCallback runApp) async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initializeServices();
    runApp();
    await _configureSystemUI();
  }

  // Initialize required services
  static Future<void> _initializeServices() async {
    try {
      // Set cache path
      cachePath = '${(await getApplicationDocumentsDirectory()).path}/';

      // Initialize dependencies
      await Future.wait<void>([
        DataSp.init(),
        Hive.initFlutter(cachePath),
      ]);

      MediaKit.ensureInitialized();
      HttpUtil.init();
      ApiService().setBaseUrl(imApiUrl);
    } catch (e, stackTrace) {
      Logger.print('Initialization error: $e\n$stackTrace');
    }
  }

  // Configure system UI (screen orientation and status bar)
  static Future<void> _configureSystemUI() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final brightness = Platform.isAndroid ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
    ));
  }

  // Check if host is an IP address
  static bool get _isIp => RegExp(_ipRegex).hasMatch(_defaultHost);

  // Get server configuration from storage or default
  static Map<String, dynamic>? _getServerConfig() {
    final server = DataSp.getServerConfig() as Map<String, dynamic>?;
    if (server != null) {
      Logger.print('Server config loaded: $server');
    }
    return server;
  }

  // Server IP address
  static String get serverIp => _getServerConfig()?['serverIP'] ?? _defaultHost;

  // URL getters with caching and fallback
  static String get chatTokenUrl {
    final url = _getServerConfig()?['chatTokenUrl'];
    return url ?? (_isIp ? 'http://$_defaultHost:10009' : 'https://$_defaultHost/chat');
  }

  static String get appAuthUrl {
    final url = _getServerConfig()?['authUrl'];
    return url ?? (_isIp ? 'http://$_defaultHost:10008' : 'https://$_defaultHost/chat');
  }

  static String get imApiUrl {
    final url = _getServerConfig()?['apiUrl'];
    return url ?? (_isIp ? 'http://$_defaultHost:10002' : 'https://$_defaultHost/api');
  }

  static String get imWsUrl {
    final url = _getServerConfig()?['wsUrl'];
    return url ?? (_isIp ? 'ws://$_defaultHost:10001' : 'wss://$_defaultHost/msg_gateway');
  }

  // Log level configuration
  static int get logLevel {
    final level = _getServerConfig()?['logLevel'];
    return level != null ? int.parse(level) : 5;
  }

  static String get robotApiUrl {
    final url = _getServerConfig()?['robotApiUrl'];

    return url ?? (_isIp ? 'http://$_defaultHost:10010' : 'https://$_defaultHost/agent');
  }
}
