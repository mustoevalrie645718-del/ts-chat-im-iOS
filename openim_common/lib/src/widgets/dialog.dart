import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

enum DialogType {
  confirm,
}

class CustomDialog extends StatefulWidget {
  const CustomDialog({
    Key? key,
    this.title,
    this.url,
    this.content,
    this.rightText,
    this.leftText,
    this.onTapLeft,
    this.onTapRight,
    this.showCheckbox = false,
    this.checkboxText,
    this.initialCheckboxValue = false,
    this.onCheckboxChanged,
    this.alignment,
  }) : super(key: key);

  final String? title;
  final String? url;
  final String? content;
  final String? rightText;
  final String? leftText;
  final Alignment? alignment;
  final Function()? onTapLeft;
  final Function()? onTapRight;
  final bool showCheckbox;
  final String? checkboxText;
  final bool initialCheckboxValue;
  final Function(bool?)? onCheckboxChanged;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialCheckboxValue;
  }

  void _handleRightButtonTap() {
    if (widget.showCheckbox) {
      Get.back(result: {'confirmed': true, 'isChecked': _isChecked});
    } else {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: 300.w,
            color: Styles.c_FFFFFF,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title section
                if (widget.title != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, widget.content != null ? 16.h : 24.h),
                    alignment: widget.alignment ?? Alignment.center,
                    child: Text(
                      widget.title!,
                      textAlign: _getTextAlign(widget.alignment ?? Alignment.center),
                      style: Styles.ts_0C1C33_17sp.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // Content section
                if (widget.content != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                        24.w, widget.title != null ? 0 : 24.h, 24.w, widget.showCheckbox ? 16.h : 24.h),
                    alignment: widget.alignment ?? Alignment.center,
                    child: Text(
                      widget.content!,
                      textAlign: _getTextAlign(widget.alignment ?? Alignment.center),
                      style: Styles.ts_0C1C33_17sp.copyWith(
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),

                // Checkbox section
                if (widget.showCheckbox)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    alignment: widget.alignment ?? Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: widget.alignment == Alignment.center ? MainAxisSize.min : MainAxisSize.max,
                      mainAxisAlignment: _getMainAxisAlignment(widget.alignment ?? Alignment.centerLeft),
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (value) {
                            setState(() {
                              _isChecked = value ?? false;
                            });
                            widget.onCheckboxChanged?.call(value);
                          },
                          activeColor: Styles.c_0089FF,
                          checkColor: Colors.white,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        8.horizontalSpace,
                        widget.alignment == Alignment.center
                            ? Text(
                                widget.checkboxText ?? '',
                                style: Styles.ts_0C1C33_17sp.copyWith(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF666666),
                                ),
                              )
                            : Expanded(
                                child: Text(
                                  widget.checkboxText ?? '',
                                  style: Styles.ts_0C1C33_17sp.copyWith(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                // Divider
                Container(
                  height: 0.5.h,
                  color: Styles.c_E8EAEF,
                ),

                // Buttons section
                Row(
                  children: [
                    _button(
                      bgColor: Styles.c_FFFFFF,
                      text: widget.leftText ?? StrRes.cancel,
                      textStyle: Styles.ts_0C1C33_17sp,
                      onTap: widget.onTapLeft ?? () => Get.back(result: false),
                    ),
                    Container(
                      color: Styles.c_E8EAEF,
                      width: 0.5.w,
                      height: 48.h,
                    ),
                    _button(
                      bgColor: Styles.c_FFFFFF,
                      text: widget.rightText ?? StrRes.determine,
                      textStyle: Styles.ts_0089FF_17sp,
                      onTap: widget.onTapRight ?? () => _handleRightButtonTap(),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 根据Alignment获取对应的TextAlign
  TextAlign _getTextAlign(Alignment alignment) {
    if (alignment == Alignment.centerLeft || alignment == Alignment.topLeft || alignment == Alignment.bottomLeft) {
      return TextAlign.left;
    } else if (alignment == Alignment.centerRight ||
        alignment == Alignment.topRight ||
        alignment == Alignment.bottomRight) {
      return TextAlign.right;
    } else {
      return TextAlign.center;
    }
  }

  /// 根据Alignment获取对应的MainAxisAlignment
  MainAxisAlignment _getMainAxisAlignment(Alignment alignment) {
    if (alignment == Alignment.centerLeft || alignment == Alignment.topLeft || alignment == Alignment.bottomLeft) {
      return MainAxisAlignment.start;
    } else if (alignment == Alignment.centerRight ||
        alignment == Alignment.topRight ||
        alignment == Alignment.bottomRight) {
      return MainAxisAlignment.end;
    } else {
      return MainAxisAlignment.center;
    }
  }

  Widget _button({
    required Color bgColor,
    required String text,
    required TextStyle textStyle,
    Function()? onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
            ),
            height: 48.h,
            alignment: Alignment.center,
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ),
      );
}

class ForwardHintDialog extends StatelessWidget {
  const ForwardHintDialog({
    super.key,
    required this.title,
    this.checkedList = const [],
    this.controller,
  });
  final String title;
  final List<dynamic> checkedList;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final list = IMUtils.convertCheckedListToForwardObj(checkedList);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            margin: EdgeInsets.symmetric(horizontal: 36.w),
            decoration: BoxDecoration(
              color: Styles.c_FFFFFF,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                (list.length == 1 ? StrRes.sentTo : StrRes.sentSeparatelyTo).toText
                  ..style = Styles.ts_0C1C33_17sp_medium,
                5.verticalSpace,
                list.length == 1
                    ? Row(
                        children: [
                          AvatarView(
                            url: list.first['faceURL'],
                            text: list.first['nickname'],
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: (list.first['nickname'] ?? '').toText
                              ..style = Styles.ts_0C1C33_17sp
                              ..maxLines = 1
                              ..overflow = TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 120.h),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 0,
                            childAspectRatio: 50.w / 65.h,
                          ),
                          itemCount: list.length,
                          shrinkWrap: true,
                          itemBuilder: (_, index) => Column(
                            children: [
                              AvatarView(
                                url: list.elementAt(index)['faceURL'],
                                text: list.elementAt(index)['nickname'],
                              ),
                              10.horizontalSpace,
                              (list.elementAt(index)['nickname'] ?? '').toText
                                ..style = Styles.ts_8E9AB0_10sp
                                ..maxLines = 1
                                ..overflow = TextOverflow.ellipsis,
                            ],
                          ),
                        ),
                      ),
                5.verticalSpace,
                title.substring(0, title.length < 50 ? title.length : 50).toText
                  ..style = Styles.ts_8E9AB0_14sp
                  ..maxLines = 1
                  ..overflow = TextOverflow.ellipsis,
                10.verticalSpace,
                Container(
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: Styles.c_E8EAEF,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    style: Styles.ts_0C1C33_14sp,
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: StrRes.leaveMessage,
                      hintStyle: Styles.ts_8E9AB0_14sp,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 7.h,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                16.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StrRes.cancel.toText
                      ..style = Styles.ts_0C1C33_17sp
                      ..onTap = () => Get.back(),
                    26.horizontalSpace,
                    StrRes.determine.toText
                      ..style = Styles.ts_0089FF_17sp
                      ..onTap = () => Get.back(result: true),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
使用示例：

// 1. 只有标题的对话框
Get.dialog(CustomDialog(
  title: "确认删除该消息？",
));

// 2. 只有内容的对话框
Get.dialog(CustomDialog(
  content: "该操作不可恢复，请谨慎操作",
));

// 3. 标题 + 内容的对话框
Get.dialog(CustomDialog(
  title: "确认删除消息",
  content: "删除后无法恢复，是否继续？",
));

// 4. 带复选框的对话框（如UI图所示）
final result = await Get.dialog(CustomDialog(
  title: "确认删除该条消息？",
  showCheckbox: true,
  checkboxText: "确认双向删除该条消息？",
  initialCheckboxValue: false,
));
// 结果: {'confirmed': true, 'isChecked': true/false} 或 false(取消)

// 5. 自定义按钮文字
Get.dialog(CustomDialog(
  title: "退出群聊",
  content: "退出后将不再接收此群消息",
  leftText: "取消",
  rightText: "退出",
));

// 6. 自定义对齐方式
final result = await Get.dialog(CustomDialog(
  title: "左对齐标题",
  content: "左对齐内容文本",
  alignment: Alignment.centerLeft,
  showCheckbox: true,
  checkboxText: "复选框也会左对齐",
  initialCheckboxValue: false,
));

// 7. 右对齐示例
Get.dialog(CustomDialog(
  title: "右对齐标题",
  content: "右对齐内容文本", 
  alignment: Alignment.centerRight,
));
*/
