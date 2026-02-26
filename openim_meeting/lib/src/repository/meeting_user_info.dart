import 'dart:convert';

class MeetingUserInfo {
  final String token;
  final String userId;
  final String nickname;
  final String? faceURL;

  MeetingUserInfo({required this.token, required this.userId, required this.nickname, this.faceURL});

  factory MeetingUserInfo.fromJson(String str) => MeetingUserInfo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MeetingUserInfo.fromMap(Map<String, dynamic> json) => MeetingUserInfo(
        token: json["token"] ?? '',
        userId: json["userID"],
        nickname: json["nickname"],
        faceURL: json["faceURL"],
      );

  Map<String, dynamic> toMap() => {"token": token, "userID": userId, "nickname": nickname, 'faceURL': faceURL};
}
