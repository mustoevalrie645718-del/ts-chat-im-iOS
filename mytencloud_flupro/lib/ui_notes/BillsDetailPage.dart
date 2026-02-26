import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

import '../bean/money.dart';
import '../bean/money_database.dart';
import '../stylesutil/SharedPreferenceUtil.dart';
import '../stylesutil/res_urils.dart';
import '../tools/my_colors.dart';

class BillPages extends StatefulWidget {
  String date = "dd";

  BillPages({required this.date});

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPages> {
  double pieData1 = 0;
  double pieData2 = 0;
  double pieData3 = 0;
  double totalMonet = 0;
  String username = "Tips for saving money";
  int indexLogo = 0;

  @override
  void initState() {
    super.initState();
    initNewData();
    readMoney(int.parse(widget.date.substring(0, 4)),
        int.parse(widget.date.substring(5)));
  }

  void initNewData() {
    SharedPreferenceUtil.getString("username").then((value) => {
          if (value != null) {username = value, setState(() {})}
        });
    SharedPreferenceUtil.getInt("logoindex").then((value) => {
          if (value != null) {indexLogo = value, setState(() {})}
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('详情'),
        centerTitle: true,
      ),
      body: Column(children: <Widget>[
        headViewp(),
        Text("支出统计"),
        SizedBox(
          height: 20,
        ),
        bodyView(),
        Divider(
          height: 10,
        ),
        selfStyle(),
        buildLiws()
      ]),
    );
  }

  headViewp() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.red[100],
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                width: 70,
                child: ClipRRect(
                  child: Image(
                    image: AssetImage(headList[indexLogo]),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(username),
                    Text(tufeiList[
                            Random().nextInt(tufeiList.length - 1)]
                        .substring(3)),
                    Text("这是您加入开源与节约的第一天")
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bodyView() {
    List<PieChartSectionData> list = [];
    if (totalMonet == 0) {
      list.add(PieChartSectionData(value: 100, color: Colors.red));
    } else {
      list.add(PieChartSectionData(
          value: double.parse((totalMonet == 0 ? 0 : pieData1 / totalMonet * 100)
              .toStringAsFixed(0)),
          color: Colors.red));
      list.add(PieChartSectionData(
          value: double.parse((totalMonet == 0 ? 0 : pieData2 / totalMonet * 100)
              .toStringAsFixed(0)),
          color: Colors.green));
      list.add(PieChartSectionData(
          value: double.parse((totalMonet == 0 ? 0 : pieData3 / totalMonet * 100)
              .toStringAsFixed(0)),
          color: Colors.blue));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: MyColors.color_main,
        shape: RoundedRectangleBorder(
            side: BorderSide.merge(
                BorderSide(color: Colors.red), BorderSide(color: Colors.red)),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: PieChart(
                  PieChartData(sections: list
                      // read about it in the PieChartData section
                      ),
                  swapAnimationDuration:
                      Duration(milliseconds: 150), // Optional
                  swapAnimationCurve: Curves.linear, // Optional
                ),
              ),
              toldTopView()
            ],
          ),
        ),
      ),
    );
  }

  toldTopView() {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text("支出分配", style: TextStyle(color: Colors.black, fontSize: 20)),
          Divider(
            height: 8,
          ),
          Text(
            "娱乐${pieData1.toStringAsFixed(2)}¥",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
          Divider(
            height: 2,
          ),
          Text(
            "学习${pieData2.toStringAsFixed(2)}¥",
            style: TextStyle(color: Colors.green, fontSize: 18),
          ),
          Divider(
            height: 2,
          ),
          Text(
            "生活${pieData3.toStringAsFixed(2)}¥",
            style: TextStyle(color: Colors.blue, fontSize: 18),
          )
        ],
      ),
    );
  }

  selfStyle() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Card(
          color: MyColors.color_main,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("这个月你达到预期目标了吗？给自己点赞！"),
          ),
        ),
      ),
    );
  }

  List<Money> dataList = []; //列表数据

  Future readMoney(int year, int month) async {
    dataList.clear();
    pieData1 = 0;
    pieData2 = 0;
    pieData3 = 0;
    totalMonet = 0;
    List<Money> alldata = []; //列表数据
    alldata = await MoneyDatabase.instance.readAllNotes();
    alldata.forEach((element) {
      if (element.datetime.year == year && element.datetime.month == month) {
        dataList.add(element);
      }
    });
    for (Money money in dataList) {
      totalMonet = totalMonet + double.parse(money.money);
      if (money.useway == "13") {
        //学习
        pieData1 = pieData1 + double.parse(money.money);
      } else if (money.useway == "9" || money.useway == "12") {
        //生活
        pieData2 = pieData2 + double.parse(money.money);
      } else {
        //娱乐
        pieData3 = pieData3 + double.parse(money.money);
      }
    }
    setState(() {});
  }

  buildLiws() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 100,
        alignment: Alignment.centerRight,
        child: LikeButton(
            size: 50,
            circleColor: const CircleColor(
                start: Color(0xff00ddff), end: Color(0xff0099cc)),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Color(0xff33b5e5),
              dotSecondaryColor: Color(0xff0099cc),
            ),
            likeBuilder: (bool isLiked) {
              return Icon(
                CupertinoIcons.heart,
                color: isLiked ? Colors.deepPurpleAccent : Colors.grey,
                size: 20,
              );
            },
            likeCount: 1,
            countBuilder: (count, isLiked, text) {
              var color = isLiked ? Colors.deepPurpleAccent : Colors.grey;
              Widget result;
              if (count == 0) {
                result = Text(
                  "",
                  style: TextStyle(color: color),
                );
              } else {
                result = Text(
                  "",
                  style: TextStyle(color: color),
                );
              }
              return result;
            }),
      ),
    );
  }
}
