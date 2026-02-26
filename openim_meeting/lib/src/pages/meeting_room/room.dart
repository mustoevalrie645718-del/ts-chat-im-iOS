import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_meeting/src/widgets/page_content.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:sprintf/sprintf.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../repository/forPB/meeting.pb.dart' hide MeetingMetadata;
import '../../repository/meeting.pb.dart' hide NotifyMeetingData, KickOffReason;
import '../../repository/pb_extension.dart';
import '../../widgets/meeting_alert_dialog.dart';
import '../../widgets/meeting_state.dart';
import '../../widgets/participant.dart';
import '../../widgets/participant_info.dart';

class MeetingRoom extends MeetingView {
  const MeetingRoom(
    super.meetingClient,
    super.room,
    super.listener, {
    super.key,
    required super.roomID,
    required this.url,
    required this.token,
    super.onClose,
    super.infoSetting,
  });

  final String url;
  final String token;

  @override
  MeetingViewState<MeetingRoom> createState() => _MeetingRoomState();
}

class _MeetingRoomState extends MeetingViewState<MeetingRoom> with WidgetsBindingObserver {
  //
  List<ParticipantTrack> participantTracks = [];
  Timer? _reconnectCloseTimer;
  bool _didForceClose = false;

  EventsListener<RoomEvent> get _listener => widget.listener;

  bool get fastConnection => widget.room.engine.fastConnectOptions != null;
  ParticipantTrack? get _localParticipantTrack =>
      widget.room.localParticipant == null ? null : ParticipantTrack(participant: widget.room.localParticipant!);

