import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

class Apis {
  static Options get imTokenOptions => Options(headers: {'token': DataSp.imToken});

  static Options get chatTokenOptions => Options(headers: {'token': DataSp.chatToken});

  static StreamController kickoffController = StreamController<int>.broadcast();

  static void _kickoff(int? errCode) {
    if (errCode == 1501 || errCode == 1503 || errCode == 1504 || errCode == 1505) {
      kickoffController.sink.add(errCode);
    }
  }

  /// login
  static Future<LoginCertificate> login({
    String? areaCode,
    String? phoneNumber,
    String? account,
    String? email,
    String? password,
    String? verificationCode,
  }) async {
    try {
      var data = await HttpUtil.post(Urls.login, data: {
        "areaCode": areaCode,
        'account': account,
        'phoneNumber': phoneNumber,
        'email': email,
        'password': null != password ? IMUtils.generateMD5(password) : null,
        'platform': await IMUtils.getPlatform(),
        'verifyCode': verificationCode,
      });
      final cert = LoginCertificate.fromJson(data!);
      ApiService().setToken(cert.imToken);

      return cert;
    } catch (e, s) {
      _catchErrorHelper(e, s);

      return Future.error(e);
    }
  }

  static Future<LoginCertificate> thirdPartyLogin({
    required String provider,
    required String token,
    bool? isRegister,
  }) async {
    try {
      String url = '';

      if (provider == 'google') {
        url = Urls.thirdPartyAutoLogin;
      } else {
        url = isRegister != true ? Urls.thirdPartyRegister : Urls.thirdPartyLogin;
      }

      var data = await HttpUtil.post(url, data: {
        'endpoint': provider,
        'token': provider == 'google' ? token : null,
        'state': provider == 'github' ? token : null,
        'platform': await IMUtils.getPlatform(),
      });
      final cert = LoginCertificate.fromJson(data!);
      ApiService().setToken(cert.imToken);

      return cert;
    } catch (e, s) {
      _catchErrorHelper(e, s);

      return Future.error(e);
    }
  }

  /// register
  static Future<LoginCertificate> register({
    required String nickname,
    required String password,
    String? faceURL,
    String? areaCode,
    String? phoneNumber,
    String? email,
    String? account,
    int birth = 0,
    int gender = 1,
    required String verificationCode,
    String? invitationCode,
  }) async {
    try {
      var data = await HttpUtil.post(Urls.register, data: {
        'deviceID': DataSp.getDeviceID(),
        'verifyCode': verificationCode,
        'platform': await IMUtils.getPlatform(),
        'invitationCode': invitationCode,
        'autoLogin': true,
        'user': {
          "nickname": nickname,
          "faceURL": faceURL,
          'birth': birth,
          'gender': gender,
          'email': email,
          "areaCode": areaCode,
          'phoneNumber': phoneNumber,
          'account': account,
          'password': IMUtils.generateMD5(password),
        },
      });

      final cert = LoginCertificate.fromJson(data!);
      ApiService().setToken(cert.imToken);

      return cert;
    } catch (e, s) {
      _catchErrorHelper(e, s);

      return Future.error(e);
    }
  }

  static Future deleteAccount(List<String> userIDs) async {
    try {
      await HttpUtil.post(
        Urls.deleteAccount,
        data: {
          'userIDs': userIDs,
        },
        options: chatTokenOptions,
      );
    } catch (e, s) {
      _catchErrorHelper(e, s);
    }
  }

