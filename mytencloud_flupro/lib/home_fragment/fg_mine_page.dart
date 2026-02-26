import 'package:animations/animations.dart';
import 'package:mytencloud_flupro/tools/toast_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pricypage/setting_list.dart';
import '../viewpages/FanKuiPage.dart';
import '../stylesutil/SharedPreferenceUtil.dart';
import '../stylesutil/res_urils.dart';
import '../viewpages/AppPage.dart';
import '../viewpages/MoUtilsPage.dart';
import '../viewpages/UserLetterPage.dart';
import '../viewpages/saving_tips_page.dart';
import '../viewpages/invoice_list_page.dart';
import '../viewpages/settings_page.dart';

class MineFragment extends StatefulWidget {
  @override
  _MineFragmentState createState() => _MineFragmentState();
}

class _MineFragmentState extends State<MineFragment> {
  bool myCheck=false; //同步开关
  String username = "Mike";
  String sign = "Just DO IT";
  int indexLogun = 0;
  int maxLien = 0;
  var listviews = [
     Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          onTap: (){
            ToastUtil.showMyToast("It's the latest version");
          },
          title: const Text(
            "当前版本", //当前版本新增版本说明
            style: TextStyle(fontSize: 16),
          ),
          subtitle: Text("V1.1.1"),
          dense: true,
          trailing:  Icon(CupertinoIcons.right_chevron),
        ),
      ),
    ),
    // Padding(
    //   padding: const EdgeInsets.all(8.0),
    //   child: Card(
    //     child: OpenContainer(
    //       transitionDuration: Duration(milliseconds: 500),
    //       openBuilder: (BuildContext context,
    //           void Function({Object returnValue}) action) {
    //         return InvoiceListPage();
    //       },
    //       closedBuilder: (BuildContext context, void Function() action) {
    //         return const ListTile(
    //           title: Text(
    //             "发票助手",
    //             style: TextStyle(fontSize: 16),
    //           ),
    //           trailing: const Icon(CupertinoIcons.right_chevron),
    //         );
    //       },
    //     ),
    //   ),
    // ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: OpenContainer(
          transitionDuration: Duration(milliseconds: 500),
          openBuilder: (BuildContext context,
              void Function({Object returnValue}) action) {
            return SettingListPage();
          },
          closedBuilder: (BuildContext context, void Function() action) {
            return const ListTile(
              title: Text(
                "安全",
                style: TextStyle(fontSize: 16),
              ),
              trailing: const Icon(CupertinoIcons.right_chevron),
            );
          },
        ),
      ),
    ), Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: OpenContainer(
          transitionDuration: Duration(milliseconds: 500),
          openBuilder: (BuildContext context,
              void Function({Object returnValue}) action) {
            return SettingsPage();
          },
          closedBuilder: (BuildContext context, void Function() action) {
            return const ListTile(
              title: Text(
                "设置",
                style: TextStyle(fontSize: 16),
              ),
              trailing: const Icon(CupertinoIcons.right_chevron),
            );
          },
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: OpenContainer(
          transitionDuration: Duration(milliseconds: 500),
          openBuilder: (BuildContext context,
              void Function({Object returnValue}) action) {
            return FanKuiPage();
          },
          closedBuilder: (BuildContext context, void Function() action) {
            return const ListTile(
              title: Text(
                "反馈",
                style: TextStyle(fontSize: 16),
              ),
              trailing: const Icon(CupertinoIcons.right_chevron),
            );
          },
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: OpenContainer(
        transitionDuration: Duration(milliseconds: 500),
        openBuilder:
            (BuildContext context, void Function({Object returnValue}) action) {
          return  UserLetterPage();
        },
        closedBuilder: (BuildContext context, void Function() action) {
          return const ListTile(
            title: Text(
              "致用户的一封信",
              style: TextStyle(fontSize: 16),
            ),
            trailing: Icon(CupertinoIcons.right_chevron),
          );
        },
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: OpenContainer(
        transitionDuration: Duration(milliseconds: 500),
        openBuilder:
            (BuildContext context, void Function({Object returnValue}) action) {
          return  AppPage();
        },
        closedBuilder: (BuildContext context, void Function() action) {
          return const ListTile(
            title: Text(
              "关于应用", //关于应用
              style: TextStyle(fontSize: 16),
            ),
            trailing: Icon(CupertinoIcons.right_chevron),
          );
        },
      ),
    ),
    
  ];

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    SharedPreferenceUtil.getString("username").then((value) => {
          if (value != null) {username = value, setState(() {})}
        });
    SharedPreferenceUtil.getString("sign").then((value) => {
          if (value != null) {sign = value, setState(() {})}
        });
    SharedPreferenceUtil.getInt("logoindex").then((value) => {
          if (value != null) {indexLogun = value, setState(() {})}
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
            elevation: 0,
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                titlePadding: EdgeInsets.only(left: 10, top: 10),
                title: SizedBox(
                  height: 80,
                  child: InkWell(
                    onTap: () {
                      // Navigator.push(context,
                      //     CupertinoPageRoute(builder: (cet) {
                      //   return SetInfoPage();
                      // })).then((value) => {initData()});
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(headList[indexLogun]),
                    ),
                  ),
                ),
                background: Image.asset(
                  'assets/icon/ban_sp2.jpg',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.5),
                ))),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF2FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: OpenContainer(
                transitionDuration: Duration(milliseconds: 500),
                openBuilder: (BuildContext context,
                    void Function({Object returnValue}) action) {
                  return MoreListTollsPage();
                },
                closedBuilder: (BuildContext context, void Function() action) {
                  return const ListTile(
                    tileColor:  Color(0xFFEDF2FA),
                    subtitle:  Text("优先体验最新功能，欢迎体验"),
                    title: Text(
                      "尝鲜区",
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Icon(CupertinoIcons.right_chevron),
                  );
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF2FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              itemExtent: 80,
              itemBuilder: (ctx, index) {
                return listviews[index];
              },
              itemCount: listviews.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 120.0), // 在顶部插入空白
        ),
      ]),
    );
  }
}
