import 'dart:async';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:openim_common/openim_common.dart';
import 'package:rxdart/rxdart.dart';

import '../live_client.dart';

class SignalingService {
  static final SignalingService _instance = SignalingService._internal();

  factory SignalingService() => _instance;

  SignalingService._internal() {
    // Removed internal listener to avoid conflict with IMController
    // The OpenIMLive mixin in IMController will feed events into this service.
  }

  final _signalingSubject = PublishSubject<CallEvent>();

  Stream<CallEvent> get signalingStream => _signalingSubject.stream;

  final _waitTimeout = 60;

  // --- Event Ingestion from OpenIMLive Mixin ---

  void onInvitationCancelled(SignalingInfo info) {
    _log('onInvitationCancelled', info);
    _signalingSubject.add(CallEvent(CallState.beCanceled, info));
  }

  void onInvitationTimeout(SignalingInfo info) {
    _log('onInvitationTimeout', info);
    _signalingSubject.add(CallEvent(CallState.timeout, info));
  }

  void onInviteeAccepted(SignalingInfo info) {
    _log('onInviteeAccepted', info);
    _signalingSubject.add(CallEvent(CallState.beAccepted, info));
  }

  void onInviteeRejected(SignalingInfo info) {
    _log('onInviteeRejected', info);
    _signalingSubject.add(CallEvent(CallState.beRejected, info));
  }

  void onReceiveNewInvitation(SignalingInfo info) {
    _log('onReceiveNewInvitation', info);
    _signalingSubject.add(CallEvent(CallState.beCalled, info));
  }

  void onInviteeAcceptedByOtherDevice(SignalingInfo info) {
    _log('onInviteeAcceptedByOtherDevice', info);
    _signalingSubject.add(CallEvent(CallState.otherAccepted, info));
  }

  void onInviteeRejectedByOtherDevice(SignalingInfo info) {
    _log('onInviteeRejectedByOtherDevice', info);
    _signalingSubject.add(CallEvent(CallState.otherReject, info));
  }

  void onHangup(SignalingInfo info) {
    _log('onHangup', info);
    _signalingSubject.add(CallEvent(CallState.beHangup, info));
  }

  // --- Operations ---

  Future<SignalingCertificate> invite({
    required SignalingInfo info,
  }) async {
    final offlinePushInfo = Config.offlinePushInfo;
    final newPushInfo = OfflinePushInfo(
      title: offlinePushInfo.title,
      desc: offlinePushInfo.desc,
      iOSBadgeCount: offlinePushInfo.iOSBadgeCount,
    )..title = StrRes.offlineCallMessage;

    return OpenIM.iMManager.signalingManager.signalingInvite(
        info: info
          ..invitation?.timeout = _waitTimeout
          ..offlinePushInfo = newPushInfo);
  }

  Future<SignalingCertificate> inviteInGroup({
    required SignalingInfo info,
  }) async {
    final offlinePushInfo = Config.offlinePushInfo;
    final newPushInfo = OfflinePushInfo(
      title: offlinePushInfo.title,
      desc: offlinePushInfo.desc,
      iOSBadgeCount: offlinePushInfo.iOSBadgeCount,
    )..title = StrRes.offlineCallMessage;

    return OpenIM.iMManager.signalingManager.signalingInviteInGroup(
        info: info
          ..invitation?.timeout = _waitTimeout
          ..offlinePushInfo = newPushInfo);
  }

  Future<SignalingCertificate> accept({
    required SignalingInfo info,
  }) async {
    return OpenIM.iMManager.signalingManager.signalingAccept(info: info);
  }

  Future<void> reject({
    required SignalingInfo info,
  }) async {
    return OpenIM.iMManager.signalingManager.signalingReject(info: info);
  }

  Future<void> cancel({
    required SignalingInfo info,
  }) async {
    return OpenIM.iMManager.signalingManager.signalingCancel(info: info);
  }

  Future<void> hangup({
    required SignalingInfo info,
  }) async {
    return OpenIM.iMManager.signalingManager.signalingHungUp(info: info);
  }

  void _log(String method, SignalingInfo info) {
    Logger.print(
      '[Livekit service] $method',
      fileName: 'signaling_service.dart',
      keyAndValues: ['opUserID', info.userID],
    );
  }
}
