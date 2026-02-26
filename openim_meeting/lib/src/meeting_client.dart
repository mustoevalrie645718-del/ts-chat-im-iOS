import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_meeting/openim_meeting.dart';
import 'package:openim_meeting/src/pages/meeting_room/room.dart';
import 'package:openim_meeting/src/repository/repository_adapter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

import 'repository/meeting.pb.dart';
import 'repository/pb_extension.dart';

/// 会议室
class MeetingClient implements MeetingBridge {
  MeetingClient();

  void _attachBridge() {
    if (PackageBridge.meetingBridge != this) {
      PackageBridge.meetingBridge = this;
    }
  }

  void _detachBridge() {
    if (PackageBridge.meetingBridge == this) {
      PackageBridge.meetingBridge = null;
    }
  }

  @override
  bool get hasConnection {
    Logger.print('meeting_client has Connection: $isBusy');
    return isBusy;
  }

  @override
  void dismiss() {
    close();
  }

  @override
  void forceDismiss() {
    forceClose();
  }

  OverlayEntry? _holder;
  bool isBusy = false;
  bool isForceClosing = false;
  // PublishSubject<MeetingStreamEvent>? subject;
  String? roomID;
  AnimationController? _animationController;
  Room? _room;
  EventsListener<RoomEvent>? _listener;

  Future<void> close() async {
    Logger.print('[MeetingClient] close begin, isForceClosing: $isForceClosing');
    if (_holder == null) {
      isBusy = false;
      roomID = null;
      _room = null;
      _listener = null;
      isForceClosing = false;
      return;
    }

    // Dispose listener and room BEFORE removing holder to ensure cleanup happens
    // before widget's dispose() is triggered
    try {
      if (_listener != null && !isForceClosing) {
        await _listener!.dispose();
        Logger.print('[MeetingClient] listener disposed');
      }
    } catch (e) {
      Logger.print('[MeetingClient] close dispose listener error: $e');
    }

    try {
      if (_room != null && !isForceClosing) {
        await _room!.disconnect();
        await _room!.dispose();
        Logger.print('[MeetingClient] room disposed');
      }
    } catch (e) {
      Logger.print('[MeetingClient] close dispose room error: $e');
    }

    _animationController?.reverse();

    _holder?.remove();
    _holder = null;
    isBusy = false;
    roomID = null;
    _room = null;
    _listener = null;
    _animationController = null;
    _detachBridge();

    try {
      if (await WakelockPlus.enabled) WakelockPlus.disable();
    } catch (e) {
      Logger.print('[MeetingClient] close disable wakelock error: $e');
    }
    Logger.print('[MeetingClient] close end');
    isForceClosing = false;
  }

  Future forceClose() async {
    Logger.print('[MeetingClient] forceClose begin');
    isForceClosing = true;

    try {
      await _listener?.dispose();
      await _room?.disconnect();
      await _room?.dispose();
    } catch (e) {
      Logger.print('[MeetingClient] forceClose disconnect error: $e');
    } finally {
      await close();
    }
    Logger.print('[MeetingClient] forceClose end');
  }

  Future<void> create(
    BuildContext ctx, {
    required String meetingName,
    required int startTime,
    required int duration,
    VoidCallback? onClose,
  }) =>
      _connect(ctx,
          isCreate: true, meetingName: meetingName, startTime: startTime, duration: duration, onClose: onClose);

  join(
    BuildContext ctx, {
    required String meetingID,
    String? meetingName,
    String? participantNickname,
    VoidCallback? onClose,
  }) =>
      _connect(ctx,
          isCreate: false,
          meetingID: meetingID,
          meetingName: meetingName,
          participantNickname: participantNickname,
          onClose: onClose);

