import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/tools/toast_utils.dart';

import '../stylesutil/show_style.dart';
import '../tools/style_utils.dart';
import 'CalendarPage.dart';
import 'CalenDetailPage.dart';
import 'ChangeMoneyPage.dart';

class MoreListTollsPage extends StatefulWidget {
  const MoreListTollsPage({Key? key}) : super(key: key);

  @override
  _MoreListTollsPageState createState() => _MoreListTollsPageState();
}

class _MoreListTollsPageState extends State<MoreListTollsPage> {
  List<String> newList = [  "Developing"];
  List<IconData> iconList = [
    Icons.more_horiz
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('尝鲜区'),
          centerTitle: true,
        ),
        body: initDataView(context));
  }

  initDataView(BuildContext context) {
    return Container(
      decoration:
          containBoxDecoration("assets/images/ic_splash_ho3.png"),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
            itemCount: newList.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (ctx, index) {
              return getSanfuren(context, index);
            }),
      ),
    );
    // return calculatePage();
  }

  getSanfuren(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        switch (index) {
          case 0:
            ToastUtil.showMyToast("敬请期待...");
            break;
          // case 2:
          //   Navigator.push(context, CupertinoPageRoute(builder: (ctx) {
          //     return ExchenageMoney();
          //   }));
            break;
          // case 3:
          //   Navigator.push(context, CupertinoPageRoute(builder: (ctx) {
          //     return YouXisView();
          //   }));
          //   break;
        }
      },
      child:
          BaseShots(iconData: iconList[index], iconName: newList[index]),
    );
  }
}
