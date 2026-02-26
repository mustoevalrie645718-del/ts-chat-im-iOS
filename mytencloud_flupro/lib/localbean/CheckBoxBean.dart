import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/stylesutil/constfinal.dart';
import 'package:mytencloud_flupro/localbean/CcmtvBean.dart';
import 'package:mytencloud_flupro/tools/my_colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../viewpages/IPThingsPage.dart';
import '../viewpages/WebViewPage.dart';
import '../stylesutil/res_urils.dart';
import '../bean/library_database.dart';
import '../bean/librarydata.dart';
import '../bean/money.dart';
import '../bean/money_database.dart';
import '../ui_notes/add_record_page.dart';
import 'MaShangBean.dart';

class Check_home extends StatefulWidget {
  const Check_home({Key? key}) : super(key: key);

  @override
  State<Check_home> createState() => _Check_homeState();
}

class _Check_homeState extends State<Check_home>
    with SingleTickerProviderStateMixin {
  List tabdataList = [
    "Self-service declaration",
    "Survey Questionnaire",
    "CAL（for CN）"
  ];
  List<Money> dataList = []; //列表数据

  List ulListWindgets = [
    "https://csyun.ccmtv.cn/admin.php/gsfy/home/Integral/index?suffix=oQlGqvYuWbx/BkmZYXmCtCdrDAX/ZYw",
    "https://csyun.ccmtv.cn/admin.php/wx/Quesnaire/index?suffix=oQlGqvYuWbx/BkmZYXmCtCdrDAX/ZYw",
    "https://csyun.ccmtv.cn/admin.php/wx/Myrili/index?suffix=oQlGqvYuWbx/BkmZYXmCtCdrDAX/ZYw"
  ];
  final dio = Dio();
  List<SomeRootEntityDataDataList> msdatalist =[];
  late TabController _tabController;
  double inTotal = 0; //收入合计
  double outTotal = 0; //支出合计
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  String year = DateTime.now().year.toString(); //
  String month = DateTime.now().month.toString(); //
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      print("当前${_tabController.index}");
      setState(() {});
    });
    getQingchun();
    readCheck(DateTime.now().year, DateTime.now().month);
    GetPieData();
  }

  void GetPieData() async {
    libdataList = await LibraryDatabase.instance.readAllNotes();
    setState(() {});
  }
  Future<int> delete(int id) async {
    int resid = await LibraryDatabase.instance.delete(id);
    setState(() {

    });
    return resid;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mainViews(),
      floatingActionButton: Visibility(
        visible: 1 == _tabController.index,
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, CupertinoPageRoute(builder: (_) {
              return IpThingPage("", "",);
            }));
          },
        ),
      ),
    );
  }

  void getQingchun() async {
    var data =
        "ZXlKaFkzUWlPaUpuWlhSTlpXUnBZMkZzVTJOaGJHVnpUR2x6ZENJc0luRjFaWEo1SWpvaUlpd2ljR0ZuWlNJNk1Td2ljMmw2WlNJNgpJakl3SWl3aWMyaHZkMTlqYUdGdWJtVnNJam9pTWlJc0luTnZjblFpT2lJaUxDSnJaWE5vYVNJNklpSjkK";
    var datacheck =
        "ZXlKMWMyVnlRV05qYjNWdWRDSTZJbmhvTWlJc0luQmhjM04zYjNKa0lqb2lNVEl6TkRVMklpd2lj"
        "MjkxY21ObFpteGhaeUk2SW1GagpZMjkxYm5SZmJHOW5hVzRpTENKdGIySndhRzl1WlNJNklqRTNO"
        "VEl4TXpFMU1qRXhJaXdpYzI5MWNtTmxJam9pUVc1a2NtOXBaQ0lzCkluWmxjbk5wYjI0aU9pSTFM"
        "akl1T1NJc0ltMXZaR1ZzSWpvaVNGVkJWMFZKVEVsUExVRk9NREFpTENKemVYTjBaVzEyWlhKemFX"
        "OXUKSWpvaU1USWlmUT09Cg==";
    FormData formData = FormData.fromMap({
      "data": data,
      "datacheck": datacheck,
    });
    var userData = await dio.post(
      ConstSlwFinal.BASE_URL,
      data: formData,
    );

    var jsons = utf8.decode(base64Decode(userData.data.toString()));
    var jsonss = utf8.decode(base64Decode(jsons));
    SomeRootEntity bean = SomeRootEntity.fromJson(jsonDecode(jsonss));
    print("卡卡西jsons${bean.data.data.list[0].title}");
    msdatalist = bean.data.data.list;
    setState(() {});
  }

  mainViews() {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage("assets/images/ic_splash_ho3.png"))),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true, // 设置吸顶
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('WORK'),
              background: Image.network(
                'https://picsum.photos/250?image=9',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 40,
              child: TabBar(controller: _tabController, tabs: const [
                Tab(
                    child:
                        Text("Notes", style: TextStyle(color: Colors.black))),
                Tab(
                    child: Text("Workbench",
                        style: TextStyle(color: Colors.black))),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 1300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  mainLiejiu(),
                  sendLoves()
                  // bodyWidget,
                  // msGEt,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  mainLiejiu() {
    return Expanded(
      child: SmartRefresher(
        controller: _refreshController,
        header: const ClassicHeader(),
        enablePullDown: true,
        onRefresh: () {
          readCheck(int.parse(year), int.parse(month));
        },
        child: dataList.isNotEmpty
            ? ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (ctx, index) {
                  return itemShHomsHosswa(index);
                })
            : Center(
                child: OutlinedButton(
                onPressed: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (_) {
                    return  AddNotePage();
                  })).then((value) => _refreshController.requestRefresh());
                },
                child: const Text(
                  "暂无数据,点击添加",
                  style: TextStyle(fontSize: 20),
                ),
              )),
      ),
    );
  }

  Future readCheck(int year, int month) async {
    print("当前年$year当前月$month");
    dataList.clear();
    List<Money> alldata = []; //列表数据
    alldata = await MoneyDatabase.instance.readAllNotes();
    alldata.forEach((element) {
      if (element.datetime.year == year && element.datetime.month == month) {
        dataList.add(element);
      }
    });
    dataList.sort((a, b) {
      return b.datetime.isAfter(a.datetime) ? 1 : -1;
    });
    setState(() {});
    _refreshController.refreshCompleted();
    outTotal = 0;
    inTotal = 0;
    for (var value in dataList) {
      if (value.datetime.year == year && value.datetime.month == month) {
        //当月
        if (value.type == "0") {
          //支出
          outTotal = double.parse(value.money) + outTotal;
        } else {
          //收入
          inTotal = double.parse(value.money) + inTotal;
        }
      }
    }
  }

  //收支item
  Widget itemShHomsHosswa(int index) {
    if (dataList[index].type == "0") {
      return buildMontaim(index, true, "ic_bk_zc");
    } else {
      return buildMontaim(index, false, "ic_bk_sr");
    }
  }

  Widget buildTexcomlum(int index, bool isout, String icname) {
    TextEditingController _counert = TextEditingController();
    return Card(
      color: Colors.white,
      child: Dismissible(
        background: Text("background"),
        crossAxisEndOffset: 0.0,
        secondaryBackground: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "删除",
                style: TextStyle(color: Colors.red),
              )),
        ),
        key: Key(dataList[index].id.toString()),
        direction: DismissDirection.endToStart,
        dismissThresholds: {
          DismissDirection.startToEnd: 0.8,
          DismissDirection.endToStart: 0.3
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            //左滑删除
            var temp = dataList[index];
            delMoney(dataList[index].id);
            dataList.remove(temp);
            setState(() {});
            _refreshController.requestRefresh();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("删除成功"),
              action: SnackBarAction(
                onPressed: () {
                  addMoney(temp);
                },
                label: '撤销',
              ),
            ));
          }
        },
        child: Card(
          color: Colors.blue[100],
          child: ListTile(
            onTap: () {
              _counert.text = dataList[index].money;
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return CupertinoAlertDialog(
                      content: CupertinoTextField(
                        keyboardType: TextInputType.number,
                        controller: _counert,
                        placeholder: "请输入金额",
                      ),
                      title: Text("Modify current data"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("取消")),
                        TextButton(
                            onPressed: () {
                              Money mon = dataList[index];
                              mon.money = _counert.text;
                              updateMoney(mon);
                              Navigator.pop(context);
                            },
                            child: Text("确定")),
                      ],
                    );
                  });
            },
            title: Text(isout
                ? outName[int.parse(dataList[index].useway.toString())]
                : inName[int.parse(dataList[index].useway.toString())]),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image(
                image: AssetImage(
                    "images/choice/$icname${int.parse(dataList[index].useway.toString()) + 1}.png"),
                color: isout ? Colors.red[200] : Colors.green[200],
              ),
            ),
            trailing: Text("${isout ? "-" : "+"}${dataList[index].money}¥"),
          ),
        ),
      ),
    );
  }

  Widget buildMontaim(int index, bool isout, String icname) {
    TextEditingController _counert = TextEditingController();
    return Slidable(
      key: const ValueKey(0),
      endActionPane: ActionPane(
        dismissible: DismissiblePane(onDismissed: () {
          var temp = dataList[index];
          delMoney(dataList[index].id);
          dataList.remove(temp);
          setState(() {});
          _refreshController.requestRefresh();
        }),
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            borderRadius: BorderRadius.circular(10),
            flex: 2,
            backgroundColor: const Color(0xFFFF0000),
            foregroundColor: Colors.white,
            icon: CupertinoIcons.delete,
            label: '删除',
            onPressed: (BuildContext context) {
              var temp = dataList[index];
              delMoney(dataList[index].id);
              dataList.remove(temp);
              setState(() {});
              _refreshController.requestRefresh();
            },
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.blueAccent[50],
        child: ListTile(
          onTap: () {
            _counert.text = dataList[index].money;
            showDialog(
                context: context,
                builder: (ctx) {
                  return CupertinoAlertDialog(
                    content: CupertinoTextField(
                      keyboardType: TextInputType.number,
                      controller: _counert,
                      placeholder: "请输入金额",
                    ),
                    title: Text("Modify current data"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("取消")),
                      TextButton(
                          onPressed: () {
                            Money mon = dataList[index];
                            mon.money = _counert.text;
                            updateMoney(mon);
                            Navigator.pop(context);
                          },
                          child: Text("确定")),
                    ],
                  );
                });
          },
          subtitle: Text(dataList[index].datetime.toString().substring(0, 10)),
          title: Text(isout
              ? outName[int.parse(dataList[index].useway.toString())]
              : inName[int.parse(dataList[index].useway.toString())]),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image(
              image: AssetImage(
                  "assets/images/choice/$icname${int.parse(dataList[index].useway.toString()) + 1}.png"),
              color: isout ? Colors.red[200] : Colors.green[200],
            ),
          ),
          trailing: Text("${isout ? "-" : "+"}${dataList[index].money}¥"),
        ),
      ),
    );
  }

  Future delMoney(int id) async {
    print("删除$id");
    await MoneyDatabase.instance.delete(id);
    _refreshController.requestRefresh();
  }

  void addMoney(Money money) {
    print("新增${money.id}");
    MoneyDatabase.instance.create(money);
    _refreshController.requestRefresh();
  }

  Future updateMoney(Money money) async {
    await MoneyDatabase.instance.update(money);
    _refreshController.requestRefresh();
  }

  get msGEt => Container(
        height: 1300,
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: msdatalist
              .map((e) => Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: container(e),
                  ))
              .toList(),
        ),
      );

  Widget container(SomeRootEntityDataDataList e) {
    return Container(
      color: MyColors.bluecolor,
      child: ListTile(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (ctx) {
            return LiangbiaoDetail(e.id);
          }));
        },
        title: Text(e.title),
        subtitle: Text(e.developTime),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Icon(Icons.star), Text(e.hits)],
          ),
        ),
      ),
    );
  }

  final _myReflash = RefreshController();
  var libdataList = <Library>[];

  sendLoves() {
    return Expanded(
      child: libdataList.isNotEmpty
          ? SmartRefresher(
              onRefresh: () {
                GetPieData();
                _myReflash.refreshCompleted();
              },
              controller: _myReflash,
              child: ListView.builder(
                  itemCount: libdataList.length,
                  itemBuilder: (ctx, index) {
                    return itemTextimg(index);
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
                "No data yet, click to add",
                style: TextStyle(fontSize: 20),
              ),
            )),
    );
  }

  Widget itemTextimg(int index) {
    var data = libdataList[index];
    return Column(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            shape: BoxShape.rectangle,
          ),
          child: Center(
            child: ListTile(
              onLongPress: (){
                //弹窗确认
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return CupertinoAlertDialog(
                        title: Text("Confirm to delete the current data"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("CANCEL")),
                          TextButton(
                              onPressed: () {
                                delete(data.id);
                                _myReflash.requestRefresh();
                                Navigator.pop(context);
                              },
                              child: Text("OK")),
                        ],
                      );
                    });
              },
              dense: true,
              title: Text(
                data.title,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              subtitle: Text(data.useway),
              leading: Image(
                width: 30,
                height: 30,
                image: AssetImage(iconFaceList[index % 7]),
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

  get bodyWidget => SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: initWideg(),
        ),
      );

  List<Widget> initWideg() {
    return tabdataList
        .map((e) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  posttianya(ulListWindgets[tabdataList.indexOf(e)]);
                },
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        shape: BoxShape.rectangle,
                        color: Color(0xE6FFFFFF)),
                    width: 100,
                    height: 100,
                    child: Center(child: Text(e))),
              ),
            ))
        .toList();
  }

  void posttianya(String url) {
    // jumpToAndroidMethod(url, "android");
    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      return WebViewPages(url);
    }));
  }
}
