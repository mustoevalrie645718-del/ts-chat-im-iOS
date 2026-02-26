//
//  Generated code. Do not modify.
//  source: meeting.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'wrapperspb.pbjson.dart' as $0;

@$core.Deprecated('Use dayOfWeekDescriptor instead')
const DayOfWeek$json = {
  '1': 'DayOfWeek',
  '2': [
    {'1': 'SUNDAY', '2': 0},
    {'1': 'MONDAY', '2': 1},
    {'1': 'TUESDAY', '2': 2},
    {'1': 'WEDNESDAY', '2': 3},
    {'1': 'THURSDAY', '2': 4},
    {'1': 'FRIDAY', '2': 5},
    {'1': 'SATURDAY', '2': 6},
  ],
};

/// Descriptor for `DayOfWeek`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List dayOfWeekDescriptor = $convert.base64Decode(
    'CglEYXlPZldlZWsSCgoGU1VOREFZEAASCgoGTU9OREFZEAESCwoHVFVFU0RBWRACEg0KCVdFRE'
    '5FU0RBWRADEgwKCFRIVVJTREFZEAQSCgoGRlJJREFZEAUSDAoIU0FUVVJEQVkQBg==');

@$core.Deprecated('Use kickOffReasonDescriptor instead')
const KickOffReason$json = {
  '1': 'KickOffReason',
  '2': [
    {'1': 'DuplicatedLogin', '2': 0},
    {'1': 'Offline', '2': 1},
    {'1': 'Logout', '2': 2},
  ],
};

/// Descriptor for `KickOffReason`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List kickOffReasonDescriptor = $convert.base64Decode(
    'Cg1LaWNrT2ZmUmVhc29uEhMKD0R1cGxpY2F0ZWRMb2dpbhAAEgsKB09mZmxpbmUQARIKCgZMb2'
    'dvdXQQAg==');

@$core.Deprecated('Use meetingEndTypeDescriptor instead')
const MeetingEndType$json = {
  '1': 'MeetingEndType',
  '2': [
    {'1': 'CancelType', '2': 0},
    {'1': 'EndType', '2': 1},
  ],
};

/// Descriptor for `MeetingEndType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List meetingEndTypeDescriptor = $convert.base64Decode(
    'Cg5NZWV0aW5nRW5kVHlwZRIOCgpDYW5jZWxUeXBlEAASCwoHRW5kVHlwZRAB');

@$core.Deprecated('Use liveKitDescriptor instead')
const LiveKit$json = {
  '1': 'LiveKit',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `LiveKit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List liveKitDescriptor = $convert.base64Decode(
    'CgdMaXZlS2l0EhQKBXRva2VuGAEgASgJUgV0b2tlbhIQCgN1cmwYAiABKAlSA3VybA==');

@$core.Deprecated('Use systemGeneratedMeetingInfoDescriptor instead')
const SystemGeneratedMeetingInfo$json = {
  '1': 'SystemGeneratedMeetingInfo',
  '2': [
    {'1': 'creatorUserID', '3': 1, '4': 1, '5': 9, '10': 'creatorUserID'},
    {'1': 'creatorNickname', '3': 2, '4': 1, '5': 9, '10': 'creatorNickname'},
    {'1': 'status', '3': 3, '4': 1, '5': 9, '10': 'status'},
    {'1': 'startTime', '3': 4, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'meetingID', '3': 5, '4': 1, '5': 9, '10': 'meetingID'},
  ],
};

/// Descriptor for `SystemGeneratedMeetingInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemGeneratedMeetingInfoDescriptor = $convert.base64Decode(
    'ChpTeXN0ZW1HZW5lcmF0ZWRNZWV0aW5nSW5mbxIkCg1jcmVhdG9yVXNlcklEGAEgASgJUg1jcm'
    'VhdG9yVXNlcklEEigKD2NyZWF0b3JOaWNrbmFtZRgCIAEoCVIPY3JlYXRvck5pY2tuYW1lEhYK'
    'BnN0YXR1cxgDIAEoCVIGc3RhdHVzEhwKCXN0YXJ0VGltZRgEIAEoA1IJc3RhcnRUaW1lEhwKCW'
    '1lZXRpbmdJRBgFIAEoCVIJbWVldGluZ0lE');

@$core.Deprecated('Use creatorDefinedMeetingInfoDescriptor instead')
const CreatorDefinedMeetingInfo$json = {
  '1': 'CreatorDefinedMeetingInfo',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'scheduledTime', '3': 2, '4': 1, '5': 3, '10': 'scheduledTime'},
    {'1': 'meetingDuration', '3': 3, '4': 1, '5': 3, '10': 'meetingDuration'},
    {'1': 'password', '3': 4, '4': 1, '5': 9, '10': 'password'},
    {'1': 'timeZone', '3': 5, '4': 1, '5': 9, '10': 'timeZone'},
    {'1': 'hostUserID', '3': 6, '4': 1, '5': 9, '10': 'hostUserID'},
    {'1': 'coHostUSerID', '3': 7, '4': 3, '5': 9, '10': 'coHostUSerID'},
  ],
};

/// Descriptor for `CreatorDefinedMeetingInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List creatorDefinedMeetingInfoDescriptor = $convert.base64Decode(
    'ChlDcmVhdG9yRGVmaW5lZE1lZXRpbmdJbmZvEhQKBXRpdGxlGAEgASgJUgV0aXRsZRIkCg1zY2'
    'hlZHVsZWRUaW1lGAIgASgDUg1zY2hlZHVsZWRUaW1lEigKD21lZXRpbmdEdXJhdGlvbhgDIAEo'
    'A1IPbWVldGluZ0R1cmF0aW9uEhoKCHBhc3N3b3JkGAQgASgJUghwYXNzd29yZBIaCgh0aW1lWm'
    '9uZRgFIAEoCVIIdGltZVpvbmUSHgoKaG9zdFVzZXJJRBgGIAEoCVIKaG9zdFVzZXJJRBIiCgxj'
    'b0hvc3RVU2VySUQYByADKAlSDGNvSG9zdFVTZXJJRA==');

@$core.Deprecated('Use meetingInfoDescriptor instead')
const MeetingInfo$json = {
  '1': 'MeetingInfo',
  '2': [
    {'1': 'systemGenerated', '3': 1, '4': 1, '5': 11, '6': '.openmeeting.meeting.SystemGeneratedMeetingInfo', '10': 'systemGenerated'},
    {'1': 'creatorDefinedMeeting', '3': 2, '4': 1, '5': 11, '6': '.openmeeting.meeting.CreatorDefinedMeetingInfo', '10': 'creatorDefinedMeeting'},
  ],
};

/// Descriptor for `MeetingInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingInfoDescriptor = $convert.base64Decode(
    'CgtNZWV0aW5nSW5mbxJZCg9zeXN0ZW1HZW5lcmF0ZWQYASABKAsyLy5vcGVubWVldGluZy5tZW'
    'V0aW5nLlN5c3RlbUdlbmVyYXRlZE1lZXRpbmdJbmZvUg9zeXN0ZW1HZW5lcmF0ZWQSZAoVY3Jl'
    'YXRvckRlZmluZWRNZWV0aW5nGAIgASgLMi4ub3Blbm1lZXRpbmcubWVldGluZy5DcmVhdG9yRG'
    'VmaW5lZE1lZXRpbmdJbmZvUhVjcmVhdG9yRGVmaW5lZE1lZXRpbmc=');

@$core.Deprecated('Use meetingRepeatInfoDescriptor instead')
const MeetingRepeatInfo$json = {
  '1': 'MeetingRepeatInfo',
  '2': [
    {'1': 'endDate', '3': 1, '4': 1, '5': 3, '10': 'endDate'},
    {'1': 'repeatTimes', '3': 2, '4': 1, '5': 5, '10': 'repeatTimes'},
    {'1': 'repeatType', '3': 3, '4': 1, '5': 9, '10': 'repeatType'},
    {'1': 'uintType', '3': 4, '4': 1, '5': 9, '10': 'uintType'},
    {'1': 'interval', '3': 5, '4': 1, '5': 5, '10': 'interval'},
    {'1': 'repeatDaysOfWeek', '3': 6, '4': 3, '5': 14, '6': '.openmeeting.meeting.DayOfWeek', '10': 'repeatDaysOfWeek'},
  ],
};

/// Descriptor for `MeetingRepeatInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingRepeatInfoDescriptor = $convert.base64Decode(
    'ChFNZWV0aW5nUmVwZWF0SW5mbxIYCgdlbmREYXRlGAEgASgDUgdlbmREYXRlEiAKC3JlcGVhdF'
    'RpbWVzGAIgASgFUgtyZXBlYXRUaW1lcxIeCgpyZXBlYXRUeXBlGAMgASgJUgpyZXBlYXRUeXBl'
    'EhoKCHVpbnRUeXBlGAQgASgJUgh1aW50VHlwZRIaCghpbnRlcnZhbBgFIAEoBVIIaW50ZXJ2YW'
    'wSSgoQcmVwZWF0RGF5c09mV2VlaxgGIAMoDjIeLm9wZW5tZWV0aW5nLm1lZXRpbmcuRGF5T2ZX'
    'ZWVrUhByZXBlYXREYXlzT2ZXZWVr');

