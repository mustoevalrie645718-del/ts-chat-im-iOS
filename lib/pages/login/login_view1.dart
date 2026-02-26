// import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:openim_common/openim_common.dart';
//
// import 'login_logic.dart';
//
// class LoginPage extends GetView<LoginLogic> {
//   // final logic = Get.find<LoginLogic>();
//
//   LoginLogic get logic => controller;
//
//   const LoginPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: TouchCloseSoftKeyboard(
//         isGradientBg: true,
//         child: _buildLayout(),
//       ),
//     );
//   }
//
//   /// Build page layout
//   Widget _buildLayout() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return SingleChildScrollView(
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               minHeight: constraints.maxHeight,
//             ),
//             child: IntrinsicHeight(
//               child: Column(
//                 children: [
//                   _buildHeader(),
//                   _buildLoginForm(),
//                   _buildRegisterLink(),
//                   const Spacer(),
//                   _buildVersionInfo(),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   /// Build page header
//   Widget _buildHeader() {
//     return Column(
//       children: [
//         88.verticalSpace,
//         _buildLogo(),
//         40.verticalSpace,
//       ],
//     );
//   }
//
//   /// Build logo section
//   Widget _buildLogo() {
//     return Column(
//       children: [
//         ImageRes.loginLogo.toImage
//           ..width = 80.w
//           ..height = 80.h
//           ..onDoubleTap = logic.configService,
//         StrRes.welcome.toText..style = Styles.ts_0089FF_17sp_semibold,
//       ],
//     );
//   }
//
//   /// Build login form
//   Widget _buildLoginForm() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 32.w),
//       child: Column(
//         children: [
//           _buildTabView(),
//           46.verticalSpace,
//           _buildLoginButton(),
//         ],
//       ),
//     );
//   }
//
//   /// Build tab view
//   Widget _buildTabView() {
//     return Container(
//       height: 222.h,
//       width: 300.w,
//       child: Column(
//         children: [
//           _buildTabBar(),
//           Flexible(child: _buildTabBarView()),
//         ],
//       ),
//     );
//   }
//
//   /// Build tab bar
//   Widget _buildTabBar() {
//     return TabBar(
//       tabs: LoginType.values.map((e) => Tab(text: e.name)).toList(),
//       controller: logic.tabController,
//       isScrollable: true,
//       indicatorColor: Styles.c_0089FF,
//       labelColor: Styles.c_0089FF,
//       tabAlignment: TabAlignment.start,
//       labelPadding: const EdgeInsets.only(right: 16),
//       overlayColor: WidgetStateProperty.all(Colors.transparent),
//       dividerHeight: 0.1,
//       onTap: _handleTabTap,
//     );
//   }
//
//   /// Handle tab tap
//   void _handleTabTap(int index) {
//     logic.loginType.value = LoginType.fromRawValue(index);
//     logic.operateType = logic.loginType.value;
//     FocusScope.of(Get.context!).unfocus();
//     logic.phoneCtrl.clear();
//     logic.pwdCtrl.clear();
//   }
//
//   /// Build tab bar view content
//   Widget _buildTabBarView() {
//     return TabBarView(
//       controller: logic.tabController,
//       physics: const NeverScrollableScrollPhysics(),
//       children: [
//         _buildPhoneEmailInput(LoginType.phone),
//         _buildPhoneEmailInput(LoginType.email),
//         _buildAccountInput(),
//       ],
//     );
//   }
//
//   /// Build phone/email input view
//   Widget _buildPhoneEmailInput(LoginType type) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _buildAccountInputField(type),
//         8.verticalSpace,
//         _buildPasswordOrVerificationSection(),
//         10.verticalSpace,
//         _buildBottomActionRow(),
//       ],
//     );
//   }
//
//   /// Build account input field
//   Widget _buildAccountInputField(LoginType type) {
//     return Obx(() => InputBox.account(
//           label: '',
//           hintText: type.hintText,
//           code: logic.areaCode.value,
//           onAreaCode: type == LoginType.phone ? logic.openCountryCodePicker : null,
//           controller: logic.phoneCtrl,
//           focusNode: logic.accountFocus,
//           keyBoardType: type == LoginType.phone ? TextInputType.phone : TextInputType.text,
//         ));
//   }
//
//   /// Build password or verification code section
//   Widget _buildPasswordOrVerificationSection() {
//     return Column(
//       children: [
//         Obx(() => Offstage(
//               offstage: !logic.isPasswordLogin.value,
//               child: _buildPasswordInputField(),
//             )),
//         Obx(() => Offstage(
//               offstage: logic.isPasswordLogin.value,
//               child: _buildVerificationCodeInputField(),
//             )),
//       ],
//     );
//   }
//
//   /// Build password input field
//   Widget _buildPasswordInputField() {
//     return InputBox.password(
//       label: '',
//       hintText: StrRes.plsEnterPassword,
//       controller: logic.pwdCtrl,
//       focusNode: logic.pwdFocus,
//     );
//   }
//
//   /// Build verification code input field
//   Widget _buildVerificationCodeInputField() {
//     return InputBox.verificationCode(
//       label: StrRes.verificationCode,
//       hintText: StrRes.plsEnterVerificationCode,
//       controller: logic.verificationCodeCtrl,
//       onSendVerificationCode: logic.getVerificationCode,
//     );
//   }
//
//   /// Build bottom action row
//   Widget _buildBottomActionRow() {
//     return Row(
//       children: [
//         _buildForgetPasswordLink(),
//         const Spacer(),
//         _buildToggleLoginTypeLink(),
//       ],
//     );
//   }
//
//   /// Build forget password link
//   Widget _buildForgetPasswordLink() {
//     return StrRes.forgetPassword.toText
//       ..style = Styles.ts_8E9AB0_12sp
//       ..onTap = logic.forgetPassword;
//   }
//
//   /// Build toggle login type link
//   Widget _buildToggleLoginTypeLink() {
//     return Obx(() => (logic.isPasswordLogin.value ? StrRes.verificationCodeLogin : StrRes.passwordLogin).toText
//       ..style = Styles.ts_0089FF_12sp
//       ..onTap = logic.togglePasswordType);
//   }
//
//   /// Build account input view
//   Widget _buildAccountInput() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _buildAccountInputField(LoginType.account),
//         8.verticalSpace,
//         _buildPasswordInputField(),
//       ],
//     );
//   }
//
//   /// Build login button
//   Widget _buildLoginButton() {
//     return Obx(() => Button(
//           text: StrRes.login,
//           enabled: logic.enabled.value,
//           onTap: logic.login,
//         ));
//   }
//
//   /// Build register link
//   Widget _buildRegisterLink() {
//     return Column(
//       children: [
//         16.verticalSpace,
//         Obx(() => Visibility(
//               visible: logic.loginType.value != LoginType.account,
//               child: _buildRegisterRichText(),
//             )),
//       ],
//     );
//   }
//
//   /// Build register rich text
//   Widget _buildRegisterRichText() {
//     return RichText(
//       text: TextSpan(
//         text: StrRes.noAccountYet,
//         style: Styles.ts_8E9AB0_12sp,
//         children: [
//           TextSpan(
//             text: StrRes.registerNow,
//             style: Styles.ts_0089FF_12sp,
//             recognizer: TapGestureRecognizer()..onTap = _showRegisterBottomSheet,
//           )
//         ],
//       ),
//     );
//   }
//
//   /// Show register bottom sheet
//   void _showRegisterBottomSheet() {
//     showCupertinoModalPopup(
//       context: Get.context!,
//       builder: (BuildContext context) {
//         return CupertinoActionSheet(
//           actions: [
//             CupertinoActionSheetAction(
//               onPressed: () {
//                 Navigator.pop(context);
//                 logic.operateType = LoginType.email;
//                 logic.registerNow();
//               },
//               child: Text('${StrRes.email} ${StrRes.registerNow}'),
//             ),
//             CupertinoActionSheetAction(
//               onPressed: () {
//                 Navigator.pop(context);
//                 logic.operateType = LoginType.phone;
//                 logic.registerNow();
//               },
//               child: Text('${StrRes.phoneNumber} ${StrRes.registerNow}'),
//             ),
//           ],
//           cancelButton: CupertinoActionSheetAction(
//             onPressed: () => Navigator.pop(context),
//             child: Text(StrRes.cancel),
//           ),
//         );
//       },
//     );
//   }
//
//   /// Build version info
//   Widget _buildVersionInfo() {
//     return Column(
//       children: [
//         32.verticalSpace,
//         Obx(() => logic.versionInfo.value.toText..style = Styles.ts_0C1C33_14sp),
//         32.verticalSpace,
//       ],
//     );
//   }
// }
