import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/tools/my_colors.dart';

class MyUseWayPage extends StatefulWidget {
  const MyUseWayPage({Key? key}) : super(key: key);

  @override
  State<MyUseWayPage> createState() => _MyUseWayPageState();
}

class _MyUseWayPageState extends State<MyUseWayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColors.grey_61cc,
        appBar: AppBar(
          title: const Text('使用说明及相关注意事项'),
        ),
        body: buildHuzi());
  }

  buildHuzi() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: const <Widget>[
          Text(
            "存储说明：",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
          Divider(
            height: 10,
          ),
          Text(
            "    我们的应用仅提供本地存储功能，不会保存用户任何数据，不会泄露用户的任何个人隐私数据。重要内容请注意备份。",
            style: TextStyle(color: MyColors.color_main),
          ),
          Divider(
            height: 30,
          ),
          Text(
            "使用说明：",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
          Divider(
            height: 10,
          ),
          Text(
            "    我们的应用包含记账、笔记、娱乐等多模块，可以随时切换工作和娱乐状态，更好的服务用户。",
            style: TextStyle(color: MyColors.color_main),
          ),
          Divider(
            height: 30,
          ),
          Text(
            "操作说明：",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
          Divider(
            height: 10,
          ),
          Text(
            "    记账模块包含普通记账，类型分类，金额统计，趋势分析。笔记模块包含日记记录，字数统计，习惯养成计划。",
            style: TextStyle(color: MyColors.color_main),
          ),
          Divider(
            height: 50,
          ),
          Text(
            "寄语：",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
          Divider(
            height: 10,
          ),
          Text(
            "    我们的应用还处于起步阶段，所有功能均免费可用，欢迎您下载使用。任何问题可以使用个人中心-意见反馈提交到后台，会有工作人员记录并处理",
            style: TextStyle(color: MyColors.color_main),
          ),
        ],
      ),
    );
  }
}
