import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_live/src/utils/live_utils.dart';
import 'package:openim_live/src/widgets/no_video.dart';

class ParticipantTrack {
  ParticipantTrack({required this.participant, required this.videoTrack, required this.isScreenShare});

  VideoTrack? videoTrack;
  Participant participant;
  final bool isScreenShare;
}

abstract class ParticipantWidget extends StatefulWidget {
  // Convenience method to return relevant widget for participant
  static ParticipantWidget widgetFor(ParticipantTrack participantTrack) {
    if (participantTrack.participant is LocalParticipant) {
      return LocalParticipantWidget(participantTrack.participant as LocalParticipant, participantTrack.videoTrack,
          participantTrack.isScreenShare);
    } else if (participantTrack.participant is RemoteParticipant) {
      return RemoteParticipantWidget(participantTrack.participant as RemoteParticipant, participantTrack.videoTrack,
          participantTrack.isScreenShare);
    }
    throw UnimplementedError('Unknown participant type');
  }

  // Must be implemented by child class
  abstract final Participant participant;
  abstract final VideoTrack? videoTrack;
  abstract final bool isScreenShare;
  final VideoQuality quality;

  const ParticipantWidget({
    this.quality = VideoQuality.MEDIUM,
    Key? key,
  }) : super(key: key);
}

class LocalParticipantWidget extends ParticipantWidget {
  @override
  final LocalParticipant participant;
  @override
  final VideoTrack? videoTrack;
  @override
  final bool isScreenShare;

  const LocalParticipantWidget(
    this.participant,
    this.videoTrack,
    this.isScreenShare, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LocalParticipantWidgetState();
}

class RemoteParticipantWidget extends ParticipantWidget {
  @override
  final RemoteParticipant participant;
  @override
  final VideoTrack? videoTrack;
  @override
  final bool isScreenShare;

  const RemoteParticipantWidget(
    this.participant,
    this.videoTrack,
    this.isScreenShare, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RemoteParticipantWidgetState();
}

abstract class _ParticipantWidgetState<T extends ParticipantWidget> extends State<T> {
  VideoTrack? get activeVideoTrack;

  TrackPublication? get videoPublication;

  TrackPublication? get firstAudioPublication;

  String? _avatar;
  String? _nickname;

  @override
  void initState() {
    super.initState();
    widget.participant.addListener(_onParticipantChanged);
    // Listen to camera position changes for instant mirror mode updates
    CameraPositionTracker.currentPosition.addListener(_onCameraPositionChanged);
    _onParticipantChanged();
  }

  @override
  void dispose() {
    widget.participant.removeListener(_onParticipantChanged);
    CameraPositionTracker.currentPosition.removeListener(_onCameraPositionChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    oldWidget.participant.removeListener(_onParticipantChanged);
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
    super.didUpdateWidget(oldWidget);
  }

  // Notify Flutter that UI re-build is required, but we don't set anything here
  // since the updated values are computed properties.
  void _onParticipantChanged() => setState(() {
        _parseMetadata();
      });

  void _onCameraPositionChanged() {
    if (mounted) setState(() {});
  }

  void _parseMetadata() {
    try {
      if (widget.participant.metadata == null) return;
      var data = json.decode(widget.participant.metadata!);
      _avatar = data['userInfo']['faceURL'];
      _nickname = data['userInfo']['nickName'];
    } catch (error, stack) {
      Logger.print('$error $stack');
    }
  }

  VideoViewMirrorMode _getMirrorMode() {
    // Only apply mirror mode for local video tracks (not screen share)
    if (activeVideoTrack is LocalVideoTrack && !widget.isScreenShare) {
      // Use the static tracked camera position instead of currentOptions
      // because rtc.Helper.switchCamera doesn't update currentOptions.cameraPosition
      return CameraPositionTracker.currentPosition.value == CameraPosition.front
          ? VideoViewMirrorMode.mirror
          : VideoViewMirrorMode.off;
    }
    // For remote tracks or screen share, no mirror mode
    return VideoViewMirrorMode.off;
  }

  // Widgets to show above the info bar
  List<Widget> extraWidgets(bool isScreenShare) => [];

  @override
  Widget build(BuildContext ctx) => SizedBox(
        child: activeVideoTrack != null
            ? (!activeVideoTrack!.muted
                ? VideoTrackRenderer(
                    activeVideoTrack!,
                    // fit: VideoViewFit.contain,
                    mirrorMode: _getMirrorMode(),
                  )
                : NoVideoAvatarWidget(
                    name: _nickname,
                    faceURL: _avatar,
                  ))
            : Container(
                color: Colors.black,
              ),
      );
}

class _LocalParticipantWidgetState extends _ParticipantWidgetState<LocalParticipantWidget> {
  @override
  LocalTrackPublication<LocalVideoTrack>? get videoPublication =>
      widget.participant.videoTrackPublications.where((element) => element.sid == widget.videoTrack?.sid).firstOrNull;

  @override
  LocalTrackPublication<LocalAudioTrack>? get firstAudioPublication =>
      widget.participant.audioTrackPublications.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.videoTrack;
}

class _RemoteParticipantWidgetState extends _ParticipantWidgetState<RemoteParticipantWidget> {
  @override
  RemoteTrackPublication<RemoteVideoTrack>? get videoPublication =>
      widget.participant.videoTrackPublications.where((element) => element.sid == widget.videoTrack?.sid).firstOrNull;

  @override
  RemoteTrackPublication<RemoteAudioTrack>? get firstAudioPublication =>
      widget.participant.audioTrackPublications.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.videoTrack;
}