@$core.Deprecated('Use meetingSettingDescriptor instead')
const MeetingSetting$json = {
  '1': 'MeetingSetting',
  '2': [
    {'1': 'canParticipantsEnableCamera', '3': 1, '4': 1, '5': 8, '10': 'canParticipantsEnableCamera'},
    {'1': 'canParticipantsUnmuteMicrophone', '3': 2, '4': 1, '5': 8, '10': 'canParticipantsUnmuteMicrophone'},
    {'1': 'canParticipantsShareScreen', '3': 3, '4': 1, '5': 8, '10': 'canParticipantsShareScreen'},
    {'1': 'disableCameraOnJoin', '3': 4, '4': 1, '5': 8, '10': 'disableCameraOnJoin'},
    {'1': 'disableMicrophoneOnJoin', '3': 5, '4': 1, '5': 8, '10': 'disableMicrophoneOnJoin'},
    {'1': 'canParticipantJoinMeetingEarly', '3': 6, '4': 1, '5': 8, '10': 'canParticipantJoinMeetingEarly'},
    {'1': 'lockMeeting', '3': 7, '4': 1, '5': 8, '10': 'lockMeeting'},
    {'1': 'audioEncouragement', '3': 8, '4': 1, '5': 8, '10': 'audioEncouragement'},
    {'1': 'videoMirroring', '3': 9, '4': 1, '5': 8, '10': 'videoMirroring'},
  ],
};

/// Descriptor for `MeetingSetting`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingSettingDescriptor = $convert.base64Decode(
    'Cg5NZWV0aW5nU2V0dGluZxJAChtjYW5QYXJ0aWNpcGFudHNFbmFibGVDYW1lcmEYASABKAhSG2'
    'NhblBhcnRpY2lwYW50c0VuYWJsZUNhbWVyYRJICh9jYW5QYXJ0aWNpcGFudHNVbm11dGVNaWNy'
    'b3Bob25lGAIgASgIUh9jYW5QYXJ0aWNpcGFudHNVbm11dGVNaWNyb3Bob25lEj4KGmNhblBhcn'
    'RpY2lwYW50c1NoYXJlU2NyZWVuGAMgASgIUhpjYW5QYXJ0aWNpcGFudHNTaGFyZVNjcmVlbhIw'
    'ChNkaXNhYmxlQ2FtZXJhT25Kb2luGAQgASgIUhNkaXNhYmxlQ2FtZXJhT25Kb2luEjgKF2Rpc2'
    'FibGVNaWNyb3Bob25lT25Kb2luGAUgASgIUhdkaXNhYmxlTWljcm9waG9uZU9uSm9pbhJGCh5j'
    'YW5QYXJ0aWNpcGFudEpvaW5NZWV0aW5nRWFybHkYBiABKAhSHmNhblBhcnRpY2lwYW50Sm9pbk'
    '1lZXRpbmdFYXJseRIgCgtsb2NrTWVldGluZxgHIAEoCFILbG9ja01lZXRpbmcSLgoSYXVkaW9F'
    'bmNvdXJhZ2VtZW50GAggASgIUhJhdWRpb0VuY291cmFnZW1lbnQSJgoOdmlkZW9NaXJyb3Jpbm'
    'cYCSABKAhSDnZpZGVvTWlycm9yaW5n');

@$core.Deprecated('Use meetingInfoSettingDescriptor instead')
const MeetingInfoSetting$json = {
  '1': 'MeetingInfoSetting',
  '2': [
    {'1': 'info', '3': 1, '4': 1, '5': 11, '6': '.openmeeting.meeting.MeetingInfo', '10': 'info'},
    {'1': 'setting', '3': 2, '4': 1, '5': 11, '6': '.openmeeting.meeting.MeetingSetting', '10': 'setting'},
    {'1': 'repeatInfo', '3': 3, '4': 1, '5': 11, '6': '.openmeeting.meeting.MeetingRepeatInfo', '10': 'repeatInfo'},
  ],
};

/// Descriptor for `MeetingInfoSetting`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingInfoSettingDescriptor = $convert.base64Decode(
    'ChJNZWV0aW5nSW5mb1NldHRpbmcSNAoEaW5mbxgBIAEoCzIgLm9wZW5tZWV0aW5nLm1lZXRpbm'
    'cuTWVldGluZ0luZm9SBGluZm8SPQoHc2V0dGluZxgCIAEoCzIjLm9wZW5tZWV0aW5nLm1lZXRp'
    'bmcuTWVldGluZ1NldHRpbmdSB3NldHRpbmcSRgoKcmVwZWF0SW5mbxgDIAEoCzImLm9wZW5tZW'
    'V0aW5nLm1lZXRpbmcuTWVldGluZ1JlcGVhdEluZm9SCnJlcGVhdEluZm8=');

@$core.Deprecated('Use userInfoDescriptor instead')
const UserInfo$json = {
  '1': 'UserInfo',
  '2': [
    {'1': 'userID', '3': 1, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'nickname', '3': 2, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'account', '3': 3, '4': 1, '5': 9, '10': 'account'},
    {'1': 'faceURL', '3': 4, '4': 1, '5': 9, '10': 'faceURL'},
  ],
};

/// Descriptor for `UserInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userInfoDescriptor = $convert.base64Decode(
    'CghVc2VySW5mbxIWCgZ1c2VySUQYASABKAlSBnVzZXJJRBIaCghuaWNrbmFtZRgCIAEoCVIIbm'
    'lja25hbWUSGAoHYWNjb3VudBgDIAEoCVIHYWNjb3VudBIYCgdmYWNlVVJMGAQgASgJUgdmYWNl'
    'VVJM');

@$core.Deprecated('Use participantMetaDataDescriptor instead')
const ParticipantMetaData$json = {
  '1': 'ParticipantMetaData',
  '2': [
    {'1': 'userInfo', '3': 1, '4': 1, '5': 11, '6': '.openmeeting.meeting.UserInfo', '10': 'userInfo'},
  ],
};

/// Descriptor for `ParticipantMetaData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantMetaDataDescriptor = $convert.base64Decode(
    'ChNQYXJ0aWNpcGFudE1ldGFEYXRhEjkKCHVzZXJJbmZvGAEgASgLMh0ub3Blbm1lZXRpbmcubW'
    'VldGluZy5Vc2VySW5mb1IIdXNlckluZm8=');

@$core.Deprecated('Use bookMeetingReqDescriptor instead')
const BookMeetingReq$json = {
  '1': 'BookMeetingReq',
  '2': [
    {'1': 'creatorUserID', '3': 1, '4': 1, '5': 9, '10': 'creatorUserID'},
    {'1': 'creatorDefinedMeetingInfo', '3': 2, '4': 1, '5': 11, '6': '.openmeeting.meeting.CreatorDefinedMeetingInfo', '10': 'creatorDefinedMeetingInfo'},
    {'1': 'setting', '3': 3, '4': 1, '5': 11, '6': '.openmeeting.meeting.MeetingSetting', '10': 'setting'},
    {'1': 'repeatInfo', '3': 4, '4': 1, '5': 11, '6': '.openmeeting.meeting.MeetingRepeatInfo', '10': 'repeatInfo'},
  ],
};

/// Descriptor for `BookMeetingReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bookMeetingReqDescriptor = $convert.base64Decode(
    'Cg5Cb29rTWVldGluZ1JlcRIkCg1jcmVhdG9yVXNlcklEGAEgASgJUg1jcmVhdG9yVXNlcklEEm'
    'wKGWNyZWF0b3JEZWZpbmVkTWVldGluZ0luZm8YAiABKAsyLi5vcGVubWVldGluZy5tZWV0aW5n'
    'LkNyZWF0b3JEZWZpbmVkTWVldGluZ0luZm9SGWNyZWF0b3JEZWZpbmVkTWVldGluZ0luZm8SPQ'
    'oHc2V0dGluZxgDIAEoCzIjLm9wZW5tZWV0aW5nLm1lZXRpbmcuTWVldGluZ1NldHRpbmdSB3Nl'
    'dHRpbmcSRgoKcmVwZWF0SW5mbxgEIAEoCzImLm9wZW5tZWV0aW5nLm1lZXRpbmcuTWVldGluZ1'
    'JlcGVhdEluZm9SCnJlcGVhdEluZm8=');

@$core.Deprecated('Use bookMeetingRespDescriptor instead')
const BookMeetingResp$json = {
  '1': 'BookMeetingResp',
  '2': [
    {'1': 'detail', '3': 1, '4': 1, '5': 11, '6': '.openmeeting.meeting.MeetingInfoSetting', '10': 'detail'},
  ],
};

/// Descriptor for `BookMeetingResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bookMeetingRespDescriptor = $convert.base64Decode(
    'Cg9Cb29rTWVldGluZ1Jlc3ASPwoGZGV0YWlsGAEgASgLMicub3Blbm1lZXRpbmcubWVldGluZy'
    '5NZWV0aW5nSW5mb1NldHRpbmdSBmRldGFpbA==');

