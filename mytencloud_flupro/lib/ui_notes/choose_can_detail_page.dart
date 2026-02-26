import 'package:mytencloud_flupro/tools/style_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/localbean/ZhangdanBean.dart';
import 'package:mytencloud_flupro/tools/my_colors.dart';
import 'package:flutter/rendering.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../bean/money.dart';
import '../bean/money_database.dart';
import 'BillsDetailPage.dart';

class ChoseBillYearPage extends StatefulWidget {
  const ChoseBillYearPage({Key? key}) : super(key: key);

  @override
  _ChoseBillYearPageState createState() => _ChoseBillYearPageState();
}

class _ChoseBillYearPageState extends State<ChoseBillYearPage> {
  String year = "2025";
  List pickerChildren = [
    "2025",
    "2026",
    "2027",
  ];
  int selectedValue = 0;
  List<ZhangdanBean> zhangdanlist = [];
  double inYear = 0;
  double outYear = 0;

  @override
  void initState() {
    super.initState();
    readListAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('账单汇总'),
          centerTitle: true,
          actions: [
            TextButton(
              child: Text(
                "$year",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                _doDidVie();
              },
            )
          ],
        ),
        body: bodyView());
  }

  bodyView() {
    return Column(
      children: [
        gtLastTitle(),
        Divider(),
        TopGuanye(),
        Divider(),
        getDateList(),
      ],
    );
  }

  void _doDidVie() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          var controllr =
              FixedExtentScrollController(initialItem: selectedValue);
          return Container(
            // padding: EdgeInsets.all(10),
            height: 250,
            color: Colors.grey[200],
            child: Column(
              children: <Widget>[
                Container(
                  height: 40,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          year = pickerChildren[controllr.selectedItem];
                          readListAll();
                          Navigator.pop(context, controllr.selectedItem);
                        },
                        child: Text("ok"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                    ),
                    child: Container(
                      height: 200,
                      child: CupertinoPicker(
                        scrollController: controllr,
                        // diameterRatio: 1.5,
                        // offAxisFraction: 0.2, //轴偏离系数
                        // useMagnifier: true, //使用放大镜
                        // magnification: 1.5, //当前选中item放大倍数
                        itemExtent: 32, //行高
                        // backgroundColor: Colors.amber, //选中器背景色
                        onSelectedItemChanged: (value) {
                          selectedValue = value;
                          // print("value = $value, 性别：${pickerChildren[value]}");
                          // year = pickerChildren[value];
                          // readData();
                        },
                        children: pickerChildren.map((data) {
                          return Center(
                            child: Text(data),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).then((value) {
      if (value != selectedValue && value != null) {
        setState(() {
          selectedValue = value;
        });
      }
    });
  }

  gtLastTitle() {
    return Container(
      height: 120,
      color: MyColors.color_main,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("余额", style: styTxt()),
          const SizedBox(
            height: 8,
          ),
          Text((inYear - outYear).toStringAsFixed(2),
              style: TextStyle(fontSize: 24, color: Colors.white)),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("收入", style: styTxt()),
              const SizedBox(
                width: 5,
              ),
              Text(inYear.toStringAsFixed(2), style: txtStyleU()),
              const Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: SizedBox(
                  width: 1,
                  height: 20,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.grey),
                  ),
                ),
              ),
              Text("支出", style: styTxt()),
              const SizedBox(
                width: 5,
              ),
              Text(outYear.toStringAsFixed(2), style: txtStyleU()),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle styTxt() => const TextStyle(fontSize: 12, color: Colors.white);

  TextStyle txtStyleU() {
    return const TextStyle(
        fontSize: 22, color: Colors.white, fontStyle: FontStyle.italic);
  }

  RefreshController _myreflash = RefreshController();

  getDateList() {
    return Expanded(
      child: Container(
        decoration: containBoxDecoration("assets/icon/bg_bill.jpg",opact: 0.7),
        child: SmartRefresher(
            header: const ClassicHeader(),
            onRefresh: () {
              readListAll();
              _myreflash.refreshCompleted();
            },
            child: zhangdanlist.isNotEmpty
                ? ListView.builder(
                    itemCount: zhangdanlist.length,
                    itemBuilder: (_, index) {
                      return itemView(index);
                    })
                : const Center(
                    child: Text("No data available"),
                  ),
            controller: _myreflash),
      ),
    );
  }

  TopGuanye() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const <Widget>[
        Text("月"),
        Text("收入"),
        Text("支出"),
        Text("余额"),
      ],
    );
  }

  itemView(int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (ctx) {
          return BillPages(date: "$year:${zhangdanlist[index].date}");
        }));
      },
      child: Card(
        color: Colors.red[100],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.circular(10)),
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text("${zhangdanlist[index].date} M"),
              Text(
                  double.parse(zhangdanlist[index].inmoney).toStringAsFixed(2)),
              Text(double.parse(zhangdanlist[index].outmoney)
                  .toStringAsFixed(2)),
              Text(double.parse(zhangdanlist[index].remondmoney)
                  .toStringAsFixed(2)),
            ],
          ),
        ),
      ),
    );
  }

  Future readListAll() async {
    zhangdanlist.clear();
    List<Money> datalist = await MoneyDatabase.instance.readAllNotes();
    Set<String> set = Set();
    for (var value in datalist) {
      if (year == value.datetime.year.toString()) {
        set.add(value.datetime.month.toString());
      }
    }
    double outtotal = 0;
    double intotal = 0;
    //计算年度
    for (var value2 in datalist) {
      if (value2.datetime.year.toString() == year) {
        if (value2.type == "0") {
          outYear = outYear + double.parse(value2.money);
        } else {
          inYear = inYear + double.parse(value2.money);
        }
      } else {
        outYear = 0;
        inYear = 0;
      }
    }
    for (var value1 in set) {
      for (var value in datalist) {
        if (value.datetime.month.toString() == value1 &&
            value.datetime.year.toString() == year) {
          if (value.type == "0") {
            outtotal = outtotal + double.parse(value.money);
          } else {
            intotal = intotal + double.parse(value.money);
          }
        }
      }
      zhangdanlist.add(
          ZhangdanBean(value1, intotal.toString(), outtotal.toString(), "0"));
    }
    setState(() {});
    print("数据1${zhangdanlist.toString()}");
  }
}
