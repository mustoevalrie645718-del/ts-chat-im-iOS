import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'set_background_logic.dart';

class SetKkxBackgroundImagePage extends StatelessWidget {
  final logic = Get.find<SetBackgroundImageLogic>();

  SetKkxBackgroundImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.setChatBackground,
      ),
      backgroundColor: Styles.c_F8F9FA,
      body: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(6.0)), // 设置四角圆角半径
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Styles.c_707070,
                ),
                title: Text(
                  StrRes.selectAssetsFromAlbum,
                  style: Styles.ts_0C1C33_17sp,
                ),
                dense: true,
                onTap: () {
                  // 处理从相册选取的逻辑
                  logic.onTapAlbum();
                },
              ),
              ListTile(
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Styles.c_707070,
                ),
                title: Text(StrRes.selectAssetsFromCamera,
                    style: Styles.ts_0C1C33_17sp),
                dense: true,
                onTap: () {
                  logic.onTapCamera();
                },
              ),
              ListTile(
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Styles.c_707070,
                ),
                title: Text(StrRes.setDefaultBackground,
                    style: Styles.ts_0C1C33_17sp),
                dense: true,
                onTap: () {
                  logic.recover();
                },
              ),
            ],
          )),
    );
  }
}