@$core.Deprecated('Use createImmediateMeetingReqDescriptor instead')
const CreateImmediateMeetingReq$json = {
  '1': 'CreateImmediateMeetingReq',
  '2': [
    {'1': 'creatorUserID', '3': 1, '4': 1, '5': 9, '10': 'creatorUserID'},
    {'1': 'creatorDefinedMeetingInfo', '3': 2, '4': 1, '5': 11, '6': '.openmeeting.meeting.CreatorDefinedMeetingInfo', '10': 'creatorDefinedMeetingInfo'},
    {'1': 'setting', '3': 3, '4': 1, '5': 11, '6': '.openmeeting.meeting.MeetingSetting', '10': 'setting'},
  ],
};

/// Descriptor for `CreateImmediateMeetingReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createImmediateMeetingReqDescriptor = $convert.base64Decode(
    'ChlDcmVhdGVJbW1lZGlhdGVNZWV0aW5nUmVxEiQKDWNyZWF0b3JVc2VySUQYASABKAlSDWNyZW'
    'F0b3JVc2VySUQSbAoZY3JlYXRvckRlZmluZWRNZWV0aW5nSW5mbxgCIAEoCzIuLm9wZW5tZWV0'
    'aW5nLm1lZXRpbmcuQ3JlYXRvckRlZmluZWRNZWV0aW5nSW5mb1IZY3JlYXRvckRlZmluZWRNZW'
    'V0aW5nSW5mbxI9CgdzZXR0aW5nGAMgASgLMiMub3Blbm1lZXRpbmcubWVldGluZy5NZWV0aW5n'
    'U2V0dGluZ1IHc2V0dGluZw==');

@$core.Deprecated('Use createImmediateMeetingRespDescriptor instead')
const CreateImmediateMeetingResp$json = {
  '1': 'CreateImmediateMeetingResp',
  '2': [
    {'1': 'detail', '3': 1, '4': 1, '5': 11, '6': '.openmeeting.meeting.MeetingInfoSetting', '10': 'detail'},
    {'1': 'liveKit', '3': 2, '4': 1, '5': 11, '6': '.openmeeting.meeting.LiveKit', '10': 'liveKit'},
  ],
};

/// Descriptor for `CreateImmediateMeetingResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createImmediateMeetingRespDescriptor = $convert.base64Decode(
    'ChpDcmVhdGVJbW1lZGlhdGVNZWV0aW5nUmVzcBI/CgZkZXRhaWwYASABKAsyJy5vcGVubWVldG'
    'luZy5tZWV0aW5nLk1lZXRpbmdJbmZvU2V0dGluZ1IGZGV0YWlsEjYKB2xpdmVLaXQYAiABKAsy'
    'HC5vcGVubWVldGluZy5tZWV0aW5nLkxpdmVLaXRSB2xpdmVLaXQ=');

@$core.Deprecated('Use joinMeetingReqDescriptor instead')
const JoinMeetingReq$json = {
  '1': 'JoinMeetingReq',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'userID', '3': 2, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'password', '3': 3, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `JoinMeetingReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinMeetingReqDescriptor = $convert.base64Decode(
    'Cg5Kb2luTWVldGluZ1JlcRIcCgltZWV0aW5nSUQYASABKAlSCW1lZXRpbmdJRBIWCgZ1c2VySU'
    'QYAiABKAlSBnVzZXJJRBIaCghwYXNzd29yZBgDIAEoCVIIcGFzc3dvcmQ=');

@$core.Deprecated('Use joinMeetingRespDescriptor instead')
const JoinMeetingResp$json = {
  '1': 'JoinMeetingResp',
  '2': [
    {'1': 'liveKit', '3': 1, '4': 1, '5': 11, '6': '.openmeeting.meeting.LiveKit', '10': 'liveKit'},
  ],
};

/// Descriptor for `JoinMeetingResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinMeetingRespDescriptor = $convert.base64Decode(
    'Cg9Kb2luTWVldGluZ1Jlc3ASNgoHbGl2ZUtpdBgBIAEoCzIcLm9wZW5tZWV0aW5nLm1lZXRpbm'
    'cuTGl2ZUtpdFIHbGl2ZUtpdA==');

@$core.Deprecated('Use getMeetingTokenReqDescriptor instead')
const GetMeetingTokenReq$json = {
  '1': 'GetMeetingTokenReq',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'userID', '3': 2, '4': 1, '5': 9, '10': 'userID'},
  ],
};

/// Descriptor for `GetMeetingTokenReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMeetingTokenReqDescriptor = $convert.base64Decode(
    'ChJHZXRNZWV0aW5nVG9rZW5SZXESHAoJbWVldGluZ0lEGAEgASgJUgltZWV0aW5nSUQSFgoGdX'
    'NlcklEGAIgASgJUgZ1c2VySUQ=');

@$core.Deprecated('Use getMeetingTokenRespDescriptor instead')
const GetMeetingTokenResp$json = {
  '1': 'GetMeetingTokenResp',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'liveKit', '3': 2, '4': 1, '5': 11, '6': '.openmeeting.meeting.LiveKit', '10': 'liveKit'},
  ],
};

/// Descriptor for `GetMeetingTokenResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMeetingTokenRespDescriptor = $convert.base64Decode(
    'ChNHZXRNZWV0aW5nVG9rZW5SZXNwEhwKCW1lZXRpbmdJRBgBIAEoCVIJbWVldGluZ0lEEjYKB2'
    'xpdmVLaXQYAiABKAsyHC5vcGVubWVldGluZy5tZWV0aW5nLkxpdmVLaXRSB2xpdmVLaXQ=');

@$core.Deprecated('Use leaveMeetingReqDescriptor instead')
const LeaveMeetingReq$json = {
  '1': 'LeaveMeetingReq',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'userID', '3': 2, '4': 1, '5': 9, '10': 'userID'},
  ],
};

/// Descriptor for `LeaveMeetingReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveMeetingReqDescriptor = $convert.base64Decode(
    'Cg9MZWF2ZU1lZXRpbmdSZXESHAoJbWVldGluZ0lEGAEgASgJUgltZWV0aW5nSUQSFgoGdXNlck'
    'lEGAIgASgJUgZ1c2VySUQ=');

@$core.Deprecated('Use leaveMeetingRespDescriptor instead')
const LeaveMeetingResp$json = {
  '1': 'LeaveMeetingResp',
};

/// Descriptor for `LeaveMeetingResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveMeetingRespDescriptor = $convert.base64Decode(
    'ChBMZWF2ZU1lZXRpbmdSZXNw');

@$core.Deprecated('Use endMeetingReqDescriptor instead')
const EndMeetingReq$json = {
  '1': 'EndMeetingReq',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'userID', '3': 2, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'endType', '3': 3, '4': 1, '5': 14, '6': '.openmeeting.meeting.MeetingEndType', '10': 'endType'},
  ],
};

/// Descriptor for `EndMeetingReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List endMeetingReqDescriptor = $convert.base64Decode(
    'Cg1FbmRNZWV0aW5nUmVxEhwKCW1lZXRpbmdJRBgBIAEoCVIJbWVldGluZ0lEEhYKBnVzZXJJRB'
    'gCIAEoCVIGdXNlcklEEj0KB2VuZFR5cGUYAyABKA4yIy5vcGVubWVldGluZy5tZWV0aW5nLk1l'
    'ZXRpbmdFbmRUeXBlUgdlbmRUeXBl');

@$core.Deprecated('Use endMeetingRespDescriptor instead')
const EndMeetingResp$json = {
  '1': 'EndMeetingResp',
};

/// Descriptor for `EndMeetingResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List endMeetingRespDescriptor = $convert.base64Decode(
    'Cg5FbmRNZWV0aW5nUmVzcA==');

