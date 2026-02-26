import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:collection/collection.dart';

import 'participant.dart';

enum ParticipantTrackType {
  kUserMedia,
  kScreenShare,
}

extension ParticipantTrackTypeExt on ParticipantTrackType {
  TrackSource get lkVideoSourceType => {
        ParticipantTrackType.kUserMedia: TrackSource.camera,
        ParticipantTrackType.kScreenShare: TrackSource.screenShareVideo,
      }[this]!;

  TrackSource get lkAudioSourceType => {
        ParticipantTrackType.kUserMedia: TrackSource.microphone,
        ParticipantTrackType.kScreenShare: TrackSource.screenShareAudio,
      }[this]!;
}

extension LocalVideoTrackExt on ParticipantTrack {
  void toggleCamera() async {
    if (participant is! LocalParticipant) {
      return;
    }

    try {
      final track =
          participant.videoTrackPublications.firstWhereOrNull((e) => !e.isScreenShare)?.track as LocalVideoTrack;

      final newPosition = (track.currentOptions as CameraCaptureOptions).cameraPosition == CameraPosition.front
          ? CameraPosition.back
          : CameraPosition.front;
      await track.setCameraPosition(newPosition);

      // Update the camera position tracker for mirror mode
      CameraPositionTracker.currentPosition.value = newPosition;
    } catch (error) {
      print('could not restart track: $error');
      return;
    }
  }
}

class ParticipantTrack {
  ParticipantTrack({
    required this.participant,
    this.type = ParticipantTrackType.kUserMedia,
    this.isHost = false,
  });
  Participant participant;
  final ParticipantTrackType type;

  bool isHost;

  bool get isScreenShare => type == ParticipantTrackType.kScreenShare;
}

class ParticipantInfoWidget extends StatelessWidget {
  //
  final String? title;
  final bool audioAvailable;
  final ConnectionQuality connectionQuality;
  final bool isScreenShare;
  final bool isHost;

  const ParticipantInfoWidget({
    this.title,
    this.audioAvailable = true,
    this.connectionQuality = ConnectionQuality.unknown,
    this.isScreenShare = false,
    this.isHost = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHost)
              ImageRes.meetingPerson.toImage
                ..width = 17.w
                ..height = 17.h,
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: Styles.c_0C1C33_opacity30,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                margin: EdgeInsets.only(left: 2.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    (audioAvailable ? ImageRes.meetingMicOnWhite : ImageRes.meetingMicOffWhite).toImage
                      ..width = 13.w
                      ..height = 13.h,
                    if (title != null)
                      Flexible(
                        child: title!.toText
                          ..style = Styles.ts_FFFFFF_12sp
                          ..maxLines = 1
                          ..overflow = TextOverflow.ellipsis,
                      ),
                    if (connectionQuality != ConnectionQuality.unknown)
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Icon(
                          connectionQuality == ConnectionQuality.poor ? EvaIcons.wifiOffOutline : EvaIcons.wifi,
                          color: {
                            ConnectionQuality.excellent: Colors.green,
                            ConnectionQuality.good: Colors.orange,
                            ConnectionQuality.poor: Colors.red,
                          }[connectionQuality],
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // isScreenShare
            //     ? const Padding(
            //         padding: EdgeInsets.only(left: 5),
            //         child: Icon(
            //           EvaIcons.monitor,
            //           color: Colors.white,
            //           size: 16,
            //         ),
            //       )
            //     : Padding(
            //         padding: const EdgeInsets.only(left: 5),
            //         child: Icon(
            //           audioAvailable ? EvaIcons.mic : EvaIcons.micOff,
            //           color: audioAvailable ? Colors.white : Colors.red,
            //           size: 16,
            //         ),
            //       ),
          ],
        ),
      );
}
