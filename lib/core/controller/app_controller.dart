import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart' as im;
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openim/core/im_callback.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:vibration/vibration.dart';

import '../../utils/upgrade_manager.dart';
import '../../utils/device_capability_detector.dart';
import 'im_controller.dart';

class AppController extends GetxController with UpgradeManger, WidgetsBindingObserver {
  var isRunningBackground = false;
  AppLifecycleState? _lastLifecycleState;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final DarwinInitializationSettings initializationSettingsDarwin = const DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  MeetingBridge? get meetingBridge => PackageBridge.meetingBridge;

  RTCBridge? get rtcBridge => PackageBridge.rtcBridge;

  bool get shouldMuted => meetingBridge?.hasConnection == true || rtcBridge?.hasConnection == true;

  final _ring = 'assets/audio/message_ring.wav';
  final _audioPlayer = AudioPlayer();
  bool _isPlayingSound = false; // Lock to prevent concurrent playback
  DateTime? _lastVibrationTime; // Track last vibration time for debounce
  static const _vibrationDebounceMs = 1000; // Vibrate at most once per second
  final configuration = const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.ambient,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
    androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
    androidAudioAttributes: AndroidAudioAttributes(
      contentType: AndroidAudioContentType.sonification,
      usage: AndroidAudioUsage.notification,
    ),
  );
  late AudioSession session;

  late BaseDeviceInfo deviceInfo;

  /// discoverPageURL
  /// ordinaryUserAddFriend,
  /// bossUserID,
  /// adminURL ,
  /// allowSendMsgNotFriend
  /// needInvitationCodeRegister
  /// robots
  final clientConfigMap = <String, dynamic>{}.obs;

  final _networkMonitor = NetworkMonitor();

  Future<void> runningBackground(bool run) async {
    Logger.print('-----App running background : $run-------------');

    if (isRunningBackground && !run) {}
    isRunningBackground = run;
    if (!run) {
      _cancelAllNotifications();
    }
  }

  @override
  void onInit() async {
    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Initialize voice message click records
    await IMUtils.initVoiceMessageClickMap();

    Future.delayed(2.seconds, () async {
      _networkMonitor.onNetworkChanged((status) async {
        bool isAvailable = await _networkMonitor.isNetworkAvailable();

        if (!isAvailable) {
          Toast.show(Get.context!, StrRes.networkNotStable);
        }
      });
    });
    // _requestPermissions();
    _initPlayer();
    _initPhoneNumberLibrary();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {},
    );
    // autoCheckVersionUpgrade();
    super.onInit();
  }

  Future<void> showNotification(im.Message message, {bool showNotification = true}) async {
    if (_isGlobalNotDisturb() ||
        message.attachedInfoElem?.notSenderNotificationPush == true ||
        message.contentType == im.MessageType.typing ||
        message.sendID == OpenIM.iMManager.userID ||
        (message.contentType! >= 1000 && message.contentType != 1400)) return;

    // 开启免打扰的不提示
    var sourceID = message.sessionType == ConversationType.single ? message.sendID : message.groupID;
    if (sourceID != null && message.sessionType != null) {
      var i = await OpenIM.iMManager.conversationManager.getOneConversation(
        sourceID: sourceID,
        sessionType: message.sessionType!,
      );
      if (i.recvMsgOpt != 0) return;
    }

    if (showNotification) {
      promptSoundOrNotification(message.seq!);
    }
  }

  Future<void> promptSoundOrNotification(int seq) async {
    final sdkStatus = Get.find<IMController>().imSdkStatusSubject.values.lastOrNull?.status;
    if (sdkStatus != null && sdkStatus != IMSdkStatus.syncEnded) {
      return;
    }
    if (!isRunningBackground) {
      _playMessageSound();
    } else {
      if (Platform.isAndroid) {
        final id = seq;

        final androidPlatformChannelSpecifics = AndroidNotificationDetails('chat', StrRes.home,
            channelDescription: StrRes.home, importance: Importance.max, priority: Priority.high, ticker: 'ticker');
        final NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin
            .show(id, StrRes.offlineMessage, StrRes.offlineMessage, platformChannelSpecifics, payload: '');
      }
    }
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void showBadge(count) {
    OpenIM.iMManager.messageManager.setAppBadge(count);

    if (count == 0) {
      removeBadge();
      Get.find<PushController>().resetBadge();
    } else {
      AppBadgePlus.isSupported().then((value) {
        if (value) {
          AppBadgePlus.updateBadge(count);
        }
      });

      Get.find<PushController>().setBadge(count);
    }
  }

  void removeBadge() {
    Logger.print('removeBadge');
    AppBadgePlus.isSupported().then((value) {
      if (value) {
        AppBadgePlus.updateBadge(0);
      }
    });
  }

  @override
  void onClose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    // backgroundSubject.close();
    // _stopForegroundService();
    closeSubject();
    _audioPlayer.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Log for debugging old Android device issues
    Logger.print('[AppLifecycle] State changed from $_lastLifecycleState to $state', fileName: 'app_controller.dart');

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        Logger.print('[AppLifecycle] App is inactive', fileName: 'app_controller.dart');
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        Logger.print('[AppLifecycle] App is hidden', fileName: 'app_controller.dart');
        break;
    }

    _lastLifecycleState = state;
  }

  void _onAppResumed() {
    Logger.print('[AppLifecycle] App resumed - now in foreground', fileName: 'app_controller.dart');

    // Cancel notifications when app comes to foreground
    _cancelAllNotifications();

    // Log device state for debugging on old Android devices
    if (Platform.isAndroid) {
      Logger.print('[AppLifecycle] Android device info: ${deviceInfo.data}', fileName: 'app_controller.dart');
    }
  }

  void _onAppPaused() {
    Logger.print('[AppLifecycle] App paused - going to background', fileName: 'app_controller.dart');

    // Stop any playing sounds
    _stopMessageSound();

    // Save critical state if needed
    // Note: For old devices, this is the last chance to save before potential process kill
  }

  void _onAppDetached() {
    Logger.print('[AppLifecycle] App detached - process is terminating', fileName: 'app_controller.dart');

    // Cleanup resources
    _stopMessageSound();
  }

  Locale? getLocale() {
    var local = Get.locale;
    var index = DataSp.getLanguage() ?? 0;
    switch (index) {
      case 1:
        local = const Locale('zh', 'CN');
        break;
      case 2:
        local = const Locale('en', 'US');
        break;
    }
    return local;
  }

  @override
  void onReady() {
    // _startForegroundService();
    queryClientConfig();
    _getDeviceInfo();
    _cancelAllNotifications();

    // Detect and log device capabilities for debugging old Android device issues
    _detectAndLogDeviceCapabilities();

    super.onReady();
  }

  Future<void> _detectAndLogDeviceCapabilities() async {
    try {
      await DeviceCapabilityDetector.logDeviceInfo();
      await DeviceCapabilityDetector.applyLowEndOptimizations();
    } catch (e) {
      Logger.print('[AppController] Error detecting device capabilities: $e', fileName: 'app_controller.dart');
    }
  }

  /// 全局免打扰
  bool _isGlobalNotDisturb() {
    bool isRegistered = Get.isRegistered<IMController>();
    if (isRegistered) {
      var logic = Get.find<IMController>();
      return logic.userInfo.value.globalRecvMsgOpt == 2;
    }
    return false;
  }

  void _initPlayer() async {
    session = await AudioSession.instance;
    await session.configure(configuration);

    _audioPlayer.setAsset(_ring, package: 'openim_common');
    _audioPlayer.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
        case ProcessingState.loading:
        case ProcessingState.buffering:
        case ProcessingState.ready:
          break;
        case ProcessingState.completed:
          _stopMessageSound();
          // _audioPlayer.seek(null);
          break;
      }
    });
  }

  /// Initialize flutter_libphonenumber for phone number validation
  Future<void> _initPhoneNumberLibrary() async {
    try {
      await PhoneNumberValidator().init();
      Logger.print('[AppController] PhoneNumberValidator initialized successfully', fileName: 'app_controller.dart');
    } catch (e) {
      Logger.print('[AppController] Failed to initialize PhoneNumberValidator: $e', fileName: 'app_controller.dart');
    }
  }

  /// 播放提示音
  void _playMessageSound() async {
    if (shouldMuted) {
      return;
    }

    // CRITICAL: Check lock FIRST before any async operations
    // This prevents concurrent calls from interfering with audio playback
    if (_isPlayingSound) {
      return;
    }

    _isPlayingSound = true; // Set lock IMMEDIATELY before any async operation

    try {
      bool isRegistered = Get.isRegistered<IMController>();
      bool isAllowVibration = true;
      bool isAllowBeep = true;
      if (isRegistered) {
        var logic = Get.find<IMController>();
        isAllowVibration = logic.userInfo.value.allowVibration == 1;
        isAllowBeep = logic.userInfo.value.allowBeep == 1;
      }

      RingerModeStatus ringerStatus = await SoundMode.ringerModeStatus;

      // Handle vibration FIRST (quick operation)
      if (isAllowVibration &&
          (ringerStatus == RingerModeStatus.normal ||
              ringerStatus == RingerModeStatus.vibrate ||
              ringerStatus == RingerModeStatus.unknown)) {
        final now = DateTime.now();
        final shouldVibrate =
            _lastVibrationTime == null || now.difference(_lastVibrationTime!).inMilliseconds >= _vibrationDebounceMs;

        if (shouldVibrate) {
          if (await Vibration.hasVibrator()) {
            Vibration.vibrate();
            _lastVibrationTime = now;
          }
        }
      }

      // Handle sound playback
      if (!isAllowBeep || ringerStatus == RingerModeStatus.silent) {
        _isPlayingSound = false; // Release lock - no sound to play
        return;
      }

      if (ringerStatus != RingerModeStatus.normal && ringerStatus != RingerModeStatus.unknown) {
        _isPlayingSound = false; // Release lock - ringer mode not suitable
        return;
      }

      try {
        // CRITICAL: Force complete reset to idle state
        // Stop any current playback and wait for player to become truly idle
        try {
          await _audioPlayer.stop();
          await _audioPlayer.setAsset(_ring, package: 'openim_common'); // Preload immediately
        } catch (e) {
          // If stop or preload fails, continue
        }

        // Now configure and play
        await session.setActive(true);
        await _audioPlayer.setLoopMode(LoopMode.off);
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.play();

        // Lock will be released by _stopMessageSound when playback completes
      } catch (e) {
        Logger.print('Error playing audio: $e', fileName: 'app_controller.dart');
        _isPlayingSound = false; // Release lock on error
      }
    } catch (e) {
      Logger.print('Unexpected error in _playMessageSound: $e', fileName: 'app_controller.dart');
      _isPlayingSound = false; // Release lock on unexpected error
    }
  }

  /// 关闭提示音
  void _stopMessageSound() async {
    if (_audioPlayer.playerState.playing) {
      _audioPlayer.stop();
    }
    await session.setActive(false);

    // Release the lock when sound stops
    _isPlayingSound = false;
  }

  void _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    deviceInfo = await deviceInfoPlugin.deviceInfo;
  }

  Future queryClientConfig() async {
    final map = await Apis.getClientConfig();
    clientConfigMap.assignAll(map);

    return clientConfigMap;
  }
}