@$core.Deprecated('Use getMeetingsReqDescriptor instead')
const GetMeetingsReq$json = {
  '1': 'GetMeetingsReq',
  '2': [
    {'1': 'userID', '3': 1, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'status', '3': 2, '4': 3, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `GetMeetingsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMeetingsReqDescriptor = $convert.base64Decode(
    'Cg5HZXRNZWV0aW5nc1JlcRIWCgZ1c2VySUQYASABKAlSBnVzZXJJRBIWCgZzdGF0dXMYAiADKA'
    'lSBnN0YXR1cw==');

@$core.Deprecated('Use getMeetingsRespDescriptor instead')
const GetMeetingsResp$json = {
  '1': 'GetMeetingsResp',
  '2': [
    {'1': 'meetingDetails', '3': 1, '4': 3, '5': 11, '6': '.openmeeting.meeting.MeetingInfoSetting', '10': 'meetingDetails'},
  ],
};

/// Descriptor for `GetMeetingsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMeetingsRespDescriptor = $convert.base64Decode(
    'Cg9HZXRNZWV0aW5nc1Jlc3ASTwoObWVldGluZ0RldGFpbHMYASADKAsyJy5vcGVubWVldGluZy'
    '5tZWV0aW5nLk1lZXRpbmdJbmZvU2V0dGluZ1IObWVldGluZ0RldGFpbHM=');

@$core.Deprecated('Use getMeetingReqDescriptor instead')
const GetMeetingReq$json = {
  '1': 'GetMeetingReq',
  '2': [
    {'1': 'userID', '3': 1, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'meetingID', '3': 2, '4': 1, '5': 9, '10': 'meetingID'},
  ],
};

/// Descriptor for `GetMeetingReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMeetingReqDescriptor = $convert.base64Decode(
    'Cg1HZXRNZWV0aW5nUmVxEhYKBnVzZXJJRBgBIAEoCVIGdXNlcklEEhwKCW1lZXRpbmdJRBgCIA'
    'EoCVIJbWVldGluZ0lE');

@$core.Deprecated('Use getMeetingRespDescriptor instead')
const GetMeetingResp$json = {
  '1': 'GetMeetingResp',
  '2': [
    {'1': 'meetingDetail', '3': 1, '4': 1, '5': 11, '6': '.openmeeting.meeting.MeetingInfoSetting', '10': 'meetingDetail'},
  ],
};

/// Descriptor for `GetMeetingResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMeetingRespDescriptor = $convert.base64Decode(
    'Cg5HZXRNZWV0aW5nUmVzcBJNCg1tZWV0aW5nRGV0YWlsGAEgASgLMicub3Blbm1lZXRpbmcubW'
    'VldGluZy5NZWV0aW5nSW5mb1NldHRpbmdSDW1lZXRpbmdEZXRhaWw=');

@$core.Deprecated('Use modifyMeetingParticipantNickNameReqDescriptor instead')
const ModifyMeetingParticipantNickNameReq$json = {
  '1': 'ModifyMeetingParticipantNickNameReq',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'userID', '3': 2, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'participantUserID', '3': 3, '4': 1, '5': 9, '10': 'participantUserID'},
    {'1': 'nickname', '3': 4, '4': 1, '5': 9, '10': 'nickname'},
  ],
};

/// Descriptor for `ModifyMeetingParticipantNickNameReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List modifyMeetingParticipantNickNameReqDescriptor = $convert.base64Decode(
    'CiNNb2RpZnlNZWV0aW5nUGFydGljaXBhbnROaWNrTmFtZVJlcRIcCgltZWV0aW5nSUQYASABKA'
    'lSCW1lZXRpbmdJRBIWCgZ1c2VySUQYAiABKAlSBnVzZXJJRBIsChFwYXJ0aWNpcGFudFVzZXJJ'
    'RBgDIAEoCVIRcGFydGljaXBhbnRVc2VySUQSGgoIbmlja25hbWUYBCABKAlSCG5pY2tuYW1l');

@$core.Deprecated('Use modifyMeetingParticipantNickNameRespDescriptor instead')
const ModifyMeetingParticipantNickNameResp$json = {
  '1': 'ModifyMeetingParticipantNickNameResp',
};

/// Descriptor for `ModifyMeetingParticipantNickNameResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List modifyMeetingParticipantNickNameRespDescriptor = $convert.base64Decode(
    'CiRNb2RpZnlNZWV0aW5nUGFydGljaXBhbnROaWNrTmFtZVJlc3A=');

@$core.Deprecated('Use updateMeetingRequestDescriptor instead')
const UpdateMeetingRequest$json = {
  '1': 'UpdateMeetingRequest',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'updatingUserID', '3': 2, '4': 1, '5': 9, '10': 'updatingUserID'},
    {'1': 'title', '3': 3, '4': 1, '5': 11, '6': '.openim.protobuf.StringValue', '10': 'title'},
    {'1': 'scheduledTime', '3': 4, '4': 1, '5': 11, '6': '.openim.protobuf.Int64Value', '10': 'scheduledTime'},
    {'1': 'meetingDuration', '3': 5, '4': 1, '5': 11, '6': '.openim.protobuf.Int64Value', '10': 'meetingDuration'},
    {'1': 'password', '3': 6, '4': 1, '5': 11, '6': '.openim.protobuf.StringValue', '10': 'password'},
    {'1': 'timeZone', '3': 7, '4': 1, '5': 11, '6': '.openim.protobuf.StringValue', '10': 'timeZone'},
    {'1': 'repeatInfo', '3': 8, '4': 1, '5': 11, '6': '.openmeeting.meeting.MeetingRepeatInfo', '10': 'repeatInfo'},
    {'1': 'canParticipantsEnableCamera', '3': 9, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'canParticipantsEnableCamera'},
    {'1': 'canParticipantsUnmuteMicrophone', '3': 10, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'canParticipantsUnmuteMicrophone'},
    {'1': 'canParticipantsShareScreen', '3': 11, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'canParticipantsShareScreen'},
    {'1': 'disableCameraOnJoin', '3': 12, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'disableCameraOnJoin'},
    {'1': 'disableMicrophoneOnJoin', '3': 13, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'disableMicrophoneOnJoin'},
    {'1': 'canParticipantJoinMeetingEarly', '3': 14, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'canParticipantJoinMeetingEarly'},
    {'1': 'lockMeeting', '3': 15, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'lockMeeting'},
    {'1': 'audioEncouragement', '3': 16, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'audioEncouragement'},
    {'1': 'videoMirroring', '3': 17, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'videoMirroring'},
  ],
};

/// Descriptor for `UpdateMeetingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateMeetingRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVNZWV0aW5nUmVxdWVzdBIcCgltZWV0aW5nSUQYASABKAlSCW1lZXRpbmdJRBImCg'
    '51cGRhdGluZ1VzZXJJRBgCIAEoCVIOdXBkYXRpbmdVc2VySUQSMgoFdGl0bGUYAyABKAsyHC5v'
    'cGVuaW0ucHJvdG9idWYuU3RyaW5nVmFsdWVSBXRpdGxlEkEKDXNjaGVkdWxlZFRpbWUYBCABKA'
    'syGy5vcGVuaW0ucHJvdG9idWYuSW50NjRWYWx1ZVINc2NoZWR1bGVkVGltZRJFCg9tZWV0aW5n'
    'RHVyYXRpb24YBSABKAsyGy5vcGVuaW0ucHJvdG9idWYuSW50NjRWYWx1ZVIPbWVldGluZ0R1cm'
    'F0aW9uEjgKCHBhc3N3b3JkGAYgASgLMhwub3BlbmltLnByb3RvYnVmLlN0cmluZ1ZhbHVlUghw'
    'YXNzd29yZBI4Cgh0aW1lWm9uZRgHIAEoCzIcLm9wZW5pbS5wcm90b2J1Zi5TdHJpbmdWYWx1ZV'
    'IIdGltZVpvbmUSRgoKcmVwZWF0SW5mbxgIIAEoCzImLm9wZW5tZWV0aW5nLm1lZXRpbmcuTWVl'
    'dGluZ1JlcGVhdEluZm9SCnJlcGVhdEluZm8SXAobY2FuUGFydGljaXBhbnRzRW5hYmxlQ2FtZX'
    'JhGAkgASgLMhoub3BlbmltLnByb3RvYnVmLkJvb2xWYWx1ZVIbY2FuUGFydGljaXBhbnRzRW5h'
    'YmxlQ2FtZXJhEmQKH2NhblBhcnRpY2lwYW50c1VubXV0ZU1pY3JvcGhvbmUYCiABKAsyGi5vcG'
    'VuaW0ucHJvdG9idWYuQm9vbFZhbHVlUh9jYW5QYXJ0aWNpcGFudHNVbm11dGVNaWNyb3Bob25l'
    'EloKGmNhblBhcnRpY2lwYW50c1NoYXJlU2NyZWVuGAsgASgLMhoub3BlbmltLnByb3RvYnVmLk'
    'Jvb2xWYWx1ZVIaY2FuUGFydGljaXBhbnRzU2hhcmVTY3JlZW4STAoTZGlzYWJsZUNhbWVyYU9u'
    'Sm9pbhgMIAEoCzIaLm9wZW5pbS5wcm90b2J1Zi5Cb29sVmFsdWVSE2Rpc2FibGVDYW1lcmFPbk'
    'pvaW4SVAoXZGlzYWJsZU1pY3JvcGhvbmVPbkpvaW4YDSABKAsyGi5vcGVuaW0ucHJvdG9idWYu'
    'Qm9vbFZhbHVlUhdkaXNhYmxlTWljcm9waG9uZU9uSm9pbhJiCh5jYW5QYXJ0aWNpcGFudEpvaW'
    '5NZWV0aW5nRWFybHkYDiABKAsyGi5vcGVuaW0ucHJvdG9idWYuQm9vbFZhbHVlUh5jYW5QYXJ0'
    'aWNpcGFudEpvaW5NZWV0aW5nRWFybHkSPAoLbG9ja01lZXRpbmcYDyABKAsyGi5vcGVuaW0ucH'
    'JvdG9idWYuQm9vbFZhbHVlUgtsb2NrTWVldGluZxJKChJhdWRpb0VuY291cmFnZW1lbnQYECAB'
    'KAsyGi5vcGVuaW0ucHJvdG9idWYuQm9vbFZhbHVlUhJhdWRpb0VuY291cmFnZW1lbnQSQgoOdm'
    'lkZW9NaXJyb3JpbmcYESABKAsyGi5vcGVuaW0ucHJvdG9idWYuQm9vbFZhbHVlUg52aWRlb01p'
    'cnJvcmluZw==');