  /// reset password
  static Future<dynamic> resetPassword({
    String? areaCode,
    String? phoneNumber,
    String? email,
    required String password,
    required String verificationCode,
  }) async {
    try {
      return HttpUtil.post(
        Urls.resetPwd,
        data: {
          "areaCode": areaCode,
          'phoneNumber': phoneNumber,
          'email': email,
          'password': IMUtils.generateMD5(password),
          'verifyCode': verificationCode,
          'platform': await IMUtils.getPlatform(),
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
      );
    } catch (e, s) {
      _catchErrorHelper(e, s);
    }
  }

  /// change password
  static Future<bool> changePassword({
    required String userID,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await HttpUtil.post(
        Urls.changePwd,
        data: {
          "userID": userID,
          'currentPassword': IMUtils.generateMD5(currentPassword),
          'newPassword': IMUtils.generateMD5(newPassword),
          'platform': await IMUtils.getPlatform(),
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
      );
      return true;
    } catch (e, s) {
      _catchErrorHelper(e, s);

      return false;
    }
  }

  /// change password to b
  static Future<bool> changePasswordOfB({
    required String newPassword,
  }) async {
    try {
      await HttpUtil.post(
        Urls.resetPwd,
        data: {
          'password': IMUtils.generateMD5(newPassword),
          'platform': await IMUtils.getPlatform(),
        },
        options: chatTokenOptions,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// update user info
  static Future<dynamic> updateUserInfo({
    required String userID,
    String? account,
    String? phoneNumber,
    String? areaCode,
    String? email,
    String? nickname,
    String? faceURL,
    int? gender,
    int? birth,
    int? level,
    int? allowAddFriend,
    int? allowBeep,
    int? allowVibration,
  }) async {
    try {
      Map<String, dynamic> param = {'userID': userID};
      void put(String key, dynamic value) {
        if (null != value) {
          param[key] = value;
        }
      }

      put('account', account);
      put('phoneNumber', phoneNumber);
      put('areaCode', areaCode);
      put('email', email);
      put('nickname', nickname);
      put('faceURL', faceURL);
      put('gender', gender);
      put('gender', gender);
      put('level', level);
      put('birth', birth);
      put('allowAddFriend', allowAddFriend);
      put('allowBeep', allowBeep);
      put('allowVibration', allowVibration);

      return HttpUtil.post(
        Urls.updateUserInfo,
        data: {
          ...param,
          'platform': await IMUtils.getPlatform(),
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
      );
    } catch (e, s) {
      _catchErrorHelper(e, s);
    }
  }

  static Future<List<FriendInfo>> searchFriendInfo(
    String keyword, {
    int pageNumber = 1,
    int showNumber = 10,
    bool showErrorToast = true,
  }) async {
    try {
      final data = await HttpUtil.post(
        Urls.searchFriendInfo,
        data: {
          'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
          'keyword': keyword,
        },
        options: chatTokenOptions,
        showErrorToast: showErrorToast,
      );
      if (data['users'] is List) {
        return (data['users'] as List).map((e) => FriendInfo.fromJson(e)).toList();
      }
      return [];
    } catch (e, s) {
      _catchErrorHelper(e, s);

      rethrow;
    }
  }

  static Future<List<UserFullInfo>?> getUserFullInfo({
    int pageNumber = 0,
    int showNumber = 10,
    required List<String> userIDList,
  }) async {
    try {
      final data = await HttpUtil.post(
        Urls.getUsersFullInfo,
        data: {
          'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
          'userIDs': userIDList,
          'platform': await IMUtils.getPlatform(),
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
      );
      if (data['users'] is List) {
        return (data['users'] as List).map((e) => UserFullInfo.fromJson(e)).toList();
      }
      return null;
    } catch (e, s) {
      _catchErrorHelper(e, s);

      return [];
    }
  }

  static Future<List<UserFullInfo>?> searchUserFullInfo({
    required String content,
    int pageNumber = 1,
    int showNumber = 10,
  }) async {
    try {
      final data = await HttpUtil.post(
        Urls.searchUserFullInfo,
        data: {
          'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
          'keyword': content,
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
      );
      if (data['users'] is List) {
        return (data['users'] as List).map((e) => UserFullInfo.fromJson(e)).toList();
      }
      return null;
    } catch (e, s) {
      _catchErrorHelper(e, s);

      return [];
    }
  }

  static Future<UserFullInfo?> queryMyFullInfo() async {
    final list = await Apis.getUserFullInfo(
      userIDList: [OpenIM.iMManager.userID],
    );
    return list?.firstOrNull;
  }

  /// 获取验证码
  /// [usedFor] 1：注册，2：重置密码 3：登录
  static Future<bool> requestVerificationCode({
    String? areaCode,
    String? phoneNumber,
    String? email,
    required int usedFor,
    String? invitationCode,
  }) async {
    return HttpUtil.post(
      Urls.getVerificationCode,
      data: {
        "areaCode": areaCode,
        "phoneNumber": phoneNumber,
        "email": email,
        'usedFor': usedFor,
        'invitationCode': invitationCode
      },
    ).then((value) {
      IMViews.showToast(StrRes.sentSuccessfully);
      return true;
    }).catchError((e, s) {
      Logger.print('e:$e s:$s');
      return false;
    });
  }

  /// 校验验证码
  static Future<dynamic> checkVerificationCode({
    String? areaCode,
    String? phoneNumber,
    String? email,
    required String verificationCode,
    required int usedFor,
    String? invitationCode,
  }) {
    return HttpUtil.post(
      Urls.checkVerificationCode,
      data: {
        "phoneNumber": phoneNumber,
        "areaCode": areaCode,
        "email": email,
        "verifyCode": verificationCode,
        "usedFor": usedFor,
        // 'operationID': operationID,
        'invitationCode': invitationCode
      },
    );
  }

  /// 蒲公英更新检测
  static Future<UpgradeInfoV2> checkUpgradeV2() {
    return dio.post<Map<String, dynamic>>(
      'https://www.pgyer.com/apiv2/app/check',
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
      ),
      data: {
        '_api_key': '',
        'appKey': '',
      },
    ).then((resp) {
      Map<String, dynamic> map = resp.data!;
      if (map['code'] == 0) {
        return UpgradeInfoV2.fromJson(map['data']);
      }
      return Future.error(map);
    });
  }

  /// discoverPageURL
  /// ordinaryUserAddFriend,
  /// bossUserID,
  /// adminURL ,
  /// allowSendMsgNotFriend
  /// needInvitationCodeRegister
  /// robots
  static Future<Map<String, dynamic>> getClientConfig() async {
    return {'discoverPageURL': Config.discoverPageUrl, 'allowSendMsgNotFriend': Config.allowSendMsgNotFriend};
    try {
      var result = await HttpUtil.post(
        Urls.getClientConfig,
        data: {
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
        showErrorToast: false,
      );
      return result['config'] ?? {};
    } catch (e, s) {
      _catchErrorHelper(e, s);

      return {};
    }
  }

  static Future _showHud<T>(Future<T> Function() asyncFunction, {bool show = true}) {
    return show ? LoadingView.singleton.wrap(asyncFunction: asyncFunction) : asyncFunction();
  }

  static Future meetingLogout() async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.logout,
          data: {
            'userID': DataSp.userID,
          },
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future getMeetings(Map<String, dynamic> params) async {
    try {
      if (DataSp.userID == null) {
        return null;
      }
      final result = await _showHud(
        () => ApiService().post(
          Urls.getMeetings,
          data: params,
        ),
        show: false,
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future getMeeting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.getMeeting,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future bookingMeeting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(Urls.booking, data: params),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future quicklyMeeting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(Urls.quickly, data: params),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future joinMeeting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(Urls.join, data: params),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return null;
    }
  }

  static Future createMeeting(String path, Map<String, dynamic> params) async {
    return await _showHud(
      () => ApiService().post(path, data: params),
    );
  }

  static Future getLiveKitToken(String meetingID, String userID) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.getLiveToken,
          data: {'meetingID': meetingID, 'userID': userID},
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future leaveMeeting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.leaveMeeting,
          data: params,
        ),
        show: false,
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future endMeeting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.endMeeting,
          data: params,
        ),
        show: false,
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future setPersonalSetting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.setPersonalSetting,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future updateMeetingSetting(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.updateSetting,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future operateAllStream(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.operateAllStream,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future modifyParticipantName(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.modifyParticipantName,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future kickParticipant(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.kickParticipants,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static Future setMeetingHost(Map<String, dynamic> params) async {
    try {
      final result = await _showHud(
        () => ApiService().post(
          Urls.setMeetingHost,
          data: params,
        ),
      );

      return result;
    } catch (e, s) {
      _catchError(e, s);

      return Future.error(e);
    }
  }

  static void _catchErrorHelper(Object e, StackTrace s, {String? Function(int code)? msgCallback}) {
    if (e is (int, String?)) {
      final errCode = e.$1;
      final errMsg = e.$2;
      _kickoff(errCode);

      Logger.print('e:$errCode s:$errMsg');
    } else {
      _catchError(e, s, msgCallback: msgCallback);
    }
  }

  static void _catchError(Object e, StackTrace s, {bool forceBack = true, String? Function(int code)? msgCallback}) {
    if (e is ApiException) {
      final code = e.code;
      final message = e.message;

      var msg = '$code'.tr;

      if (msg.isEmpty || e.code.toString() == msg) {
        msg = message ?? 'Unkonw error';
      } else if (code == 1004) {
        msg = sprintf(msg, [StrRes.meeting]);
      }

      msg = msgCallback?.call(code) ?? msg;

      IMViews.showToast(msg);

      if ((code == 10010 || code == 10002) && forceBack) {
        DataSp.removeLoginCertificate();
        Get.offAllNamed('/login');
      }
    } else {
      NetworkMonitor().isNetworkAvailable().then((isAvailable) {
        if (isAvailable) {
          IMViews.showToast(e.toString());
        } else {
          IMViews.showToast('${StrRes.networkNotStable}，${StrRes.operateAgain}');
        }
      });
    }
  }
}
