import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../stylesutil/res_urils.dart';
import '../bean/money.dart';
import '../bean/money_database.dart';
import '../tools/my_colors.dart';
import '../ui_notes/add_record_page.dart';
import '../widget/empty_view.dart';
import '../widget/router_pages.dart';

class NotesListPages extends StatefulWidget {
  @override
  State<NotesListPages> createState() => _NotesListPagesState();
}

class _NotesListPagesState extends State<NotesListPages> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  List<Money> dataList = []; //列表数据
  String year = DateTime.now().year.toString(); //
  String month = DateTime.now().month.toString(); //
  double inTotal = 0; //收入合计
  double outTotal = 0; //支出合计
  @override
  void initState() {
    super.initState();
    readFutureView(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColors.color_main,
        appBar: AppBar(
          title: const Text('我的记账'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, createRoute(const AddNotePage()))
                .then((value) => _refreshController.requestRefresh());
          },
          backgroundColor: MyColors.color_main,
          elevation: 0,
          child: SizedBox(
            width: 80,
            height: 80,
            child: Lottie.asset("assets/json/json_feijin.json"),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              "    Tips: 滑动删除，点击编辑",
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
            mainBodys()
          ],
        ));
  }

  mainBodys() {
    return Expanded(
      child: SmartRefresher(
        controller: _refreshController,
        header: const ClassicHeader(),
        enablePullDown: true,
        onRefresh: () {
          readFutureView(int.parse(year), int.parse(month));
        },
        child: dataList.isNotEmpty
            ? ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (ctx, index) {
                  return itemSanfuren(index);
                })
            : Center(
                child: OutlinedButton(
                onPressed: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (_) {
                    return const AddNotePage();
                  })).then((value) => _refreshController.requestRefresh());
                },
                child: EmptyView(
                  title: "暂无数据",
                ),
              )),
      ),
    );
  }

  //收支item
  Widget itemSanfuren(int index) {
    if (dataList[index].type == "0") {
      return buildJieQian(index, true, "ic_bk_zc");
    } else {
      return buildJieQian(index, false, "ic_bk_sr");
    }
  }

  Widget buildJieQian(int index, bool isout, String icname) {
    TextEditingController _counert = TextEditingController();
    return Slidable(
      key: const ValueKey(1),
      endActionPane: ActionPane(
        dismissible: DismissiblePane(onDismissed: () {
          var temp = dataList[index];
          delMoney(dataList[index].id);
          dataList.remove(temp);
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
              // setState(() {});
              // _refreshController.requestRefresh();
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
                      placeholder: "Please enter the amount",
                    ),
                    title: Text("Modify current data"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("cancel")),
                      TextButton(
                          onPressed: () {
                            Money mon = dataList[index];
                            mon.money = _counert.text;
                            updateFuture(mon);
                            Navigator.pop(context);
                          },
                          child: Text("ok")),
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

  Future readFutureView(int year, int month) async {
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

  Future updateFuture(Money money) async {
    await MoneyDatabase.instance.update(money);
    _refreshController.requestRefresh();
  }

  Future delMoney(int id) async {
    await MoneyDatabase.instance.delete(id);
    _refreshController.requestRefresh();
  }

  void addQians(Money money) {
    MoneyDatabase.instance.create(money);
    _refreshController.requestRefresh();
  }
}