@$core.Deprecated('Use updateMeetingRespDescriptor instead')
const UpdateMeetingResp$json = {
  '1': 'UpdateMeetingResp',
};

/// Descriptor for `UpdateMeetingResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateMeetingRespDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVNZWV0aW5nUmVzcA==');

@$core.Deprecated('Use personalMeetingSettingDescriptor instead')
const PersonalMeetingSetting$json = {
  '1': 'PersonalMeetingSetting',
  '2': [
    {'1': 'cameraOnEntry', '3': 1, '4': 1, '5': 8, '10': 'cameraOnEntry'},
    {'1': 'microphoneOnEntry', '3': 2, '4': 1, '5': 8, '10': 'microphoneOnEntry'},
  ],
};

/// Descriptor for `PersonalMeetingSetting`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List personalMeetingSettingDescriptor = $convert.base64Decode(
    'ChZQZXJzb25hbE1lZXRpbmdTZXR0aW5nEiQKDWNhbWVyYU9uRW50cnkYASABKAhSDWNhbWVyYU'
    '9uRW50cnkSLAoRbWljcm9waG9uZU9uRW50cnkYAiABKAhSEW1pY3JvcGhvbmVPbkVudHJ5');

@$core.Deprecated('Use getPersonalMeetingSettingsReqDescriptor instead')
const GetPersonalMeetingSettingsReq$json = {
  '1': 'GetPersonalMeetingSettingsReq',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'userID', '3': 2, '4': 1, '5': 9, '10': 'userID'},
  ],
};

/// Descriptor for `GetPersonalMeetingSettingsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPersonalMeetingSettingsReqDescriptor = $convert.base64Decode(
    'Ch1HZXRQZXJzb25hbE1lZXRpbmdTZXR0aW5nc1JlcRIcCgltZWV0aW5nSUQYASABKAlSCW1lZX'
    'RpbmdJRBIWCgZ1c2VySUQYAiABKAlSBnVzZXJJRA==');

@$core.Deprecated('Use getPersonalMeetingSettingsRespDescriptor instead')
const GetPersonalMeetingSettingsResp$json = {
  '1': 'GetPersonalMeetingSettingsResp',
  '2': [
    {'1': 'setting', '3': 1, '4': 1, '5': 11, '6': '.openmeeting.meeting.PersonalMeetingSetting', '10': 'setting'},
  ],
};

/// Descriptor for `GetPersonalMeetingSettingsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPersonalMeetingSettingsRespDescriptor = $convert.base64Decode(
    'Ch5HZXRQZXJzb25hbE1lZXRpbmdTZXR0aW5nc1Jlc3ASRQoHc2V0dGluZxgBIAEoCzIrLm9wZW'
    '5tZWV0aW5nLm1lZXRpbmcuUGVyc29uYWxNZWV0aW5nU2V0dGluZ1IHc2V0dGluZw==');

@$core.Deprecated('Use setPersonalMeetingSettingsReqDescriptor instead')
const SetPersonalMeetingSettingsReq$json = {
  '1': 'SetPersonalMeetingSettingsReq',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'userID', '3': 2, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'cameraOnEntry', '3': 3, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'cameraOnEntry'},
    {'1': 'microphoneOnEntry', '3': 4, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'microphoneOnEntry'},
  ],
};

/// Descriptor for `SetPersonalMeetingSettingsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPersonalMeetingSettingsReqDescriptor = $convert.base64Decode(
    'Ch1TZXRQZXJzb25hbE1lZXRpbmdTZXR0aW5nc1JlcRIcCgltZWV0aW5nSUQYASABKAlSCW1lZX'
    'RpbmdJRBIWCgZ1c2VySUQYAiABKAlSBnVzZXJJRBJACg1jYW1lcmFPbkVudHJ5GAMgASgLMhou'
    'b3BlbmltLnByb3RvYnVmLkJvb2xWYWx1ZVINY2FtZXJhT25FbnRyeRJIChFtaWNyb3Bob25lT2'
    '5FbnRyeRgEIAEoCzIaLm9wZW5pbS5wcm90b2J1Zi5Cb29sVmFsdWVSEW1pY3JvcGhvbmVPbkVu'
    'dHJ5');

@$core.Deprecated('Use setPersonalMeetingSettingsRespDescriptor instead')
const SetPersonalMeetingSettingsResp$json = {
  '1': 'SetPersonalMeetingSettingsResp',
};

/// Descriptor for `SetPersonalMeetingSettingsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPersonalMeetingSettingsRespDescriptor = $convert.base64Decode(
    'Ch5TZXRQZXJzb25hbE1lZXRpbmdTZXR0aW5nc1Jlc3A=');

@$core.Deprecated('Use personalDataDescriptor instead')
const PersonalData$json = {
  '1': 'PersonalData',
  '2': [
    {'1': 'userID', '3': 1, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'personalSetting', '3': 2, '4': 1, '5': 11, '6': '.openmeeting.meeting.PersonalMeetingSetting', '10': 'personalSetting'},
    {'1': 'limitSetting', '3': 3, '4': 1, '5': 11, '6': '.openmeeting.meeting.PersonalMeetingSetting', '10': 'limitSetting'},
  ],
};

/// Descriptor for `PersonalData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List personalDataDescriptor = $convert.base64Decode(
    'CgxQZXJzb25hbERhdGESFgoGdXNlcklEGAEgASgJUgZ1c2VySUQSVQoPcGVyc29uYWxTZXR0aW'
    '5nGAIgASgLMisub3Blbm1lZXRpbmcubWVldGluZy5QZXJzb25hbE1lZXRpbmdTZXR0aW5nUg9w'
    'ZXJzb25hbFNldHRpbmcSTwoMbGltaXRTZXR0aW5nGAMgASgLMisub3Blbm1lZXRpbmcubWVldG'
    'luZy5QZXJzb25hbE1lZXRpbmdTZXR0aW5nUgxsaW1pdFNldHRpbmc=');

@$core.Deprecated('Use meetingMetadataDescriptor instead')
const MeetingMetadata$json = {
  '1': 'MeetingMetadata',
  '2': [
    {'1': 'detail', '3': 1, '4': 1, '5': 11, '6': '.openmeeting.meeting.MeetingInfoSetting', '10': 'detail'},
    {'1': 'personalData', '3': 2, '4': 3, '5': 11, '6': '.openmeeting.meeting.PersonalData', '10': 'personalData'},
  ],
};

/// Descriptor for `MeetingMetadata`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingMetadataDescriptor = $convert.base64Decode(
    'Cg9NZWV0aW5nTWV0YWRhdGESPwoGZGV0YWlsGAEgASgLMicub3Blbm1lZXRpbmcubWVldGluZy'
    '5NZWV0aW5nSW5mb1NldHRpbmdSBmRldGFpbBJFCgxwZXJzb25hbERhdGEYAiADKAsyIS5vcGVu'
    'bWVldGluZy5tZWV0aW5nLlBlcnNvbmFsRGF0YVIMcGVyc29uYWxEYXRh');

@$core.Deprecated('Use operateRoomAllStreamReqDescriptor instead')
const OperateRoomAllStreamReq$json = {
  '1': 'OperateRoomAllStreamReq',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'operatorUserID', '3': 2, '4': 1, '5': 9, '10': 'operatorUserID'},
    {'1': 'cameraOnEntry', '3': 3, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'cameraOnEntry'},
    {'1': 'microphoneOnEntry', '3': 4, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'microphoneOnEntry'},
  ],
};

/// Descriptor for `OperateRoomAllStreamReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List operateRoomAllStreamReqDescriptor = $convert.base64Decode(
    'ChdPcGVyYXRlUm9vbUFsbFN0cmVhbVJlcRIcCgltZWV0aW5nSUQYASABKAlSCW1lZXRpbmdJRB'
    'ImCg5vcGVyYXRvclVzZXJJRBgCIAEoCVIOb3BlcmF0b3JVc2VySUQSQAoNY2FtZXJhT25FbnRy'
    'eRgDIAEoCzIaLm9wZW5pbS5wcm90b2J1Zi5Cb29sVmFsdWVSDWNhbWVyYU9uRW50cnkSSAoRbW'
    'ljcm9waG9uZU9uRW50cnkYBCABKAsyGi5vcGVuaW0ucHJvdG9idWYuQm9vbFZhbHVlUhFtaWNy'
    'b3Bob25lT25FbnRyeQ==');

@$core.Deprecated('Use operateRoomAllStreamRespDescriptor instead')
const OperateRoomAllStreamResp$json = {
  '1': 'OperateRoomAllStreamResp',
  '2': [
    {'1': 'streamNotExistUserIDList', '3': 1, '4': 3, '5': 9, '10': 'streamNotExistUserIDList'},
    {'1': 'failedUserIDList', '3': 2, '4': 3, '5': 9, '10': 'failedUserIDList'},
  ],
};

