import 'config.dart';

/// Urls of backend API endpoints.
class Urls {
  /// Base URLs
  static String get _imApi => Config.imApiUrl;
  static String get _authApi => Config.appAuthUrl;

  /// ----------------- Auth -----------------

  static String get getVerificationCode => '$_authApi/account/code/send';
  static String get checkVerificationCode => '$_authApi/account/code/verify';
  static String get register => '$_authApi/account/register';
  static String get resetPwd => '$_authApi/account/password/reset';
  static String get changePwd => '$_authApi/account/password/change';
  static String get login => '$_authApi/account/login';
  static String get thirdPartyAutoLogin => '$_authApi/account/login/oauth/auto';

  static String get thirdPartyLogin => '$_authApi/account/login/oauth';
  static String get thirdPartyRegister => '$_authApi/account/register/oauth';
  static String get deleteAccount => '$_authApi/user/unregister_user';

  /// ----------------- User -----------------

  static String get updateUserInfo => '$_authApi/user/update';
  static String get getUsersFullInfo => '$_authApi/user/find/full';
  static String get searchUserFullInfo => '$_authApi/user/search/full';

  /// ----------------- Friend -----------------

  static String get searchFriendInfo => '$_authApi/friend/search';

  /// ----------------- Manager -----------------

  static String get onlineStatus => '$_imApi/manager/get_users_online_status';
  static String get queryAllUsers => '$_imApi/manager/get_all_users_uid';

  /// ----------------- Client Config -----------------

  static String get getClientConfig => '$_authApi/client_config/get';

  /// ----------------- Meeting -----------------

  static String get _meeting => '$_imApi/rtc-meeting';
  static String get logout => '$_meeting/logout';
  static String get getMeetings => '$_meeting/get_meetings';
  static String get booking => '$_meeting/book_meeting';
  static String get quickly => '$_meeting/create_immediate_meeting';
  static String get join => '$_meeting/join_meeting';
  static String get getLiveToken => '$_meeting/get_meeting_token';
  static String get getMeeting => '$_meeting/get_meeting';
  static String get leaveMeeting => '$_meeting/leave_meeting';
  static String get endMeeting => '$_meeting/end_meeting';
  static String get setPersonalSetting => '$_meeting/set_personal_setting';
  static String get updateSetting => '$_meeting/update_meeting';
  static String get operateAllStream => '$_meeting/operate_meeting_all_stream';
  static String get modifyParticipantName => '$_meeting/modify_meeting_participant_name';
  static String get kickParticipants => '$_meeting/remove_participants';
  static String get setMeetingHost => '$_meeting/set_meeting_host_info';

  /// ----------------- App -----------------

  static String get upgrade => '$_authApi/app/check';
}