  ScrollPhysics? scrollPhysics;
  final PageController _pageController = PageController(initialPage: 1);
  int _pages = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.room.addListener(_onRoomDidUpdate);
    _setUpListeners();
    _sortParticipants();
    _parseRoomMetadata();
    _connect();
  }

  Future<void> _connect() async {
    try {
      if (!await WakelockPlus.enabled) WakelockPlus.enable();
      DataSp.putMeetingInProgress(widget.roomID);

      await _askPublish(
        widget.infoSetting?.setting.disableCameraOnJoin ?? false,
        widget.infoSetting?.setting.disableMicrophoneOnJoin ?? false,
      );

      if (!startTimerCompleter.isCompleted) {
        startTimerCompleter.complete(true);
      }
    } catch (e, s) {
      Logger.print('[MeetingRoom] post-connect tasks error: $e, stack: $s');
      widget.onClose?.call();
    }
  }

  Future _askPublish(bool joinDisabledVideo, bool joinDisabledMicrophone) async {
    Logger.print('[MeetingRoom] _askPublish video: $joinDisabledVideo, mic: $joinDisabledMicrophone');
    await IMUtils.requestBackgroundPermission(title: StrRes.audioAndVideoCall, text: StrRes.audioAndVideoCall);

    try {
      await widget.room.localParticipant?.setCameraEnabled(!joinDisabledVideo);
      Logger.print('[MeetingRoom] publish video success');
    } catch (error) {
      Logger.print('[MeetingRoom] could not publish video: $error');
    }
    try {
      await widget.room.localParticipant?.setMicrophoneEnabled(!joinDisabledMicrophone);
      Logger.print('[MeetingRoom] publish microphone success');
    } catch (error) {
      Logger.print('[MeetingRoom] could not publish audio: $error');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _cancelReconnectCloseTimer();

    // Remove the room update listener that this widget added
    widget.room.removeListener(_onRoomDidUpdate);

    // Disable background execution asynchronously (don't wait)
    if (Platform.isAndroid) {
      // Fire async but don't wait - this is a cleanup task that can complete in background
      IMUtils.disableBackgroundExecution().catchError((e) {
        Logger.print('[MeetingRoom] dispose disableBackgroundExecution error: $e');
        return false;
      });
    }

    Logger.print('[MeetingRoom] dispose completed');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Logger.print('[MeetingRoom] AppLifecycleState changed to: $state');

    if (state == AppLifecycleState.paused) {
      // App going to background - ensure background execution is still enabled
      _ensureBackgroundExecution();
    } else if (state == AppLifecycleState.resumed) {
      // App coming back to foreground
      Logger.print('[MeetingRoom] App resumed, room state: ${widget.room.connectionState}');
    }
  }

  Future<void> _ensureBackgroundExecution() async {
    if (!Platform.isAndroid) return;
    try {
      if (!FlutterBackground.isBackgroundExecutionEnabled) {
        Logger.print('[MeetingRoom] Background execution not enabled, re-enabling...');
        await IMUtils.requestBackgroundPermission(
          title: StrRes.audioAndVideoCall,
          text: StrRes.audioAndVideoCall,
        );
      }
    } catch (e) {
      Logger.print('[MeetingRoom] Error ensuring background execution: $e');
    }
  }

  void _setUpListeners() => _listener
    ..on<RoomDisconnectedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'metting_room.dart',
        line: 78,
        msgs: 'OpenIM-Flutter: RoomDisconnectedEvent',
        keyAndValues: ['reason', event.reason.toString()],
      );
      _meetingClosed(event.reason);
    })
    ..on<RoomRecordingStatusChanged>((event) {})
    ..on<LocalTrackPublishedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'meeting_room.dart',
        line: 89,
        msgs: 'OpenIM-Flutter: LocalTrackPublishedEvent',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      _sortParticipants();
    })
    ..on<LocalTrackUnpublishedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'meeting_room.dart',
        line: 98,
        msgs: 'OpenIM-Flutter: LocalTrackUnpublishedEvent',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      _sortParticipants();
    })
    ..on<ParticipantConnectedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'meeting_room.dart',
        line: 107,
        msgs: 'OpenIM-Flutter: ParticipantConnectedEvent',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      _cancelReconnectCloseTimer();
      _sortParticipants();
    })
    ..on<ParticipantDisconnectedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'meeting_room.dart',
        line: 116,
        msgs: 'OpenIM-Flutter: ParticipantDisconnectedEvent',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      _cancelReconnectCloseTimer();
      _sortParticipants();
    })
    ..on<TrackSubscribedEvent>((event) {
      Logger.print(
        'TrackSubscribedEvent',
        fileName: 'meeting_room.dart',
        keyAndValues: [
          'metadata',
          event.participant.metadata ?? event.participant.identity,
          'kind',
          event.track.kind,
        ],
      );
      _cancelReconnectCloseTimer();

      _sortParticipants();
    })
    ..on<TrackUnsubscribedEvent>((event) {
      Logger.print(
        'TrackUnsubscribedEvent',
        fileName: 'meeting_room.dart',
        keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
      );
      _cancelReconnectCloseTimer();

      _sortParticipants();
    })
    ..on<TrackUnmutedEvent>((event) {
      Logger.print('TrackUnmutedEvent: ${event.participant.metadata} ${event.publication.kind}');
    })
    ..on<TrackMutedEvent>((event) {
      Logger.print('TrackMutedEvent: ${event.participant.metadata} ${event.publication.kind}');
    })
    ..on<RoomMetadataChangedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'meeting_room.dart',
        line: 125,
        msgs: 'OpenIM-Flutter: RoomMetadataChangedEvent',
        keyAndValues: ['metadata', event.metadata ?? 'unkonwn room metadata'],
      );
      _parseRoomMetadata();
    })
    ..on<DataReceivedEvent>((event) => _parseDataReceived(event))
    ..on<RoomAttemptReconnectEvent>((event) {
      OpenIM.iMManager.logs(
          file: 'meeting_room.dart',
          line: 137,
          msgs: 'OpenIM-Flutter: RoomAttemptReconnectEvent',
          keyAndValues: [event.attempt, event.maxAttemptsRetry]);
      _startReconnectCloseTimer();
    })
    ..on<RoomReconnectedEvent>((event) {
      OpenIM.iMManager.logs(
        file: 'meeting_room.dart',
        line: 144,
        msgs: 'OpenIM-Flutter: RoomReconnectedEvent',
      );
      _didForceClose = false;
      _cancelReconnectCloseTimer();

      // After reconnecting, if no remote participants remain, close the meeting.
      final remoteCount = widget.room.remoteParticipants.length;
      if (remoteCount == 0) {
        OverlayWidget().showToast(
          context: context,
          text: StrRes.callingInterruption,
          onDelayDismiss: () {
            widget.onClose?.call();
          },
        );
      }
    });

  void _parseDataReceived(DataReceivedEvent event) {
    final result = NotifyMeetingData.fromBuffer(event.data);
    Logger.print(
      '_parseDataReceived',
      fileName: 'meeting_room.dart',
      keyAndValues: [jsonEncode(result.toProto3Json())],
    );
    // kickofff
    if (result.hasKickOffMeetingData() &&
        result.kickOffMeetingData.userID.isNotEmpty &&
        result.kickOffMeetingData.reasonCode == KickOffReason.DuplicatedLogin) {
      widget.room.disconnect();
      widget.onClose?.call();
      return;
    }

    if (!result.hasStreamOperateData()) return;

    final streamOperateData = result.streamOperateData;

    if (streamOperateData.operation.isEmpty || result.operatorUserID == widget.room.localParticipant?.identity) {
      return;
    }

    final operateUser = streamOperateData.operation.firstWhereOrNull((element) {
      return element.userID == widget.room.localParticipant?.identity;
    });

    if (operateUser == null) return;

    if (operateUser.hasCameraOnEntry()) {
      final cameraOnEntry = operateUser.cameraOnEntry;

      if (cameraOnEntry.value) {
        MeetingAlertDialog.show(context, sprintf(StrRes.requestXDoHint, [StrRes.meetingEnableVideo]),
            confirmText: StrRes.confirm, cancelText: StrRes.keepClose, onConfirm: () {
          widget.room.localParticipant?.setCameraEnabled(cameraOnEntry.value);
        });
      } else {
        widget.room.localParticipant?.setCameraEnabled(cameraOnEntry.value);
      }
    }

    if (operateUser.hasMicrophoneOnEntry()) {
      final microphoneOnEntry = operateUser.microphoneOnEntry;

      if (microphoneOnEntry.value) {
        MeetingAlertDialog.show(context, sprintf(StrRes.requestXDoHint, [StrRes.meetingUnmute]),
            confirmText: StrRes.confirm, cancelText: StrRes.keepClose, onConfirm: () {
          widget.room.localParticipant?.setMicrophoneEnabled(microphoneOnEntry.value);
        });
      } else {
        widget.room.localParticipant?.setMicrophoneEnabled(microphoneOnEntry.value);
      }
    }
  }

  void _parseRoomMetadata() {
    if (widget.room.metadata != null && widget.room.metadata!.isNotEmpty) {
      Logger.print('room parseRoomMetadata: ${widget.room.metadata}');
      meetingInfo =
          (MeetingMetadata()..mergeFromProto3Json(jsonDecode(widget.room.metadata!), ignoreUnknownFields: true)).detail;
      watchedUserID ??= meetingInfo?.creatorUserID;
      meetingInfoChangedSubject.add(meetingInfo!);
      setState(() {});
    }
  }

  @override
  customWatchedUser(String userID) {
    watchedUserID = null;
    if (wasClickedUserID == userID) return;
    final track = participantTracks.firstWhereOrNull((e) => e.participant.identity == userID);
    wasClickedUserID = track?.participant.identity;
    if (null != wasClickedUserID) _sortParticipants();
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
  }

  void _sortParticipants() {
    if (widget.room.localParticipant == null) return;
    List<ParticipantTrack> userMediaTracks = [];
    List<ParticipantTrack> screenTracks = [];
    for (var participant in widget.room.remoteParticipants.values) {
      if (participant.videoTrackPublications.isNotEmpty) {
        final screenShareTrack = participant.videoTrackPublications.firstWhereOrNull((e) => e.isScreenShare);

        if (screenShareTrack != null) {
          screenTracks.add(ParticipantTrack(
            participant: participant,
            type: ParticipantTrackType.kScreenShare,
            isHost: hostUserID == participant.identity,
          ));
        } else {
          userMediaTracks.add(ParticipantTrack(
            participant: participant,
            isHost: hostUserID == participant.identity,
          ));
        }
      } else {
        userMediaTracks.add(ParticipantTrack(
          participant: participant,
          isHost: hostUserID == participant.identity,
        ));
      }
    }

    // sort speakers for the grid
    userMediaTracks.sort((a, b) {
      /*
      // loudest speaker first
      if (a.participant.isSpeaking && b.participant.isSpeaking) {
        if (a.participant.audioLevel > b.participant.audioLevel) {
          return -1;
        } else {
          return 1;
        }
      }

      // last spoken at
      final aSpokeAt = a.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
      final bSpokeAt = b.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

      if (aSpokeAt != bSpokeAt) {
        return aSpokeAt > bSpokeAt ? -1 : 1;
      }
      */

      // video on
      if (a.participant.hasVideo != b.participant.hasVideo) {
        return a.participant.hasVideo ? -1 : 1;
      }

      // joinedAt
      return a.participant.joinedAt.millisecondsSinceEpoch - b.participant.joinedAt.millisecondsSinceEpoch;
    });

    final localParticipantTracks = widget.room.localParticipant?.videoTrackPublications;
    final screenShareTrack = localParticipantTracks?.firstWhereOrNull((e) => e.isScreenShare);

    if (screenShareTrack != null) {
      screenTracks.add(ParticipantTrack(
        participant: widget.room.localParticipant!,
        type: ParticipantTrackType.kScreenShare,
        isHost: hostUserID == widget.room.localParticipant?.identity,
      ));
    } else {
      userMediaTracks.add(ParticipantTrack(
        participant: widget.room.localParticipant!,
        isHost: hostUserID == widget.room.localParticipant?.identity,
      ));
    }

    setState(() {
      participantTracks = [...screenTracks, ...userMediaTracks];
      participantsSubject.add(participantTracks);
    });
  }

  ParticipantTrack? get _firstParticipantTrack {
    ParticipantTrack? track;
    if (null != wasClickedUserID) {
      track = participantTracks.firstWhereOrNull((e) => e.participant.identity == wasClickedUserID);
    } else if (null != watchedUserID) {
      track = participantTracks.firstWhereOrNull((e) => e.participant.identity == watchedUserID);
    } else {
      track = participantTracks.firstWhereOrNull((e) => e.participant.videoTrackPublications.isNotEmpty);
    }
    final videoTracks = track?.participant.videoTrackPublications;
    final screenTrack = videoTracks?.firstWhereOrNull((e) => e.isScreenShare);
    final videoTrack = videoTracks?.firstWhereOrNull((e) => !e.isScreenShare);

    Logger.print('first watch track : ${track == null} '
        'videoTrack:${screenTrack != null} '
        'screenShareTrack:${videoTrack != null} '
        'screen track muted:${screenTrack?.muted} '
        'video track muted:${videoTrack?.muted} '
        'audio track muted:${track?.participant.isMuted == true} ');
    return track;
  }

  _onPageChange(int pages) {
    setState(() {
      _pages = pages;
    });
  }

  _fixPages(int count) {
    _pages = min(_pages, count - 1);
    return count;
  }

  int get pageCount => _fixPages(
      (participantTracks.length % 4 == 0 ? participantTracks.length ~/ 4 : participantTracks.length ~/ 4 + 1) +
          (null == _firstParticipantTrack ? 0 : 1));

  @override
  Widget buildChild() => Stack(
        children: [
          widget.room.remoteParticipants.isEmpty
              ? (_localParticipantTrack == null
                  ? const SizedBox()
                  : GestureDetector(
                      onDoubleTap: toggleFullScreen,
                      child: ParticipantWidget.widgetFor(
                        _localParticipantTrack!,
                        // isZoom: false,
                        // useScreenShareTrack: true,
                        onTapSwitchCamera: () {
                          _localParticipantTrack!.toggleCamera();
                        },
                      )))
              : PageView.builder(
                  physics: scrollPhysics,
                  itemBuilder: (context, index) {
                    final existVideoTrack = null != _firstParticipantTrack;
                    if (existVideoTrack && index == 0) {
                      return GestureDetector(
                        child: FirstPage(
                          participantTrack: _firstParticipantTrack!,
                        ),
                        onDoubleTap: () {
                          toggleFullScreen();
                        },
                      );
                    }
                    return OtherPage(
                      participantTracks: participantTracks,
                      pages: existVideoTrack ? index - 1 : index,
                      onDoubleTap: (t) {
                        setState(() {
                          customWatchedUser(t.participant.identity);
                          _pageController.jumpToPage(0);
                        });
                      },
                    );
                  },
                  itemCount: pageCount,
                  onPageChanged: _onPageChange,
                  controller: _pageController,
                ),
          if (widget.room.remoteParticipants.isNotEmpty && pageCount > 1)
            Positioned(
              bottom: 8.h,
              child: PageViewDotIndicator(
                currentItem: _pages,
                count: pageCount,
                size: Size(8.w, 8.h),
                unselectedColor: Styles.c_FFFFFF_opacity50,
                selectedColor: Styles.c_FFFFFF,
              ),
            ),
          Positioned(
            right: 16.w,
            bottom: 16.h,
            child: ImageRes.meetingRotateScreen.toImage
              ..width = 44.w
              ..height = 44.h
              ..onTap = rotateScreen,
          )
        ],
      );

  void _meetingClosed(DisconnectReason? reason) {
    Logger.print(
        '[MeetingClient] _meetingClosed reason: $reason, humanOperation: $humanOperation, isForceClosing: ${widget.meetingClient.isForceClosing}');
    if (humanOperation || widget.meetingClient.isForceClosing) {
      return;
    }

    final isMeetingClosed = reason == DisconnectReason.serverShutdown || reason == DisconnectReason.roomDeleted;
    final tips = isMeetingClosed ? StrRes.meetingIsOver : StrRes.meetingClosedHint;

    if (isMeetingClosed) {
      OverlayWidget().showAutoCloseAlert(
        context: context,
        message: tips,
        buttonText: StrRes.leaveMeeting,
        countdownSeconds: 3,
        onAutoClose: () {
          OverlayWidget().dismiss();
          widget.onClose?.call();
        },
      );
    } else if (reason == DisconnectReason.joinFailure ||
        reason == DisconnectReason.reconnectAttemptsExceeded ||
        reason == DisconnectReason.signalingConnectionFailure) {
      final tips = reason == DisconnectReason.joinFailure ? StrRes.joinFailure : StrRes.connectionDisconnected;

      OverlayWidget().showToast(
        context: context,
        text: tips,
        onDelayDismiss: () {
          widget.onClose?.call();
        },
      );
    } else {
      OverlayWidget().showDialog(
        context: context,
        child: CustomDialog(
          onTapLeft: OverlayWidget().dismiss,
          onTapRight: () {
            OverlayWidget().dismiss();
            widget.onClose?.call();
          },
          title: tips,
        ),
      );
    }
  }

  void _startReconnectCloseTimer() {
    if (_didForceClose || _reconnectCloseTimer != null) return;
    _reconnectCloseTimer = Timer(const Duration(seconds: 10), () {
      if (_didForceClose) return;
      _didForceClose = true;
      _reconnectCloseTimer = null;
      OverlayWidget().showToast(
        context: context,
        text: StrRes.callingInterruption,
        onDelayDismiss: () {
          widget.onClose?.call();
        },
      );
    });
  }

  void _cancelReconnectCloseTimer() {
    _reconnectCloseTimer?.cancel();
    _reconnectCloseTimer = null;
  }
}

class FirstPageZoomNotification extends Notification {
  bool isZoom;

  FirstPageZoomNotification({this.isZoom = false});
}