/// Descriptor for `OperateRoomAllStreamResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List operateRoomAllStreamRespDescriptor = $convert.base64Decode(
    'ChhPcGVyYXRlUm9vbUFsbFN0cmVhbVJlc3ASOgoYc3RyZWFtTm90RXhpc3RVc2VySURMaXN0GA'
    'EgAygJUhhzdHJlYW1Ob3RFeGlzdFVzZXJJRExpc3QSKgoQZmFpbGVkVXNlcklETGlzdBgCIAMo'
    'CVIQZmFpbGVkVXNlcklETGlzdA==');

@$core.Deprecated('Use removeMeetingParticipantsReqDescriptor instead')
const RemoveMeetingParticipantsReq$json = {
  '1': 'RemoveMeetingParticipantsReq',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'userID', '3': 2, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'participantUserIDs', '3': 3, '4': 3, '5': 9, '10': 'participantUserIDs'},
  ],
};

/// Descriptor for `RemoveMeetingParticipantsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeMeetingParticipantsReqDescriptor = $convert.base64Decode(
    'ChxSZW1vdmVNZWV0aW5nUGFydGljaXBhbnRzUmVxEhwKCW1lZXRpbmdJRBgBIAEoCVIJbWVldG'
    'luZ0lEEhYKBnVzZXJJRBgCIAEoCVIGdXNlcklEEi4KEnBhcnRpY2lwYW50VXNlcklEcxgDIAMo'
    'CVIScGFydGljaXBhbnRVc2VySURz');

@$core.Deprecated('Use removeMeetingParticipantsRespDescriptor instead')
const RemoveMeetingParticipantsResp$json = {
  '1': 'RemoveMeetingParticipantsResp',
  '2': [
    {'1': 'successUserIDList', '3': 1, '4': 3, '5': 9, '10': 'successUserIDList'},
    {'1': 'failedUserIDList', '3': 2, '4': 3, '5': 9, '10': 'failedUserIDList'},
  ],
};

/// Descriptor for `RemoveMeetingParticipantsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeMeetingParticipantsRespDescriptor = $convert.base64Decode(
    'Ch1SZW1vdmVNZWV0aW5nUGFydGljaXBhbnRzUmVzcBIsChFzdWNjZXNzVXNlcklETGlzdBgBIA'
    'MoCVIRc3VjY2Vzc1VzZXJJRExpc3QSKgoQZmFpbGVkVXNlcklETGlzdBgCIAMoCVIQZmFpbGVk'
    'VXNlcklETGlzdA==');

@$core.Deprecated('Use setMeetingHostInfoReqDescriptor instead')
const SetMeetingHostInfoReq$json = {
  '1': 'SetMeetingHostInfoReq',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'userID', '3': 2, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'hostUserID', '3': 3, '4': 1, '5': 11, '6': '.openim.protobuf.StringValue', '10': 'hostUserID'},
    {'1': 'coHostUserIDs', '3': 4, '4': 3, '5': 9, '10': 'coHostUserIDs'},
  ],
};

/// Descriptor for `SetMeetingHostInfoReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setMeetingHostInfoReqDescriptor = $convert.base64Decode(
    'ChVTZXRNZWV0aW5nSG9zdEluZm9SZXESHAoJbWVldGluZ0lEGAEgASgJUgltZWV0aW5nSUQSFg'
    'oGdXNlcklEGAIgASgJUgZ1c2VySUQSPAoKaG9zdFVzZXJJRBgDIAEoCzIcLm9wZW5pbS5wcm90'
    'b2J1Zi5TdHJpbmdWYWx1ZVIKaG9zdFVzZXJJRBIkCg1jb0hvc3RVc2VySURzGAQgAygJUg1jb0'
    'hvc3RVc2VySURz');

@$core.Deprecated('Use setMeetingHostInfoRespDescriptor instead')
const SetMeetingHostInfoResp$json = {
  '1': 'SetMeetingHostInfoResp',
};

/// Descriptor for `SetMeetingHostInfoResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setMeetingHostInfoRespDescriptor = $convert.base64Decode(
    'ChZTZXRNZWV0aW5nSG9zdEluZm9SZXNw');

@$core.Deprecated('Use notifyMeetingDataDescriptor instead')
const NotifyMeetingData$json = {
  '1': 'NotifyMeetingData',
  '2': [
    {'1': 'operatorUserID', '3': 1, '4': 1, '5': 9, '10': 'operatorUserID'},
    {'1': 'streamOperateData', '3': 2, '4': 1, '5': 11, '6': '.openmeeting.meeting.StreamOperateData', '9': 0, '10': 'streamOperateData'},
    {'1': 'meetingHostData', '3': 3, '4': 1, '5': 11, '6': '.openmeeting.meeting.MeetingHostData', '9': 0, '10': 'meetingHostData'},
    {'1': 'kickOffMeetingData', '3': 4, '4': 1, '5': 11, '6': '.openmeeting.meeting.KickOffMeetingData', '9': 0, '10': 'kickOffMeetingData'},
  ],
  '8': [
    {'1': 'messageType'},
  ],
};

/// Descriptor for `NotifyMeetingData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notifyMeetingDataDescriptor = $convert.base64Decode(
    'ChFOb3RpZnlNZWV0aW5nRGF0YRImCg5vcGVyYXRvclVzZXJJRBgBIAEoCVIOb3BlcmF0b3JVc2'
    'VySUQSVgoRc3RyZWFtT3BlcmF0ZURhdGEYAiABKAsyJi5vcGVubWVldGluZy5tZWV0aW5nLlN0'
    'cmVhbU9wZXJhdGVEYXRhSABSEXN0cmVhbU9wZXJhdGVEYXRhElAKD21lZXRpbmdIb3N0RGF0YR'
    'gDIAEoCzIkLm9wZW5tZWV0aW5nLm1lZXRpbmcuTWVldGluZ0hvc3REYXRhSABSD21lZXRpbmdI'
    'b3N0RGF0YRJZChJraWNrT2ZmTWVldGluZ0RhdGEYBCABKAsyJy5vcGVubWVldGluZy5tZWV0aW'
    '5nLktpY2tPZmZNZWV0aW5nRGF0YUgAUhJraWNrT2ZmTWVldGluZ0RhdGFCDQoLbWVzc2FnZVR5'
    'cGU=');

