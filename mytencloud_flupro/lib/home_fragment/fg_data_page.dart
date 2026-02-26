import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../bean/library_database.dart';
import '../bean/librarydata.dart';
import '../bean/money.dart';
import '../bean/money_database.dart';
import '../tools/my_colors.dart';
import '../tools/style_utils.dart';
import '../ui_notes/add_record_page.dart';
import '../stylesutil/SharedPreferenceUtil.dart';
import '../stylesutil/res_urils.dart';
import '../viewpages/KisterFilePage.dart';
import '../viewpages/TipsDetail.dart';
import '../viewpages/IPThingsPage.dart';

//数据
class ShuJuPage extends StatefulWidget {
  const ShuJuPage({Key? key}) : super(key: key);

  @override
  State<ShuJuPage> createState() => _ShuJuPageState();
}

class _ShuJuPageState extends State<ShuJuPage>
    with SingleTickerProviderStateMixin {
  RefreshController mycountrak = RefreshController();
  var touchedIndex = 1;
  List<Color> KkxnewColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];
  double per1 = 0;
  var enable = false;
  var list = <PieChartSectionData>[];
  double per2 = 0.0;
  var wordLength = 0;
  double per3 = 0.0;
  double inTotal = 0; //
  double outTotal = 0;
  double per4 = 0.0;
  var dataList = <Library>[];
  List<Money> DataList = []; //列表数据
  var flowViews = <FlSpot>[];
  var countral;
  final _myReflash = RefreshController();
  var preFils = 1000.0;
  double yiJian = 0;
  double shiJIan = 0;
  double zhuBei = 0;
  double xingSates = 0;

  double dianZi = 0;
  double huLue = 0;
  double tiMian = 0;
  double manMan = 0;
  var huoYIng = <PieChartSectionData>[];
  var currentStues = 0;

  @override
  void initState() {
    super.initState();
    GetPieData();
    countral = TabController(length: 2, vsync: this);
    futureList(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("数据分析"),
          actions: [
            IconButton(
              icon: const Icon(Icons.swap_horiz_outlined),
              onPressed: () {
                setState(() {
                  countral.animateTo(countral.index == 0 ? 1 : 0);
                });
              },
            ),
          ],
        ),

        body:
        // body: currentStues == 0 ? initData() : FasongLiset(),
        TabBarView(
          controller: countral,
          children: [FasongLiset(),initData()
          ],
        )
        );
  }

  initData() {
    return SmartRefresher(
      header: CustomHeader(
        builder: (ctx, model) {
          return Center(
            child: SizedBox(
              height: 50,
              child: Lottie.asset("assets/json/json_xiayibo.json"),
            ),
          );
        },
      ),
      onRefresh: () {
        GetPieData();
      },
      controller: mycountrak,
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: containBoxDecoration("assets/images/bg_first_sp3.jpg"),
        child: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(
              height: 20,
            ),
            PieView('心情统计'),
            PieCharDws(),
            PieView('数据分析'),
            buildListView(),
            const SizedBox(
              height: 20,
            ),
          ]),
        ),
      ),
    );
  }

  Widget buildHeadView() {
    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        // 配置宽高比
        aspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.width / 6 * 5),
        child: Swiper(
          indicatorLayout: PageIndicatorLayout.SCALE,
          itemBuilder: (BuildContext context, int index) {
            // 配置图片地址
            return 0 == index
                ? dataList.isEmpty
                    ? initdates()
                    : PieCharDws1()
                : SizedBox(
                    height: 300,
                    child: Card(
                        shape: buildborder(),
                        color: Colors.blue[50],
                        child: MyTipPages()));
          },
          // 配置图片数量
          itemCount: 2,
          // 底部分页器
          pagination: const SwiperPagination(),
          // 左右箭头
          control: SwiperControl(),
          // 无限循环
          loop: true,
          // 自动轮播
          autoplay: true,
        ),
      ),
    );
  }

  RoundedRectangleBorder buildborder() {
    return const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(100),
            topRight: Radius.circular(100),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)));
  }

  //饼状图
  PieView(String txt) {
    return Text(
      txt,
      style: const TextStyle(
          fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
    );
  }

  Widget PieCharDws1() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: buildborder(),
        color: Colors.blue[50],
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            AspectRatio(
              aspectRatio: 1.8,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(
                      height: 18,
                      width: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = 0;
                                return;
                              } else {
                                touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex!;
                                if (enable) {
                                  GetPieData();
                                }
                                enable = false;
                                Future.delayed(Duration(seconds: 1), () {
                                  enable = true;
                                });
                              }
                            }),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: list,
                            // read about it in the PieChartData section
                          ),
                          swapAnimationDuration:
                              Duration(milliseconds: 150), // Optional
                          swapAnimationCurve: Curves.linear, // Optional
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                      width: 30,
                    ),
                  ]),
            ),
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 30,
                ),
                KissViewPage(
                  color: MyColors.color_main,
                  myiconData: Icons.hail,
                  text: dataList.isEmpty
                      ? "HAPPY 0"
                      : '${'HAPPY   '}${(per1 / (dataList.length) * 100).toStringAsFixed(0)}%',
                  isSquare: true,
                ),
                Spacer(),
                KissViewPage(
                  color: Color(0xfff8b250),
                  myiconData: Icons.ac_unit_sharp,
                  text: dataList.isEmpty
                      ? "ANG 0"
                      : '${'ANG   '}${(per2 / dataList.length * 100).toStringAsFixed(0)}%',
                  isSquare: true,
                ),
                const SizedBox(
                  width: 30,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 30,
                ),
                KissViewPage(
                  color: Color(0xff845bef),
                  myiconData: Icons.accessible,
                  text: dataList.isEmpty
                      ? "SAD 0"
                      : '${'SAD   '}${(per3 / dataList.length * 100).toStringAsFixed(0)}%',
                  isSquare: true,
                ),
                Spacer(),
                KissViewPage(
                  color: Color(0xff13d38e),
                  myiconData: Icons.catching_pokemon,
                  text: dataList.isEmpty
                      ? "FEER 0"
                      : '${'FEER   '}${(per4 / dataList.length * 100).toStringAsFixed(0)}%',
                  isSquare: true,
                ),
                const SizedBox(
                  width: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget PieCharDws() {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      height: 200,
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              margin: const EdgeInsets.only(left: 30.0),
              width: 80,
              height: 80,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = 0;
                      return;
                    } else {
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex!;
                      if (enable) {
                        GetPieData();
                      }
                      enable = false;
                      Future.delayed(Duration(seconds: 1), () {
                        enable = true;
                      });
                    }
                  }),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: list,
                  // read about it in the PieChartData section
                ),
                swapAnimationDuration: Duration(milliseconds: 150), // Optional
                swapAnimationCurve: Curves.linear, // Optional
              ),
            ),
          ),
          const SizedBox(
            width: 50,
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Spacer(),
                KissViewPage(
                  color: MyColors.color_main,
                  myiconData: Icons.hail,
                  text: dataList.isEmpty
                      ? "HAPPY 0"
                      : '${'HAPPY   '}${(per1 / (dataList.length) * 100).toStringAsFixed(0)}%',
                  isSquare: true,
                ),
                KissViewPage(
                  color: Color(0xfff8b250),
                  myiconData: Icons.ac_unit_sharp,
                  text: dataList.isEmpty
                      ? "ANG 0"
                      : '${'ANG   '}${(per2 / dataList.length * 100).toStringAsFixed(0)}%',
                  isSquare: true,
                ),
                KissViewPage(
                  color: Color(0xff845bef),
                  myiconData: Icons.accessible,
                  text: dataList.isEmpty
                      ? "SAD 0"
                      : '${'SAD   '}${(per3 / dataList.length * 100).toStringAsFixed(0)}%',
                  isSquare: true,
                ),
                KissViewPage(
                  color: Color(0xff13d38e),
                  myiconData: Icons.catching_pokemon,
                  text: dataList.isEmpty
                      ? "FEER 0"
                      : '${'FEER   '}${(per4 / dataList.length * 100).toStringAsFixed(0)}%',
                  isSquare: true,
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: buildborder(),
        color: Colors.blue[50],
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void GetPieData() async {
    per1 = 0;
    per2 = 0;
    per3 = 0;
    per4 = 0;
    wordLength = 0;
    dataList = await LibraryDatabase.instance.readAllNotes();
    for (var value1 in dataList) {
      if (value1.facemotion == "0" || value1.facemotion == "1") {
        per1++;
      }
      if (value1.facemotion == "2" || value1.facemotion == "3") {
        per2++;
      }
      if (value1.facemotion == "4" || value1.facemotion == "5") {
        per3++;
      }
      if (value1.facemotion == "6" || value1.facemotion == "7") {
        per4++;
      }
      wordLength = wordLength + value1.maincontain.length;
    }
    //饼状图数据初始化
    list = List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: MyColors.color_main,
            value: per1 / dataList.length,
            title: 'HAPPY',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.yellow,
            value: per2 / dataList.length,
            title: 'ANG',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: per3 / dataList.length,
            title: 'SAD',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: per4 / dataList.length,
            title: 'FEER',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });

    // 曲线数据初始化
    int i = 0;
    flowViews.clear();
    while (i < 12) {
      flowViews.add(FlSpot(i.toDouble(), 0));
      i++;
    }
    for (var value2 in dataList) {
      for (var value1 in flowViews) {
        if (value2.datetime.month.toDouble() == value1.x) {
          var temp = flowViews[flowViews.indexOf(value1)].y + 1;
          flowViews[flowViews.indexOf(value1)] = FlSpot(value1.x, temp);
        }
      }
    }
    setState(() {});
    mycountrak.refreshCompleted();
  }

  void GetCharData(Library library) {
    LibraryDatabase.instance.create(library);
  }

  Widget buildListView() {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
            color: MyColors.color_main,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(50)),
        height: 200,
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      "您已经记录${wordLength}字，已经初步养成记录生活的好习惯"),
                  Text("仍然需要继续努力！"),
                  const Divider(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text(buildList[Random().nextInt(buildList.length - 1)]),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              width: 100,
              child: Lottie.asset("assets/json/json_xiayibo.json"),
            ),
          ],
        ),
      ),
    );
  }

  List<String> buildList = [
    "I will be with you, year after year, until it becomes old song and legend",
    "Roads are for people, people are for people",
    "You have to catch yourself and let others brag.",
  ];

  //曲线图
  Widget BuildLineList() {
    const cutOffYValue = 5.0;
    return AspectRatio(
      aspectRatio: 16 / 14,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 20),
            child: Column(
              children: <Widget>[
                const Text("Monthly analysis"),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      backgroundColor: Colors.red[50],
                      lineTouchData: LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: flowViews,
                          //数据
                          isCurved: true,
                          barWidth: 2,
                          //曲线宽度
                          color: Colors.blue,
                          //曲线颜色
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.deepPurple.withOpacity(0.4),
                            cutOffY: cutOffYValue,
                            applyCutOffY: true,
                          ),
                          aboveBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                            cutOffY: cutOffYValue,
                            applyCutOffY: true,
                          ),
                          dotData: FlDotData(
                            show: true, //是否开启数据点
                          ),
                        ),
                      ],
                      minY: 0,
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: const Text(
                            '2023',
                            style: _dateTextStyle,
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 18,
                            interval: 1,
                            getTitlesWidget: secondview,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          axisNameSize: 20,
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 40,
                            getTitlesWidget: buldgridview,
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        drawHorizontalLine: true,
                        horizontalInterval: 1,
                        checkToShowHorizontalLine: (double value) {
                          return value == 1 ||
                              value == 6 ||
                              value == 4 ||
                              value == 5;
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _dateTextStyle = TextStyle(
    fontSize: 10,
    color: Colors.blueAccent,
    fontWeight: FontWeight.normal,
  );

  Widget secondview(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      case 4:
        text = 'May';
        break;
      case 5:
        text = 'Jun';
        break;
      case 6:
        text = 'Jul';
        break;
      case 7:
        text = 'Aug';
        break;
      case 8:
        text = 'Sep';
        break;
      case 9:
        text = 'Oct';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dec';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: _dateTextStyle),
    );
  }

  Widget buldgridview(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.black, fontSize: 12.0);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('${value + 1}', style: style),
    );
  }

  initdates() {
    return InkWell(
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (ctx) {
          return IpThingPage("", "");
        })).then((value) => GetPieData());
      },
      child: SizedBox(
        height: 100,
        width: 100,
        child: Lottie.asset("assets/json/json_feijin.json"),
      ),
    );
  }

  FasongLiset() {
    return Container(
      decoration:
          containBoxDecoration("assets/images/bg_first_sp5.png", opact: 0.5),
      child: Column(
        children: <Widget>[
          BuildLineList(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const <Widget>[
                Text("--Y--:"),
                Text("记录数量"),
                Text("--X--:"),
                Text("月份"),
              ],
            ),
          ),
          //新增名言随机

        ],
      ),
    );
  }

