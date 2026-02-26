import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_background/flutter_background.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';

import '../../live_client.dart';
import '../../services/livekit_service.dart';
import 'widgets/call_state.dart';
import 'widgets/participant_info.dart';

class GroupRoomView extends GroupView {
  const GroupRoomView({
    super.key,
    required super.callType,
    super.roomID,
    required super.groupID,
    required super.inviterUserID,
    required super.inviteeUserIDList,
    super.onClose,
    super.onError,
    super.onSyncGroupMemberInfo,
    super.onSyncGroupInfo,
    super.onEnabledSpeaker,
    super.autoPickup = false,
  });

  @override
  State<GroupRoomView> createState() => _GroupRoomViewState();
}

class _GroupRoomViewState extends GroupState<GroupRoomView> with WidgetsBindingObserver {
  StreamSubscription? _roomSub;
  StreamSubscription? _roomEventsSub;
  StreamSubscription? _participantEventsSub;
  bool _didForceClose = false;
  Timer? _reconnectCloseTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    enabledSpeaker = true;
  }

  @override
  bool isHost() {
    return widget.inviterUserID == room?.localParticipant?.identity;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _roomSub?.cancel();
    _roomEventsSub?.cancel();
    _participantEventsSub?.cancel();
    room?.removeListener(_onRoomDidUpdate);
    _cancelReconnectCloseTimer();
    if (Platform.isAndroid) {
      IMUtils.disableBackgroundExecution();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Logger.print('[GroupRoom] AppLifecycleState changed to: $state');

    if (state == AppLifecycleState.paused) {
      _ensureBackgroundExecution();
    } else if (state == AppLifecycleState.resumed) {
      Logger.print('[GroupRoom] App resumed, room state: ${room?.connectionState}');
    }
  }

  Future<void> _ensureBackgroundExecution() async {
    if (!Platform.isAndroid) return;
    try {
      if (!FlutterBackground.isBackgroundExecutionEnabled) {
        Logger.print('[GroupRoom] Background execution not enabled, re-enabling...');
        await IMUtils.requestBackgroundPermission(
          title: StrRes.audioAndVideoCall,
          text: StrRes.audioAndVideoCall,
        );
      }
    } catch (e) {
      Logger.print('[GroupRoom] Error ensuring background execution: $e');
    }
  }

  @override
  Future<void> bindRoomStreams() async {
    if (_roomSub != null) return;

    // Subscribe to room updates from LiveKitService
    _roomSub = LiveKitService().roomStream.listen((room) {
      Logger.print('GroupRoomView: Received room update from LiveKitService. Room: ${room?.name}');
      if (room != null && this.room != room) {
        this.room?.removeListener(_onRoomDidUpdate);
        this.room = room;
        this.room!.addListener(_onRoomDidUpdate);

        _setUpListeners();
        _publish(callState != CallState.call).then((_) {
          Logger.print('GroupRoomView: _publish completed.');
          _sortParticipants();
        });
      } else {
        this.room?.removeListener(_onRoomDidUpdate);
        this.room?.dispose();
        this.room = null;
        Logger.print('GroupRoomView: Room check skipped. Room: $room, Current: ${this.room}');
      }
    });
  }

  void _setUpListeners() {
    _roomEventsSub?.cancel();
    _participantEventsSub?.cancel();

    _roomEventsSub = LiveKitService().roomEventsStream.listen((event) {
      if (event is RoomDisconnectedEvent) {
        _handleRoomDisconnected(event);
      } else if (event is RoomAttemptReconnectEvent) {
        _handleRoomAttemptReconnect(event);
      } else if (event is RoomReconnectedEvent) {
        _handleRoomReconnected(event);
      } else if (event is ParticipantConnectedEvent) {
        _handleParticipantConnected(event);
      } else if (event is ParticipantDisconnectedEvent) {
        _handleParticipantDisconnected(event);
      }
    });

    _participantEventsSub = LiveKitService().participantEventsStream.listen((event) {
      if (event is LocalTrackPublishedEvent) {
        _onRoomDidUpdate();
      } else if (event is LocalTrackUnpublishedEvent) {
        // _onRoomDidUpdate();
      } else if (event is TrackSubscribedEvent) {
        _onRoomDidUpdate();
      } else if (event is TrackUnsubscribedEvent) {
        // _onRoomDidUpdate();
      }
    });
  }

  void _handleRoomDisconnected(RoomDisconnectedEvent event) {
    Logger.print(
      'RoomDisconnectedEvent',
      fileName: 'group-room.dart',
      keyAndValues: ['reason', event.reason.toString()],
    );

    if (event.reason == DisconnectReason.joinFailure || event.reason == DisconnectReason.reconnectAttemptsExceeded) {
      final tips = event.reason == DisconnectReason.joinFailure ? StrRes.joinFailure : StrRes.callingInterruption;

      OverlayWidget().showToast(
        context: context,
        text: tips,
        onDelayDismiss: () {
          insertInterruptionMessage();
          widget.onClose?.call();
        },
      );
    } else if (event.reason == DisconnectReason.signalingConnectionFailure ||
        event.reason == DisconnectReason.roomDeleted ||
        event.reason == DisconnectReason.stateMismatch) {
      OverlayWidget().showToast(
        context: context,
        text: StrRes.callingInterruption,
        onDelayDismiss: () {
          insertInterruptionMessage();
          widget.onError?.call(StrRes.callingInterruption, null);
        },
      );
    }
  }

  void _handleRoomAttemptReconnect(RoomAttemptReconnectEvent event) {
    Logger.print(
      'RoomAttemptReconnectEvent',
      fileName: 'group-room.dart',
      keyAndValues: [event.attempt, event.maxAttemptsRetry],
    );
    _startReconnectCloseTimer();
  }

  void _handleRoomReconnected(RoomReconnectedEvent event) {
    Logger.print('RoomReconnectedEvent', fileName: 'group-room.dart');
    _didForceClose = false;
    _cancelReconnectCloseTimer();

    // If after reconnecting there are no remote participants left, close the room.
    final remoteCount = room?.remoteParticipants.length ?? 0;
    if (remoteCount == 0) {
      OverlayWidget().showToast(
        context: context,
        text: StrRes.callingInterruption,
        onDelayDismiss: () {
          insertInterruptionMessage();
          widget.onClose?.call();
        },
      );
    }
  }

  void _handleParticipantConnected(ParticipantConnectedEvent event) {
    Logger.print(
      'ParticipantConnectedEvent',
      fileName: 'group-room.dart',
      keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
    );

    _sortParticipants();
    if (callState != CallState.calling) {
      setState(() {
        callState = CallState.calling;
      });
    }
  }

  void _handleParticipantDisconnected(ParticipantDisconnectedEvent event) {
    Logger.print(
      'ParticipantDisconnectedEvent',
      fileName: 'group-room.dart',
      keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
    );
    Logger.print('participantTracks before remove: ${participantTracks.length}', fileName: 'group-room.dart');
    _sortParticipants();
    Logger.print('participantTracks after remove: ${participantTracks.length}', fileName: 'group-room.dart');
  }

  Future _publish([bool publishMic = true]) async {
    // video will fail when running in ios simulator
    await IMUtils.requestBackgroundPermission(title: StrRes.audioAndVideoCall, text: StrRes.audioAndVideoCall);

    try {
      final enabled = widget.callType == CallType.video;
      await room?.localParticipant?.setCameraEnabled(enabled);
    } catch (e) {
      Logger.print('setCameraEnabled error: $e', fileName: 'room.dart');
    }
    try {
      if (publishMic) await room?.localParticipant?.setMicrophoneEnabled(true);
    } catch (e) {
      Logger.print('setMicrophoneEnabled error: $e', fileName: 'room.dart');
    }

    await room?.localParticipant?.setMicrophoneEnabled(enabledMicrophone);
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
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
          insertInterruptionMessage();
          widget.onClose?.call();
        },
      );
    });
  }

  void _cancelReconnectCloseTimer() {
    _reconnectCloseTimer?.cancel();
    _reconnectCloseTimer = null;
  }

  void _sortParticipants() {
    if (null == room) return;
    List<ParticipantTrack> userMediaTracks = [];

    final localParticipant = room!.localParticipant;
    if (null != localParticipant) {
      VideoTrack? videoTrack;
      for (var t in localParticipant.videoTrackPublications) {
        if (!t.isScreenShare) {
          videoTrack = t.track;
          break;
        }
      }
      userMediaTracks.add(ParticipantTrack(
        participant: localParticipant,
        videoTrack: videoTrack,
        isScreenShare: false,
      ));
    }

    for (var participant in room!.remoteParticipants.values) {
      VideoTrack? videoTrack;
      for (var t in participant.videoTrackPublications) {
        if (!t.isScreenShare) {
          videoTrack = t.track;
          break;
        }
      }
      userMediaTracks.add(ParticipantTrack(
        participant: participant,
        videoTrack: videoTrack,
        isScreenShare: false,
      ));
    }

    final nextTracks = [...userMediaTracks];
    if (_isSameTracks(nextTracks)) {
      Logger.print('Sorted participants -> no change, skip rebuild', fileName: 'group-room.dart');
      return;
    }

    if (!mounted) return;
    setState(() {
      participantTracks = nextTracks;
    });
    maybeAutoCloseOnEmptyRoom(source: 'participantUpdate');
    Logger.print(
      'Sorted participants -> local: ${localParticipant?.identity}, remotes: ${room!.remoteParticipants.values.map((e) => e.identity).toList()}, tracks: ${participantTracks.length}',
      fileName: 'group-room.dart',
    );
  }

  bool _isSameTracks(List<ParticipantTrack> nextTracks) {
    if (nextTracks.length != participantTracks.length) return false;

    for (var i = 0; i < nextTracks.length; i++) {
      final next = nextTracks[i];
      final prev = participantTracks[i];
      if (next.participant.identity != prev.participant.identity) return false;
      if (next.videoTrack?.sid != prev.videoTrack?.sid) return false;
    }
    return true;
  }
}
