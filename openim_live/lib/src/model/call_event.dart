import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';

enum CallState {
  call, // Initiated a call (active invitation)
  beCalled, // Received a call (being invited)
  reject, // Rejected the call
  beRejected, // Call was rejected by the other party
  beAccepted, // Call was accepted by the other party
  hangup, // Hung up actively
  beHangup, // The other party hung up
  otherAccepted, // Accepted on another device
  otherReject, // Rejected on another device
  cancel, // Canceled actively
  beCanceled, // Call was canceled by the caller
  timeout, // Timeout
  join, // Actively joined (group call)
  networkError, // Network error
  connecting, // Connecting
  calling, // In call (ongoing call)
  interruption // Interruption
}

class CallEvent {
  CallState state;
  SignalingInfo data;
  dynamic fields;

  CallEvent(this.state, this.data, {this.fields});

  @override
  String toString() {
    return 'CallEvent{state: $state, data: $data, fields: $fields}';
  }
}

class SignalingMessageEvent {
  Message message;
  String? userID;
  String? groupID;
  int sessionType;

  SignalingMessageEvent(
    this.message,
    this.sessionType,
    this.userID,
    this.groupID,
  );

  bool get isSingleChat => sessionType == ConversationType.single;

  bool get isGroupChat => sessionType == ConversationType.group || sessionType == ConversationType.superGroup;
}

enum CallType { audio, video }

enum CallObj { single, group }