//
  ldwfD() {
    return Expanded(
      child: dataList.isNotEmpty
          ? SmartRefresher(
              onRefresh: () {
                GetPieData();
                _myReflash.refreshCompleted();
              },
              controller: _myReflash,
              child: ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (ctx, index) {
                    return TxtImgItem(index);
                  }),
            )
          : Center(
              child: OutlinedButton(
              onPressed: () {
                Navigator.push(context, CupertinoPageRoute(builder: (_) {
                  return  AddNotePage();
                }));
              },
              child: const Text(
                "暂无数据,点击添加",
                style: TextStyle(fontSize: 20),
              ),
            )),
    );
  }

  //收支item
  Widget TxtImgItem(int index) {
    var data = dataList[index];
    return Column(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            shape: BoxShape.rectangle,
          ),
          child: Center(
            child: ListTile(
              dense: true,
              title: Text(
                data.title,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              subtitle: Text(data.useway),
              leading: Image(
                width: 30,
                height: 30,
                image: AssetImage(headList[index % 7]),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "\$${data.amount}",
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  Text(
                    data.createtime.toString().substring(0, 10),
                    style: const TextStyle(
                        color: Colors.greenAccent, fontSize: 11),
                  )
                ],
              ),
            ),
          ),
        ),
        const Divider(
          height: 1,
        )
      ],
    );
  }

  Future futureList(int year, int month) async {
    print("当前年$year当前月$month");
    preFils = (await SharedPreferenceUtil.getDouble("totalpremoney"))!;
    if (preFils == 0) {
      preFils = 1000;
    }
    DataList.clear();
    List<Money> alldata = []; //列表数据
    alldata = await MoneyDatabase.instance.readAllNotes();
    alldata.forEach((element) {
      if (element.datetime.year == year && element.datetime.month == month) {
        DataList.add(element);
      }
    });
    DataList.sort((a, b) {
      return b.datetime!.isAfter(a.datetime!) ? 1 : -1;
    });
    for (var value in DataList) {
      if (value.datetime!.year == year && value.datetime.month! == month) {
        //当月
        if (value.type == "0") {
          //支出
          outTotal = double.parse(value.money!) + outTotal;
          if (value.useway!.contains("9")) {
            yiJian = double.parse(value.money!) + yiJian;
          }
          if (value.useway!.contains("0") ||
              value.useway!.contains("6") ||
              value.useway!.contains("4") ||
              value.useway!.contains("5")) {
            shiJIan = double.parse(value.money!) + shiJIan;
          }
          if (value.useway!.contains("3")) {
            zhuBei = double.parse(value.money!) + zhuBei;
          }
          if (value.useway!.contains("2")) {
            xingSates = double.parse(value.money!) + xingSates;
          }
        } else {
          //收入
          inTotal = double.parse(value.money) + inTotal;
        }
      }
    }
// 数据汇总数据

    dianZi = 0;
    huLue = 0;
    tiMian = 0;
    manMan = 0;

    for (var value1 in DataList) {
      if (value1.useway == "9") {
        dianZi++;
      }
      if (value1.useway == "5" || value1.useway == "6") {
        huLue++;
      }
      if (value1.useway == "3") {
        tiMian++;
      }
      if (value1.useway == "2" || value1.useway == "8") {
        manMan++;
      }
    }
    //饼状图数据初始化
    huoYIng = List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: MyColors.color_main,
            value: dianZi / DataList.length,
            title: '衣',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.yellow,
            value: huLue / DataList.length,
            title: '食',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: tiMian / DataList.length,
            title: '住',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: manMan / DataList.length,
            title: '行',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });
    setState(() {});
  }

  thirdLis() {
    return SingleChildScrollView(
      child: Container(
        color: MyColors.color_databg,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Card(
                color: MyColors.color_databg,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "当月预算汇总",
                        style: textSty(),
                      ),
                      ListTile(
                        title: Text("预算金额", style: textSty()),
                        trailing: Text("${preFils}", style: textSty()),
                      ),
                      ListTile(
                        title: Text("实际金额", style: textSty()),
                        trailing: Text("¥${outTotal}", style: textSty()),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(30)),
                        child: LinearProgressIndicator(
                          value: (outTotal / preFils).toDouble(),
                          backgroundColor: Colors.grey,
                          color: MyColors.color_main,
                          minHeight: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                height: 20,
              ),
              const Divider(
                height: 20,
                color: Colors.white,
              ),
              Text(
                "类目统计",
                style: textSty(),
              ),
              RuleBase(),
              const Divider(
                height: 20,
                color: Colors.white,
              ),
              Text(
                "图形分析",
                style: textSty(),
              ),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Card(
                  color: MyColors.color_databg,
                  child: Container(child: goList()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget goList() {
    return list.isEmpty
        ? const Center(
            child: Text(
              "暂无数据",
              style: TextStyle(color: Colors.white),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 30,
                height: 30,
                child: Padding(
                  padding: const EdgeInsets.only(left: 120.0),
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(touchCallback:
                          (FlTouchEvent event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = 0;
                          return;
                        } else {
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex!;
                          if (enable) {
                            GetPieData();
                          }
                          enable = false;
                          Future.delayed(Duration(seconds: 1), () {
                            enable = true;
                          });
                        }
                      }),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 20,
                      sections: huoYIng,
                      // read about it in the PieChartData section
                    ),
                    swapAnimationDuration:
                        const Duration(milliseconds: 150), // Optional
                    swapAnimationCurve: Curves.linear, // Optional
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "记录标题类型",
                      style:
                          TextStyle(fontSize: 18, color: MyColors.color_main),
                    ),
                    const Divider(
                      height: 20,
                    ),
                    JiangNIng("衣", MyColors.color_main),
                    JiangNIng("食", Colors.orange),
                    JiangNIng("住", Colors.purple),
                    JiangNIng("行", Colors.green),
                  ],
                ),
              ),
            ],
          );
  }

  Widget JiangNIng(String txt, Color color) {
    return Row(
      children: <Widget>[
        Icon(Icons.star, color: color),
        Text(
          txt,
          style: textSty(),
        )
      ],
    );
  }

  TextStyle textSty() => const TextStyle(color: Colors.white);

  RuleBase() {
    print("yinumas${yiJian}");
    return Column(
      children: <Widget>[
        StylePadding(yiJian / preFils, KkxnewColors[0], "衣服"),
        StylePadding(shiJIan / preFils, KkxnewColors[1], "食物"),
        StylePadding(zhuBei / preFils, KkxnewColors[2], "住宿"),
        StylePadding(xingSates / preFils, KkxnewColors[3], "交通"),
      ],
    );
  }

  Padding StylePadding(double value, Color color, String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                LinearProgressIndicator(
                  value: value,
                  backgroundColor: MyColors.color_databg,
                  color: color,
                  minHeight: 40,
                ),
                Positioned(
                  height: 40,
                  right: 100,
                  child: Center(
                      child: Text(
                    "${(value * 100).toStringAsFixed(2)}%",
                    style: textSty(),
                  )),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            title,
            style: textSty(),
          )
        ],
      ),
    );
  }
}