@$core.Deprecated('Use kickOffMeetingDataDescriptor instead')
const KickOffMeetingData$json = {
  '1': 'KickOffMeetingData',
  '2': [
    {'1': 'userID', '3': 1, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'nickname', '3': 2, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'reasonCode', '3': 3, '4': 1, '5': 14, '6': '.openmeeting.meeting.KickOffReason', '10': 'reasonCode'},
    {'1': 'reason', '3': 4, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `KickOffMeetingData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List kickOffMeetingDataDescriptor = $convert.base64Decode(
    'ChJLaWNrT2ZmTWVldGluZ0RhdGESFgoGdXNlcklEGAEgASgJUgZ1c2VySUQSGgoIbmlja25hbW'
    'UYAiABKAlSCG5pY2tuYW1lEkIKCnJlYXNvbkNvZGUYAyABKA4yIi5vcGVubWVldGluZy5tZWV0'
    'aW5nLktpY2tPZmZSZWFzb25SCnJlYXNvbkNvZGUSFgoGcmVhc29uGAQgASgJUgZyZWFzb24=');

@$core.Deprecated('Use streamOperateDataDescriptor instead')
const StreamOperateData$json = {
  '1': 'StreamOperateData',
  '2': [
    {'1': 'operation', '3': 1, '4': 3, '5': 11, '6': '.openmeeting.meeting.UserOperationData', '10': 'operation'},
  ],
};

/// Descriptor for `StreamOperateData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamOperateDataDescriptor = $convert.base64Decode(
    'ChFTdHJlYW1PcGVyYXRlRGF0YRJECglvcGVyYXRpb24YASADKAsyJi5vcGVubWVldGluZy5tZW'
    'V0aW5nLlVzZXJPcGVyYXRpb25EYXRhUglvcGVyYXRpb24=');

@$core.Deprecated('Use userOperationDataDescriptor instead')
const UserOperationData$json = {
  '1': 'UserOperationData',
  '2': [
    {'1': 'userID', '3': 1, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'cameraOnEntry', '3': 2, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'cameraOnEntry'},
    {'1': 'microphoneOnEntry', '3': 3, '4': 1, '5': 11, '6': '.openim.protobuf.BoolValue', '10': 'microphoneOnEntry'},
  ],
};

/// Descriptor for `UserOperationData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userOperationDataDescriptor = $convert.base64Decode(
    'ChFVc2VyT3BlcmF0aW9uRGF0YRIWCgZ1c2VySUQYASABKAlSBnVzZXJJRBJACg1jYW1lcmFPbk'
    'VudHJ5GAIgASgLMhoub3BlbmltLnByb3RvYnVmLkJvb2xWYWx1ZVINY2FtZXJhT25FbnRyeRJI'
    'ChFtaWNyb3Bob25lT25FbnRyeRgDIAEoCzIaLm9wZW5pbS5wcm90b2J1Zi5Cb29sVmFsdWVSEW'
    '1pY3JvcGhvbmVPbkVudHJ5');

@$core.Deprecated('Use meetingHostDataDescriptor instead')
const MeetingHostData$json = {
  '1': 'MeetingHostData',
  '2': [
    {'1': 'operatorNickname', '3': 2, '4': 1, '5': 9, '10': 'operatorNickname'},
    {'1': 'userID', '3': 3, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'hostType', '3': 4, '4': 1, '5': 9, '10': 'hostType'},
  ],
};

/// Descriptor for `MeetingHostData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meetingHostDataDescriptor = $convert.base64Decode(
    'Cg9NZWV0aW5nSG9zdERhdGESKgoQb3BlcmF0b3JOaWNrbmFtZRgCIAEoCVIQb3BlcmF0b3JOaW'
    'NrbmFtZRIWCgZ1c2VySUQYAyABKAlSBnVzZXJJRBIaCghob3N0VHlwZRgEIAEoCVIIaG9zdFR5'
    'cGU=');

@$core.Deprecated('Use cleanPreviousMeetingsReqDescriptor instead')
const CleanPreviousMeetingsReq$json = {
  '1': 'CleanPreviousMeetingsReq',
  '2': [
    {'1': 'userID', '3': 1, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'reasonCode', '3': 2, '4': 1, '5': 5, '10': 'reasonCode'},
    {'1': 'reason', '3': 3, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `CleanPreviousMeetingsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cleanPreviousMeetingsReqDescriptor = $convert.base64Decode(
    'ChhDbGVhblByZXZpb3VzTWVldGluZ3NSZXESFgoGdXNlcklEGAEgASgJUgZ1c2VySUQSHgoKcm'
    'Vhc29uQ29kZRgCIAEoBVIKcmVhc29uQ29kZRIWCgZyZWFzb24YAyABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use cleanPreviousMeetingsRespDescriptor instead')
const CleanPreviousMeetingsResp$json = {
  '1': 'CleanPreviousMeetingsResp',
};

/// Descriptor for `CleanPreviousMeetingsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cleanPreviousMeetingsRespDescriptor = $convert.base64Decode(
    'ChlDbGVhblByZXZpb3VzTWVldGluZ3NSZXNw');

@$core.Deprecated('Use toggleRecordMeetingReqDescriptor instead')
const ToggleRecordMeetingReq$json = {
  '1': 'ToggleRecordMeetingReq',
  '2': [
    {'1': 'meetingID', '3': 1, '4': 1, '5': 9, '10': 'meetingID'},
    {'1': 'userID', '3': 2, '4': 1, '5': 9, '10': 'userID'},
    {'1': 'enableRecord', '3': 3, '4': 1, '5': 8, '10': 'enableRecord'},
  ],
};

/// Descriptor for `ToggleRecordMeetingReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List toggleRecordMeetingReqDescriptor = $convert.base64Decode(
    'ChZUb2dnbGVSZWNvcmRNZWV0aW5nUmVxEhwKCW1lZXRpbmdJRBgBIAEoCVIJbWVldGluZ0lEEh'
    'YKBnVzZXJJRBgCIAEoCVIGdXNlcklEEiIKDGVuYWJsZVJlY29yZBgDIAEoCFIMZW5hYmxlUmVj'
    'b3Jk');

@$core.Deprecated('Use toggleRecordMeetingRespDescriptor instead')
const ToggleRecordMeetingResp$json = {
  '1': 'ToggleRecordMeetingResp',
};

/// Descriptor for `ToggleRecordMeetingResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List toggleRecordMeetingRespDescriptor = $convert.base64Decode(
    'ChdUb2dnbGVSZWNvcmRNZWV0aW5nUmVzcA==');

const $core.Map<$core.String, $core.dynamic> MeetingServiceBase$json = {
  '1': 'MeetingService',
  '2': [
    {'1': 'BookMeeting', '2': '.openmeeting.meeting.BookMeetingReq', '3': '.openmeeting.meeting.BookMeetingResp'},
    {'1': 'CreateImmediateMeeting', '2': '.openmeeting.meeting.CreateImmediateMeetingReq', '3': '.openmeeting.meeting.CreateImmediateMeetingResp'},
    {'1': 'JoinMeeting', '2': '.openmeeting.meeting.JoinMeetingReq', '3': '.openmeeting.meeting.JoinMeetingResp'},
    {'1': 'GetMeetingToken', '2': '.openmeeting.meeting.GetMeetingTokenReq', '3': '.openmeeting.meeting.GetMeetingTokenResp'},
    {'1': 'LeaveMeeting', '2': '.openmeeting.meeting.LeaveMeetingReq', '3': '.openmeeting.meeting.LeaveMeetingResp'},
    {'1': 'EndMeeting', '2': '.openmeeting.meeting.EndMeetingReq', '3': '.openmeeting.meeting.EndMeetingResp'},
    {'1': 'GetMeetings', '2': '.openmeeting.meeting.GetMeetingsReq', '3': '.openmeeting.meeting.GetMeetingsResp'},
    {'1': 'GetMeeting', '2': '.openmeeting.meeting.GetMeetingReq', '3': '.openmeeting.meeting.GetMeetingResp'},
    {'1': 'UpdateMeeting', '2': '.openmeeting.meeting.UpdateMeetingRequest', '3': '.openmeeting.meeting.UpdateMeetingResp'},
    {'1': 'GetPersonalMeetingSettings', '2': '.openmeeting.meeting.GetPersonalMeetingSettingsReq', '3': '.openmeeting.meeting.GetPersonalMeetingSettingsResp'},
    {'1': 'SetPersonalMeetingSettings', '2': '.openmeeting.meeting.SetPersonalMeetingSettingsReq', '3': '.openmeeting.meeting.SetPersonalMeetingSettingsResp'},
    {'1': 'OperateRoomAllStream', '2': '.openmeeting.meeting.OperateRoomAllStreamReq', '3': '.openmeeting.meeting.OperateRoomAllStreamResp'},
    {'1': 'ModifyMeetingParticipantNickName', '2': '.openmeeting.meeting.ModifyMeetingParticipantNickNameReq', '3': '.openmeeting.meeting.ModifyMeetingParticipantNickNameResp'},
    {'1': 'RemoveParticipants', '2': '.openmeeting.meeting.RemoveMeetingParticipantsReq', '3': '.openmeeting.meeting.RemoveMeetingParticipantsResp'},
    {'1': 'SetMeetingHostInfo', '2': '.openmeeting.meeting.SetMeetingHostInfoReq', '3': '.openmeeting.meeting.SetMeetingHostInfoResp'},
    {'1': 'CleanPreviousMeetings', '2': '.openmeeting.meeting.CleanPreviousMeetingsReq', '3': '.openmeeting.meeting.CleanPreviousMeetingsResp'},
    {'1': 'ToggleRecordMeeting', '2': '.openmeeting.meeting.ToggleRecordMeetingReq', '3': '.openmeeting.meeting.ToggleRecordMeetingResp'},
  ],
};

@$core.Deprecated('Use meetingServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> MeetingServiceBase$messageJson = {
  '.openmeeting.meeting.BookMeetingReq': BookMeetingReq$json,
  '.openmeeting.meeting.CreatorDefinedMeetingInfo': CreatorDefinedMeetingInfo$json,
  '.openmeeting.meeting.MeetingSetting': MeetingSetting$json,
  '.openmeeting.meeting.MeetingRepeatInfo': MeetingRepeatInfo$json,
  '.openmeeting.meeting.BookMeetingResp': BookMeetingResp$json,
  '.openmeeting.meeting.MeetingInfoSetting': MeetingInfoSetting$json,
  '.openmeeting.meeting.MeetingInfo': MeetingInfo$json,
  '.openmeeting.meeting.SystemGeneratedMeetingInfo': SystemGeneratedMeetingInfo$json,
  '.openmeeting.meeting.CreateImmediateMeetingReq': CreateImmediateMeetingReq$json,
  '.openmeeting.meeting.CreateImmediateMeetingResp': CreateImmediateMeetingResp$json,
  '.openmeeting.meeting.LiveKit': LiveKit$json,
  '.openmeeting.meeting.JoinMeetingReq': JoinMeetingReq$json,
  '.openmeeting.meeting.JoinMeetingResp': JoinMeetingResp$json,
  '.openmeeting.meeting.GetMeetingTokenReq': GetMeetingTokenReq$json,
  '.openmeeting.meeting.GetMeetingTokenResp': GetMeetingTokenResp$json,
  '.openmeeting.meeting.LeaveMeetingReq': LeaveMeetingReq$json,
  '.openmeeting.meeting.LeaveMeetingResp': LeaveMeetingResp$json,
  '.openmeeting.meeting.EndMeetingReq': EndMeetingReq$json,
  '.openmeeting.meeting.EndMeetingResp': EndMeetingResp$json,
  '.openmeeting.meeting.GetMeetingsReq': GetMeetingsReq$json,
  '.openmeeting.meeting.GetMeetingsResp': GetMeetingsResp$json,
  '.openmeeting.meeting.GetMeetingReq': GetMeetingReq$json,
  '.openmeeting.meeting.GetMeetingResp': GetMeetingResp$json,
  '.openmeeting.meeting.UpdateMeetingRequest': UpdateMeetingRequest$json,
  '.openim.protobuf.StringValue': $0.StringValue$json,
  '.openim.protobuf.Int64Value': $0.Int64Value$json,
  '.openim.protobuf.BoolValue': $0.BoolValue$json,
  '.openmeeting.meeting.UpdateMeetingResp': UpdateMeetingResp$json,
  '.openmeeting.meeting.GetPersonalMeetingSettingsReq': GetPersonalMeetingSettingsReq$json,
  '.openmeeting.meeting.GetPersonalMeetingSettingsResp': GetPersonalMeetingSettingsResp$json,
  '.openmeeting.meeting.PersonalMeetingSetting': PersonalMeetingSetting$json,
  '.openmeeting.meeting.SetPersonalMeetingSettingsReq': SetPersonalMeetingSettingsReq$json,
  '.openmeeting.meeting.SetPersonalMeetingSettingsResp': SetPersonalMeetingSettingsResp$json,
  '.openmeeting.meeting.OperateRoomAllStreamReq': OperateRoomAllStreamReq$json,
  '.openmeeting.meeting.OperateRoomAllStreamResp': OperateRoomAllStreamResp$json,
  '.openmeeting.meeting.ModifyMeetingParticipantNickNameReq': ModifyMeetingParticipantNickNameReq$json,
  '.openmeeting.meeting.ModifyMeetingParticipantNickNameResp': ModifyMeetingParticipantNickNameResp$json,
  '.openmeeting.meeting.RemoveMeetingParticipantsReq': RemoveMeetingParticipantsReq$json,
  '.openmeeting.meeting.RemoveMeetingParticipantsResp': RemoveMeetingParticipantsResp$json,
  '.openmeeting.meeting.SetMeetingHostInfoReq': SetMeetingHostInfoReq$json,
  '.openmeeting.meeting.SetMeetingHostInfoResp': SetMeetingHostInfoResp$json,
  '.openmeeting.meeting.CleanPreviousMeetingsReq': CleanPreviousMeetingsReq$json,
  '.openmeeting.meeting.CleanPreviousMeetingsResp': CleanPreviousMeetingsResp$json,
  '.openmeeting.meeting.ToggleRecordMeetingReq': ToggleRecordMeetingReq$json,
  '.openmeeting.meeting.ToggleRecordMeetingResp': ToggleRecordMeetingResp$json,
};

/// Descriptor for `MeetingService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List meetingServiceDescriptor = $convert.base64Decode(
    'Cg5NZWV0aW5nU2VydmljZRJYCgtCb29rTWVldGluZxIjLm9wZW5tZWV0aW5nLm1lZXRpbmcuQm'
    '9va01lZXRpbmdSZXEaJC5vcGVubWVldGluZy5tZWV0aW5nLkJvb2tNZWV0aW5nUmVzcBJ5ChZD'
    'cmVhdGVJbW1lZGlhdGVNZWV0aW5nEi4ub3Blbm1lZXRpbmcubWVldGluZy5DcmVhdGVJbW1lZG'
    'lhdGVNZWV0aW5nUmVxGi8ub3Blbm1lZXRpbmcubWVldGluZy5DcmVhdGVJbW1lZGlhdGVNZWV0'
    'aW5nUmVzcBJYCgtKb2luTWVldGluZxIjLm9wZW5tZWV0aW5nLm1lZXRpbmcuSm9pbk1lZXRpbm'
    'dSZXEaJC5vcGVubWVldGluZy5tZWV0aW5nLkpvaW5NZWV0aW5nUmVzcBJkCg9HZXRNZWV0aW5n'
    'VG9rZW4SJy5vcGVubWVldGluZy5tZWV0aW5nLkdldE1lZXRpbmdUb2tlblJlcRooLm9wZW5tZW'
    'V0aW5nLm1lZXRpbmcuR2V0TWVldGluZ1Rva2VuUmVzcBJbCgxMZWF2ZU1lZXRpbmcSJC5vcGVu'
    'bWVldGluZy5tZWV0aW5nLkxlYXZlTWVldGluZ1JlcRolLm9wZW5tZWV0aW5nLm1lZXRpbmcuTG'
    'VhdmVNZWV0aW5nUmVzcBJVCgpFbmRNZWV0aW5nEiIub3Blbm1lZXRpbmcubWVldGluZy5FbmRN'
    'ZWV0aW5nUmVxGiMub3Blbm1lZXRpbmcubWVldGluZy5FbmRNZWV0aW5nUmVzcBJYCgtHZXRNZW'
    'V0aW5ncxIjLm9wZW5tZWV0aW5nLm1lZXRpbmcuR2V0TWVldGluZ3NSZXEaJC5vcGVubWVldGlu'
    'Zy5tZWV0aW5nLkdldE1lZXRpbmdzUmVzcBJVCgpHZXRNZWV0aW5nEiIub3Blbm1lZXRpbmcubW'
    'VldGluZy5HZXRNZWV0aW5nUmVxGiMub3Blbm1lZXRpbmcubWVldGluZy5HZXRNZWV0aW5nUmVz'
    'cBJiCg1VcGRhdGVNZWV0aW5nEikub3Blbm1lZXRpbmcubWVldGluZy5VcGRhdGVNZWV0aW5nUm'
    'VxdWVzdBomLm9wZW5tZWV0aW5nLm1lZXRpbmcuVXBkYXRlTWVldGluZ1Jlc3AShQEKGkdldFBl'
    'cnNvbmFsTWVldGluZ1NldHRpbmdzEjIub3Blbm1lZXRpbmcubWVldGluZy5HZXRQZXJzb25hbE'
    '1lZXRpbmdTZXR0aW5nc1JlcRozLm9wZW5tZWV0aW5nLm1lZXRpbmcuR2V0UGVyc29uYWxNZWV0'
    'aW5nU2V0dGluZ3NSZXNwEoUBChpTZXRQZXJzb25hbE1lZXRpbmdTZXR0aW5ncxIyLm9wZW5tZW'
    'V0aW5nLm1lZXRpbmcuU2V0UGVyc29uYWxNZWV0aW5nU2V0dGluZ3NSZXEaMy5vcGVubWVldGlu'
    'Zy5tZWV0aW5nLlNldFBlcnNvbmFsTWVldGluZ1NldHRpbmdzUmVzcBJzChRPcGVyYXRlUm9vbU'
    'FsbFN0cmVhbRIsLm9wZW5tZWV0aW5nLm1lZXRpbmcuT3BlcmF0ZVJvb21BbGxTdHJlYW1SZXEa'
    'LS5vcGVubWVldGluZy5tZWV0aW5nLk9wZXJhdGVSb29tQWxsU3RyZWFtUmVzcBKXAQogTW9kaW'
    'Z5TWVldGluZ1BhcnRpY2lwYW50Tmlja05hbWUSOC5vcGVubWVldGluZy5tZWV0aW5nLk1vZGlm'
    'eU1lZXRpbmdQYXJ0aWNpcGFudE5pY2tOYW1lUmVxGjkub3Blbm1lZXRpbmcubWVldGluZy5Nb2'
    'RpZnlNZWV0aW5nUGFydGljaXBhbnROaWNrTmFtZVJlc3ASewoSUmVtb3ZlUGFydGljaXBhbnRz'
    'EjEub3Blbm1lZXRpbmcubWVldGluZy5SZW1vdmVNZWV0aW5nUGFydGljaXBhbnRzUmVxGjIub3'
    'Blbm1lZXRpbmcubWVldGluZy5SZW1vdmVNZWV0aW5nUGFydGljaXBhbnRzUmVzcBJtChJTZXRN'
    'ZWV0aW5nSG9zdEluZm8SKi5vcGVubWVldGluZy5tZWV0aW5nLlNldE1lZXRpbmdIb3N0SW5mb1'
    'JlcRorLm9wZW5tZWV0aW5nLm1lZXRpbmcuU2V0TWVldGluZ0hvc3RJbmZvUmVzcBJ2ChVDbGVh'
    'blByZXZpb3VzTWVldGluZ3MSLS5vcGVubWVldGluZy5tZWV0aW5nLkNsZWFuUHJldmlvdXNNZW'
    'V0aW5nc1JlcRouLm9wZW5tZWV0aW5nLm1lZXRpbmcuQ2xlYW5QcmV2aW91c01lZXRpbmdzUmVz'
    'cBJwChNUb2dnbGVSZWNvcmRNZWV0aW5nEisub3Blbm1lZXRpbmcubWVldGluZy5Ub2dnbGVSZW'
    'NvcmRNZWV0aW5nUmVxGiwub3Blbm1lZXRpbmcubWVldGluZy5Ub2dnbGVSZWNvcmRNZWV0aW5n'
    'UmVzcA==');

