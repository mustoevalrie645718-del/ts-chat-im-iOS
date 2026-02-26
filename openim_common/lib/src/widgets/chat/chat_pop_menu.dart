import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:openim_common/openim_common.dart';

class MenuInfo {
  String? icon;
  String text;
  Function()? onTap;
  bool enabled;

  MenuInfo({
    this.icon,
    required this.text,
    this.onTap,
    this.enabled = true,
  });
}

class ChatLongPressMenu extends StatelessWidget {
  final CustomPopupMenuController? popupMenuController;
  final List<MenuInfo> menus;
  final bool adjustWidth;

  const ChatLongPressMenu({
    Key? key,
    required this.popupMenuController,
    required this.menus,
    this.adjustWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // menus.removeWhere((element) => !element.enabled);
    // final count = menus.length < 5 ? menus.length : 5;
    return Container(
      constraints: BoxConstraints(maxWidth: 256.w, maxHeight: 122.h),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.black87.withAlpha(200) : Styles.c_0C1C33_opacity85,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(15.w, 6.h, 15.w, 3.h),
        child: Wrap(
          children: menus
              .map((e) => _menuItem(
                    icon: e.icon,
                    label: e.text,
                    onTap: e.onTap,
                    adjustWidth: adjustWidth,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _menuItem({
    String? icon,
    required String label,
    Function()? onTap,
    bool adjustWidth = false,
  }) =>
      GestureDetector(
        onTap: () {
          // Use hideMenuImmediately to ensure menu closes before onTap
          popupMenuController?.hideMenuImmediately();
          onTap?.call();
        },
        behavior: HitTestBehavior.translucent,
        child: adjustWidth
            ? IntrinsicWidth(
                child: SizedBox(
                  height: 24.h,
                  child: _MenuItemView(
                    icon: icon,
                    label: label,
                    labelStyle: Styles.ts_FFFFFF_14sp,
                  ),
                ),
              )
            : SizedBox(
                width: 42.w,
                height: 52.h,
                child: _MenuItemView(icon: icon, label: label),
              ),
      );
}

class _MenuItemView extends StatelessWidget {
  const _MenuItemView({
    Key? key,
    required this.icon,
    required this.label,
    this.labelStyle,
  }) : super(key: key);
  final String? icon;
  final String label;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          icon!.toImage
            ..width = 28.w
            ..height = 28.h,
        label.toText
          ..style =
              Get.isDarkMode ? TextStyle(color: Colors.white, fontSize: 10) : (labelStyle ?? Styles.ts_FFFFFF_10sp)
          ..maxLines = 1
          ..overflow = TextOverflow.ellipsis,
      ],
    );
  }
}

final allMenus = <MenuInfo>[
  MenuInfo(
    icon: ImageRes.menuCopy,
    text: StrRes.menuCopy,
    onTap: () {},
  ),
  MenuInfo(
    icon: ImageRes.menuDel,
    text: StrRes.menuDel,
    onTap: () {},
  ),
  MenuInfo(
    icon: ImageRes.menuForward,
    text: StrRes.menuForward,
    onTap: () {},
  ),
  MenuInfo(
    icon: ImageRes.menuReply,
    text: StrRes.menuReply,
    onTap: () {},
  ),
  MenuInfo(
    icon: ImageRes.menuMulti,
    text: StrRes.menuMulti,
    onTap: () {},
  ),
  MenuInfo(
    icon: ImageRes.menuRevoke,
    text: StrRes.menuRevoke,
    onTap: () {},
  ),
  MenuInfo(
    icon: ImageRes.menuAddFace,
    text: StrRes.menuAdd,
    onTap: () {},
  ),
];
