import 'package:get/get.dart';

import '../pages/chat/chat_binding.dart';
import '../pages/chat/chat_setup/chat_setup_binding.dart';
import '../pages/chat/chat_setup/chat_setup_view.dart';
import '../pages/chat/chat_setup/favorite_manage/favorite_manage_binding.dart';
import '../pages/chat/chat_setup/favorite_manage/favorite_manage_view.dart';
import '../pages/chat/chat_setup/search_chat_history/file/file_binding.dart';
import '../pages/chat/chat_setup/search_chat_history/file/file_view.dart';
import '../pages/chat/chat_setup/search_chat_history/multimedia/multimedia_binding.dart';
import '../pages/chat/chat_setup/search_chat_history/multimedia/multimedia_view.dart';
import '../pages/chat/chat_setup/search_chat_history/preview_chat_history/preview_chat_history_binding.dart';
import '../pages/chat/chat_setup/search_chat_history/preview_chat_history/preview_chat_history_view.dart';
import '../pages/chat/chat_setup/search_chat_history/search_chat_history_binding.dart';
import '../pages/chat/chat_setup/search_chat_history/search_chat_history_view.dart';
import '../pages/chat/chat_setup/set_background/set_background_binding.dart';
import '../pages/chat/chat_setup/set_background/set_background_view.dart';
import '../pages/chat/chat_setup/set_font_size/set_font_size_binding.dart';
import '../pages/chat/chat_setup/set_font_size/set_font_size_view.dart';
import '../pages/chat/chat_view.dart';
import '../pages/chat/group_setup/edit_announcement/edit_announcement_binding.dart';
import '../pages/chat/group_setup/edit_announcement/edit_announcement_view.dart';
import '../pages/chat/group_setup/edit_name/edit_name_binding.dart';
import '../pages/chat/group_setup/edit_name/edit_name_view.dart';
import '../pages/chat/group_setup/group_manage/group_manage_binding.dart';
import '../pages/chat/group_setup/group_manage/group_manage_view.dart';
import '../pages/chat/group_setup/group_member_list/group_member_list_binding.dart';
import '../pages/chat/group_setup/group_member_list/group_member_list_view.dart';
import '../pages/chat/group_setup/group_member_list/search_group_member/search_group_member_binding.dart';
import '../pages/chat/group_setup/group_member_list/search_group_member/search_group_member_view.dart';
import '../pages/chat/group_setup/group_qrcode/group_qrcode_binding.dart';
import '../pages/chat/group_setup/group_qrcode/group_qrcode_view.dart';
import '../pages/chat/group_setup/group_setup_binding.dart';
import '../pages/chat/group_setup/group_setup_view.dart';
import '../pages/chat/group_setup/set_mute_for_memeber/set_mute_for_member_binding.dart';
import '../pages/chat/group_setup/set_mute_for_memeber/set_mute_for_member_view.dart';
import '../pages/chat/oa_notification/oa_notification_binding.dart';
import '../pages/chat/oa_notification/oa_notification_view.dart';
import '../pages/contacts/add_by_search/add_by_search_binding.dart';
import '../pages/contacts/add_by_search/add_by_search_view.dart';
import '../pages/contacts/add_method/add_method_binding.dart';
import '../pages/contacts/add_method/add_method_view.dart';
import '../pages/contacts/create_group/create_group_binding.dart';
import '../pages/contacts/create_group/create_group_view.dart';
import '../pages/contacts/friend_list/friend_list_binding.dart';
import '../pages/contacts/friend_list/friend_list_view.dart';
import '../pages/contacts/friend_list/search_friend/search_friend_binding.dart';
import '../pages/contacts/friend_list/search_friend/search_friend_view.dart';
import '../pages/contacts/friend_requests/friend_requests_binding.dart';
import '../pages/contacts/friend_requests/friend_requests_view.dart';
import '../pages/contacts/friend_requests/process_friend_requests/process_friend_requests_binding.dart';
import '../pages/contacts/friend_requests/process_friend_requests/process_friend_requests_view.dart';
import '../pages/contacts/group_list/group_list_binding.dart';
import '../pages/contacts/group_list/group_list_view.dart';
import '../pages/contacts/group_list/search_group/search_group_binding.dart';
import '../pages/contacts/group_list/search_group/search_group_view.dart';
import '../pages/contacts/group_profile_panel/group_profile_panel_binding.dart';
import '../pages/contacts/group_profile_panel/group_profile_panel_view.dart';
import '../pages/contacts/group_requests/group_requests_binding.dart';
import '../pages/contacts/group_requests/group_requests_view.dart';
import '../pages/contacts/group_requests/process_group_requests/process_group_requests_binding.dart';
import '../pages/contacts/group_requests/process_group_requests/process_group_requests_view.dart';
import '../pages/contacts/select_contacts/friend_list/friend_list_binding.dart';
import '../pages/contacts/select_contacts/friend_list/friend_list_view.dart';
import '../pages/contacts/select_contacts/friend_list/search_friend/search_friend_binding.dart';
import '../pages/contacts/select_contacts/friend_list/search_friend/search_friend_view.dart';
import '../pages/contacts/select_contacts/group_list/group_list_binding.dart';
import '../pages/contacts/select_contacts/group_list/group_list_view.dart';
import '../pages/contacts/select_contacts/group_list/search_group/search_group_binding.dart';
import '../pages/contacts/select_contacts/group_list/search_group/search_group_view.dart';
import '../pages/contacts/select_contacts/search_contacts/search_contacts_binding.dart';
import '../pages/contacts/select_contacts/search_contacts/search_contacts_view.dart';
import '../pages/contacts/select_contacts/select_contacts_binding.dart';
import '../pages/contacts/select_contacts/select_contacts_view.dart';
import '../pages/contacts/send_verification_application/send_verification_application_binding.dart';
import '../pages/contacts/send_verification_application/send_verification_application_view.dart';
import '../pages/contacts/user_profile_panel/friend_setup/friend_setup_binding.dart';
import '../pages/contacts/user_profile_panel/friend_setup/friend_setup_view.dart';
import '../pages/contacts/user_profile_panel/personal_info/personal_info_binding.dart';
import '../pages/contacts/user_profile_panel/personal_info/personal_info_view.dart';
import '../pages/contacts/user_profile_panel/set_remark/set_remark_binding.dart';
import '../pages/contacts/user_profile_panel/set_remark/set_remark_view.dart';
import '../pages/contacts/user_profile_panel/user_profile _panel_binding.dart';
import '../pages/contacts/user_profile_panel/user_profile _panel_view.dart';
import '../pages/forget_password/forget_password_binding.dart';
import '../pages/forget_password/forget_password_view.dart';
import '../pages/forget_password/reset_password/reset_password_binding.dart';
import '../pages/forget_password/reset_password/reset_password_view.dart';
import '../pages/global_search/expand_chat_history/expand_chat_history_binding.dart';
import '../pages/global_search/expand_chat_history/expand_chat_history_view.dart';
import '../pages/global_search/global_search_binding.dart';
import '../pages/global_search/global_search_view.dart';
import '../pages/home/home_binding.dart';
import '../pages/home/home_view.dart';
import '../pages/login/login_binding.dart';
import '../pages/login/login_view.dart';
import '../pages/mine/about_us/about_us_binding.dart';
import '../pages/mine/about_us/about_us_view.dart';
import '../pages/mine/account_setup/account_setup_binding.dart';
import '../pages/mine/account_setup/account_setup_view.dart';
import '../pages/mine/blacklist/blacklist_binding.dart';
import '../pages/mine/blacklist/blacklist_view.dart';
import '../pages/mine/change_pwd/change_pwd_binding.dart';
import '../pages/mine/change_pwd/change_pwd_view.dart';
import '../pages/mine/edit_my_info/edit_my_info_binding.dart';
import '../pages/mine/edit_my_info/edit_my_info_view.dart';
import '../pages/mine/language_setup/language_setup_binding.dart';
import '../pages/mine/language_setup/language_setup_view.dart';
import '../pages/mine/my_info/my_info_binding.dart';
import '../pages/mine/my_info/my_info_view.dart';
import '../pages/mine/my_qrcode/my_qrcode_binding.dart';
import '../pages/mine/my_qrcode/my_qrcode_view.dart';
import '../pages/mine/unlock_setup/unlock_setup_binding.dart';
import '../pages/mine/unlock_setup/unlock_setup_view.dart';
import '../pages/register/register_binding.dart';
import '../pages/register/register_view.dart';
import '../pages/register/set_password/set_password_binding.dart';
import '../pages/register/set_password/set_password_view.dart';
import '../pages/register/set_self_info/set_self_info_binding.dart';
import '../pages/register/set_self_info/set_self_info_view.dart';
import '../pages/register/verify_phone/verify_phone_binding.dart';
import '../pages/register/verify_phone/verify_phone_view.dart';
import '../pages/splash/splash_binding.dart';
import '../pages/splash/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  /// 左滑关闭页面用于android
  static _pageBuilder({
    required String name,
    required GetPageBuilder page,
    Bindings? binding,
    bool preventDuplicates = true,
    bool popGesture = true,
  }) =>
      GetPage(
        name: name,
        page: page,
        binding: binding,
        preventDuplicates: preventDuplicates,
        transition: Transition.cupertino,
        popGesture: popGesture,
      );

  static final routes = <GetPage>[
    _pageBuilder(
      name: AppRoutes.splash,
      page: () => SplashPage(),
      binding: SplashBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.login,
      page: () => MyLoginPage(),
      binding: LoginBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.home,
      page: () => HomeViewPage(),
      binding: HomeBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.chat,
      page: () => MyChatPage(),
      binding: ChatBinding(),
      preventDuplicates: false,
    ),
    _pageBuilder(
      name: AppRoutes.myQrcode,
      page: () => JustMyQrcodePage(),
      binding: MyQrcodeBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.chatSetup,
      page: () => ChatNewSetupPage(),
      binding: ChatSetupBinding(),
      popGesture: false,
    ),
    _pageBuilder(
      name: AppRoutes.favoriteManage,
      page: () => MyFavoriteManagePage(),
      binding: FavoriteManageBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.addContactsMethod,
      page: () => MyAddContactsMethodPage(),
      binding: AddContactsMethodBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.addContactsBySearch,
      page: () => MyAddContactsBySearchPage(),
      binding: AddContactsBySearchBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.userProfilePanel,
      page: () => UserNewProfilePanelPage(),
      binding: UserProfilePanelBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.personalInfo,
      page: () => PersonalInfoIngPage(),
      binding: PersonalInfoBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.friendSetup,
      page: () => FriendSetupIngPage(),
      binding: FriendSetupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.setFriendRemark,
      page: () => SetLivsFriendRemarkPage(),
      binding: SetFriendRemarkBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.sendVerificationApplication,
      page: () => SendVerificationApplicationViewPage(),
      binding: SendVerificationApplicationBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.groupProfilePanel,
      page: () => GroupProfilePanelNewPage(),
      binding: GroupProfilePanelBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.setMuteForGroupMember,
      page: () => SetMuteKkxForGroupMemberPage(),
      binding: SetMuteForGroupMemberBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.myInfo,
      page: () => YouMyInfoPage(),
      binding: MyInfoBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.editMyInfo,
      page: () => FunsEditMyInfoPage(),
      binding: EditMyInfoBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.accountSetup,
      page: () => AccountSetupIngPage(),
      binding: AccountSetupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.blacklist,
      page: () => BlacklistDwPage(),
      binding: BlacklistBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.languageSetup,
      page: () => LanguageSetupPageView(),
      binding: LanguageSetupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.unlockSetup,
      page: () => UnlockSetupViewPage(),
      binding: UnlockSetupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.changePassword,
      page: () => MyChangePwdPage(),
      binding: ChangePwdBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.aboutUs,
      page: () => AboutUsWayPage(),
      binding: AboutUsBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.setBackgroundImage,
      page: () => SetKkxBackgroundImagePage(),
      binding: SetBackgroundImageBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.setFontSize,
      page: () => SetKkxFontSizePage(),
      binding: SetFontSizeBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.searchChatHistory,
      page: () => MySearchChatHistoryPage(),
      binding: SearchChatHistoryBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.searchChatHistoryMultimedia,
      page: () => ChatHistoryMultimediaPage(),
      binding: ChatHistoryMultimediaBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.searchChatHistoryFile,
      page: () => ChatHistoryFilePage(),
      binding: ChatHistoryFileBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.previewChatHistory,
      page: () => PreviewChatHistoryPage(),
      binding: PreviewChatHistoryBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.groupChatSetup,
      page: () => GroupSetupErPage(),
      binding: GroupSetupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.groupManage,
      page: () => GroupMyManagePage(),
      binding: GroupManageBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.editGroupName,
      page: () => EditFunGroupNamePage(),
      binding: EditGroupNameBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.editGroupAnnouncement,
      page: () => GetViewEditGroupAnnouncementPage(),
      binding: EditGroupAnnouncementBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.groupMemberList,
      page: () => GroupMemberErListPage(),
      binding: GroupMemberListBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.searchGroupMember,
      page: () => MySearchGroupMemberPage(),
      binding: SearchGroupMemberBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.groupQrcode,
      page: () => GetGroupQrcodePage(),
      binding: GroupQrcodeBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.friendRequests,
      page: () => LiveFriendRequestsPage(),
      binding: FriendRequestsBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.processFriendRequests,
      page: () => ProcessFriendRequestsRePage(),
      binding: ProcessFriendRequestsBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.groupRequests,
      page: () => GroupPaesRequestsPage(),
      binding: GroupRequestsBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.processGroupRequests,
      page: () => ProcessGroupRequestsViewPage(),
      binding: ProcessGroupRequestsBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.friendList,
      page: () => MyFriendListPage(),
      binding: FriendListBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.groupList,
      page: () => GroupListViePage(),
      binding: GroupListBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.searchFriend,
      page: () => SearchFriendShipPage(),
      binding: SearchFriendBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.searchGroup,
      page: () => SearchNewGroupPage(),
      binding: SearchGroupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.selectContacts,
      page: () => YourSelectContactsPage(),
      binding: SelectContactsBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.selectContactsFromFriends,
      page: () => MySelectContactsFromFriendsPage(),
      binding: SelectContactsFromFriendsBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.selectContactsFromGroup,
      page: () => WindySelectContactsFromGroupPage(),
      binding: SelectContactsFromGroupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.selectContactsFromSearchFriends,
      page: () => SelectContactsCLoudFromSearchFriendsPage(),
      binding: SelectContactsFromSearchFriendsBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.selectContactsFromSearchGroup,
      page: () => SelectContactsFromSearchGroupPage(),
      binding: SelectContactsFromSearchGroupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.selectContactsFromSearch,
      page: () => SelectKkxContactsFromSearchPage(),
      binding: SelectContactsFromSearchBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.createGroup,
      page: () => CreateFeiGroupPage(),
      binding: CreateGroupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.globalSearch,
      page: () => QuanGlobalSearchPage(),
      binding: GlobalSearchBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.expandChatHistory,
      page: () => ExpandChatHistoryPage(),
      binding: ExpandChatHistoryBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.register,
      page: () => RegisterPageViews(),
      binding: RegisterBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.verifyPhone,
      page: () => VerifyPhoneWsPage(),
      binding: VerifyPhoneBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.setPassword,
      page: () => SetPasswordsPage(),
      binding: SetPasswordBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.setSelfInfo,
      page: () => SetSelfInfosViewPage(),
      binding: SetSelfInfoBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.forgetPassword,
      page: () => JustForgetPasswordPage(),
      binding: ForgetPasswordBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.resetPassword,
      page: () => NewResetPasswordPage(),
      binding: ResetPasswordBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.oaNotificationList,
      page: () => LivOANotificationPage(),
      binding: OANotificationBinding(),
    ),
  ];
}