  Future<void> _connect(
    BuildContext ctx, {
    bool isCreate = true,
    String? meetingID,
    String? meetingName,
    int? startTime,
    int? duration,
    String? participantNickname,
    VoidCallback? onClose,
  }) async {
    try {
      if (isBusy) return;

      final isNetworkAvailable = await NetworkMonitor().isNetworkAvailable();

      if (!isNetworkAvailable) {
        IMViews.showToast(StrRes.networkNotStable);
        return;
      }

      _attachBridge();
      isBusy = true;

      FocusScope.of(ctx).requestFocus(FocusNode());

      roomID = meetingID;

      late LiveKit sc;
      final repository = MeetingRepository();
      MeetingInfoSetting infoSetting;

      if (isCreate) {
        final result = await repository.createMeeting(
          type: CreateMeetingType.quick,
          creatorUserID: DataSp.userID!,
          creatorDefinedMeetingInfo: CreatorDefinedMeetingInfo(
            title: meetingName,
            scheduledTime: Int64(startTime!),
            meetingDuration: Int64(duration!),
          ),
          setting: MeetingSetting(
            canParticipantsEnableCamera: true,
            canParticipantsUnmuteMicrophone: true,
            canParticipantsShareScreen: true,
            disableCameraOnJoin: true,
            disableMicrophoneOnJoin: true,
            canParticipantJoinMeetingEarly: true,
            lockMeeting: false,
            audioEncouragement: true,
            videoMirroring: true,
          ),
        );
        roomID = result.info.meetingID;

        if (result.cert == null) {
          isBusy = false;
          _detachBridge();

          return;
        }

        sc = result.cert!;
        infoSetting = result.info;
      } else {
        final result = await repository.joinMeeting(meetingID!, DataSp.userID!);

        if (result == null) {
          isBusy = false;
          _detachBridge();

          return;
        }
        infoSetting = await repository.getMeetingInfo(meetingID, DataSp.userID!);

        sc = result;
      }
      LoadingView().show();

      //create new room
      _room = Room(
        roomOptions: const RoomOptions(
          dynacast: true,
          adaptiveStream: true,
          defaultCameraCaptureOptions: CameraCaptureOptions(params: VideoParametersPresets.h720_169),
          defaultVideoPublishOptions: VideoPublishOptions(
              simulcast: true,
              videoCodec: 'VP8',
              videoEncoding: VideoEncoding(
                maxBitrate: 5 * 1000 * 1000,
                maxFramerate: 15,
              )),
          defaultScreenShareCaptureOptions:
              ScreenShareCaptureOptions(useiOSBroadcastExtension: true, maxFrameRate: 15.0),
        ),
      );

      OpenIM.iMManager.logs(
        file: 'meeting_client.dart',
        line: 174, // Updated line number
        msgs: 'OpenIM-Flutter: connect begin',
        keyAndValues: [sc.url, sc.token],
      );

      // Create a Listener before connecting
      _listener = _room!.createListener();

      await _room!.prepareConnection(sc.url, sc.token);

      if (Platform.isIOS) {
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.speech());
        // try {
        //   Logger.print('[Livekit service] Configuring iOS audio session before connect');
        //   final iosAttributes = rtc.AppleAudioConfiguration(
        //     appleAudioCategory: rtc.AppleAudioCategory.playAndRecord,
        //     appleAudioCategoryOptions: {
        //       rtc.AppleAudioCategoryOption.allowBluetooth,
        //       rtc.AppleAudioCategoryOption.allowBluetoothA2DP,
        //       rtc.AppleAudioCategoryOption.interruptSpokenAudioAndMixWithOthers,
        //     },
        //     appleAudioMode: rtc.AppleAudioMode.voiceChat,
        //   );
        //   await rtc.Helper.setAppleAudioConfiguration(iosAttributes);
        //   await rtc.Helper.ensureAudioSession();
        //   Logger.print('[Livekit service] iOS audio session configured successfully');
        // } catch (e) {
        //   Logger.print('[Livekit service] Failed to configure iOS audio: $e');
        // }
      }

      await _room!.connect(
        sc.url,
        sc.token,
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

      Logger.print('[MeetingClient] loading end');
      LoadingView().dismiss();
      Overlay.of(ctx).insert(
        _holder = OverlayEntry(
          builder: (context) => SlideInSlideOutWidget(
            contentBuilder: (controller) {
              _animationController = controller;
              return MeetingRoom(
                this,
                _room!,
                _listener!,
                url: sc.url,
                token: sc.token,
                infoSetting: infoSetting,
                roomID: roomID!,
                onClose: () {
                  close();
                },
              );
            },
          ),
        ),
      );
    } catch (error, trace) {
      LoadingView().dismiss();

      if (_room?.connectionState == ConnectionState.connected) {
        // After dialing N times in a row, there may be a timeout. After N+1 successful connections, the previous timeout will close the interface.
        isBusy = false;
        Logger.print('[MeetingClient] _connect partial error (was already connected)');
        return;
      }
      close();
      Logger.print("[MeetingClient] error:$error  stack:$trace");
      OpenIM.iMManager.logs(
        file: 'meeting_client.dart',
        line: 199,
        msgs: 'OpenIM-Flutter: connect error',
        err: 'error: ${error.toString()}, stackTrace: ${trace.toString()}',
      );

      if (error.toString().contains('NotExist')) {
        IMViews.showToast(StrRes.meetingIsOver);
      } else {
        IMViews.showToast(StrRes.networkError);
      }
    }
  }

  invite({
    required String meetingID,
    required String meetingName,
    required int startTime,
    required int duration,
    String? userID,
    String? groupID,
  }) async {
    final offlinePushInfo = Config.offlinePushInfo;
    final newPushInfo = OfflinePushInfo(
      title: offlinePushInfo.title,
      desc: offlinePushInfo.desc,
      iOSBadgeCount: offlinePushInfo.iOSBadgeCount,
    )..title = StrRes.offlineMeetingMessage;

    OpenIM.iMManager.messageManager.sendMessage(
      userID: userID,
      groupID: groupID,
      message: await OpenIM.iMManager.messageManager.createMeetingMessage(
        inviterUserID: OpenIM.iMManager.userInfo.userID!,
        inviterNickname: OpenIM.iMManager.userInfo.nickname ?? '',
        inviterFaceURL: OpenIM.iMManager.userInfo.faceURL,
        subject: meetingName,
        id: meetingID,
        start: startTime,
        duration: duration,
      ),
      offlinePushInfo: newPushInfo,
    );
  }
}

class SlideInSlideOutWidget extends StatefulWidget {
  final Widget Function(AnimationController) contentBuilder;

  const SlideInSlideOutWidget({super.key, required this.contentBuilder});

  @override
  State<SlideInSlideOutWidget> createState() => _SlideInSlideOutWidgetState();
}

class _SlideInSlideOutWidgetState extends State<SlideInSlideOutWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.contentBuilder(_controller),
    );
  }
}
