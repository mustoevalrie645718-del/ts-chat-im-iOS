import 'dart:async';
import 'dart:io';

import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:rxdart/rxdart.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();

  factory LiveKitService() => _instance;

  LiveKitService._internal();

  Room? _room;
  final _roomSubject = BehaviorSubject<Room?>();
  Stream<Room?> get roomStream => _roomSubject.stream;

  Room? get room => _room;

  final _roomEventsSubject = PublishSubject<RoomEvent>();
  Stream<RoomEvent> get roomEventsStream => _roomEventsSubject.stream;

  final _participantEventsSubject = PublishSubject<ParticipantEvent>();
  Stream<ParticipantEvent> get participantEventsStream => _participantEventsSubject.stream;

  EventsListener<RoomEvent>? _listener;

  Future<void> connect(String url, String token) async {
    Logger.print('[Livekit service] connect');
    if (_room != null) {
      await disconnect();
    }

    // Create Room with specific options
    _room = Room(
      roomOptions: const RoomOptions(
        dynacast: true,
        adaptiveStream: true,
        defaultAudioCaptureOptions: const AudioCaptureOptions(
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        ),
        defaultCameraCaptureOptions: CameraCaptureOptions(params: VideoParametersPresets.h720_169),
        defaultVideoPublishOptions: VideoPublishOptions(
          simulcast: true,
          videoCodec: 'VP8',
          videoEncoding: VideoEncoding(
            maxBitrate: 5 * 1000 * 1000,
            maxFramerate: 15,
          ),
        ),
      ),
    );

    _listener = _room!.createListener();

    // Forward Room events
    _listener!.on<RoomEvent>((event) {
      Logger.print('[Livekit service] Room event: ${event.toString()}');
      _roomEventsSubject.add(event);
    });

    // Forward Participant events
    _listener!.on<ParticipantEvent>((event) {
      Logger.print('[Livekit service] Participant event: ${event.toString()}');
      _participantEventsSubject.add(event);
    });

    await _room!.prepareConnection(url, token);

    if (Platform.isIOS) {
      try {
        Logger.print('[Livekit service] Configuring iOS audio session before connect');
        final iosAttributes = rtc.AppleAudioConfiguration(
          appleAudioCategory: rtc.AppleAudioCategory.playAndRecord,
          appleAudioCategoryOptions: {
            rtc.AppleAudioCategoryOption.allowBluetooth,
            rtc.AppleAudioCategoryOption.allowBluetoothA2DP,
            rtc.AppleAudioCategoryOption.interruptSpokenAudioAndMixWithOthers,
          },
          appleAudioMode: rtc.AppleAudioMode.voiceChat,
        );
        await rtc.Helper.setAppleAudioConfiguration(iosAttributes);
        await rtc.Helper.ensureAudioSession();
        Logger.print('[Livekit service] iOS audio session configured successfully');
      } catch (e) {
        Logger.print('[Livekit service] Failed to configure iOS audio: $e');
      }
    }

    try {
      await _room!.connect(
        url,
        token,
        connectOptions: ConnectOptions(
          timeouts: Timeouts(
            connection: const Duration(seconds: 60),
            debounce: const Duration(milliseconds: 100),
            publish: const Duration(seconds: 60),
            peerConnection: const Duration(seconds: 60),
            iceRestart: const Duration(seconds: 60),
          ),
        ),
      );

      _roomSubject.add(_room);
    } catch (e) {
      Logger.print('LiveKit connect error: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    Logger.print('[Livekit service] disconnect');
    await _disposeRoomAsync();

    _roomSubject.add(null);
  }

  Future<void> _disposeRoomAsync() async {
    await _listener?.dispose();
    await room?.dispose();
    _room = null;
  }
}
