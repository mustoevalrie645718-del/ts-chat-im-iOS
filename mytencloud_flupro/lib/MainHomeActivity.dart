import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mytencloud_flupro/home_fragment/fg_cube.dart';
import 'package:mytencloud_flupro/viewpages/diary_list_page.dart';

import '../tools/my_colors.dart';
import 'home_fragment/NewHomePage.dart';
import 'home_fragment/NewToolsPage.dart';
import 'home_fragment/fg_daylib.dart';
import 'home_fragment/fg_mine_page.dart';
import 'home_fragment/fg_data_page.dart';
import 'home_fragment/fg_home_page.dart';
import 'localbean/CheckBoxBean.dart';
import 'pages/habit_list_page.dart';

class MainPage extends StatefulWidget {

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> itemList = <Widget>[];
  int currentIndexView = 0;

  @override
  void initState() {
    super.initState();
    itemList
      ..add(NewHomePage()) //记账
      // ..add(HomeFragment()) //记账
      // ..add(HomeFragment()) //记账
      ..add(DiaryListPage())
      // ..add(FgCubePage()) //记账
      // ..add(Check_home()) //工作台
      // ..add(ShuJuPage()) //数据分析
      ..add(HabitListPage()) //养生
      ..add(NewToolsPage()) //发现

      ..add(MineFragment()); //我的
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: itemList[currentIndexView],
      // bottomNavigationBar: buildBottomAppBar(),
      bottomNavigationBar: buildNavigationBar(),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: MyColors.white,
      //   child: Lottie.asset("assets/json/json_lixiang.json"),
      //   onPressed: () {
      //    Navigator.push(context, MaterialPageRoute(builder: (context) {
      //      return HabitListPage();
      //    }));
      //   },
      // ),floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  NavigationBar buildNavigationBar() {
    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      animationDuration: const Duration(seconds: 1),
      selectedIndex: currentIndexView,
      onDestinationSelected: (index) {
        setState(() {
          currentIndexView = index;
        });
      },
      backgroundColor: MyColors.white,
      destinations: const [
        NavigationDestination(
            icon: Icon(
              CupertinoIcons.home,
            ),
            label: "生活"),
        // NavigationDestination(
        //     icon: Icon(
        //       CupertinoIcons.home,
        //     ),
        //     label: "备份首页"),
        NavigationDestination(
            icon: Icon(
              CupertinoIcons.book,
            ),
            label: "日记"),
        NavigationDestination(
            icon: Icon(
              CupertinoIcons.archivebox,
            ),
            label: "修身"),
        NavigationDestination(
            icon: Icon(
              CupertinoIcons.table_badge_more,
            ),
            label: "发现"),

        NavigationDestination(
            icon: Icon(
              CupertinoIcons.settings,
            ),
            label: "我的"),
      ],
    );
  }

  BottomAppBar buildBottomAppBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(), // 必须设置，否则不会有 notch 缺口
      notchMargin: 6.0, // notch 缺口的边距
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(icon:  Icon(CupertinoIcons.home,color: MyColors.bluecolor), onPressed: () {setState(() {
            currentIndexView = 0;
          });}),
          IconButton(icon: const Icon(CupertinoIcons.book), onPressed: () {setState(() {
            currentIndexView = 1;
          });}),
          SizedBox(width: 48), // 为 FAB 预留空间（也可用 Spacer 组合）
          IconButton(icon: Icon(CupertinoIcons.archivebox), onPressed: () {setState(() {
            currentIndexView = 2;
          });}),
          IconButton(icon: Icon(CupertinoIcons.settings), onPressed: () {setState(() {
            currentIndexView = 3;
          });}),
        ],
      ),
    );
  }
}
