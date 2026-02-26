import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/tools/my_colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../bean/library_database.dart';
import '../bean/librarydata.dart';
import '../stylesutil/res_urils.dart';
import '../tools/style_utils.dart';
import '../viewpages/IPThingsPage.dart';

class ReadFragment extends StatefulWidget {
  const ReadFragment({Key? key}) : super(key: key);

  @override
  _ReadFragmentState createState() => _ReadFragmentState();
}

class _ReadFragmentState extends State<ReadFragment> {
  var dataList = <Library>[];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    buildZhenAi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('重要事件'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (_) {
                    return IpThingPage("", "");
                  })).then((value) => buildZhenAi());
                },
                icon: Icon(Icons.add))
          ],
        ),
        body: JiuNIanShiaguan());
  }

  Future<int> delete(int id) async {
    int resid = await LibraryDatabase.instance.delete(id);
    return resid;
  }

  void buildZhenAi() async {
    dataList = await LibraryDatabase.instance.readAllNotes();
    print("数据${dataList.length}");
    _refreshController.refreshCompleted();
    setState(() {});
  }

  void laoGeng(Library library) {
    LibraryDatabase.instance.create(library);
  }

  JiuNIanShiaguan() {
    if (dataList.isEmpty) {
      return Container(
        decoration:
            containBoxDecoration("assets/images/bg_first_sp1.png"),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Good life, need to be recorded at all times！",
              style: TextStyle(color: Colors.yellowAccent, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: double.infinity,
              height: 200,
              child: InkWell(
                  onTap: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (_) {
                      return IpThingPage("", "");
                    })).then((value) => buildZhenAi());
                  },
                  child: Lottie.asset("assets/json/json_mengma.json")),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration:
          containBoxDecoration("assets/images/bg_first_sp7.jpg"),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: () {
            buildZhenAi();
          },
          child: ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (_, index) {
                return itemTdData(index);
              }),
        ),
      ),
    );
  }

  itemTdData(int index) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Slidable(
        key: Key(UniqueKey().toString()),
        endActionPane: ActionPane(
          extentRatio: 0.5, //滑动拉出比例
          dismissible: DismissiblePane(onDismissed: () {}),
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              borderRadius: BorderRadius.circular(10),
              flex: 2,
              backgroundColor: const Color(0xFFFF0000),
              foregroundColor: Colors.white,
              icon: CupertinoIcons.delete,
              label: "Del",
              onPressed: (BuildContext context) {
                setState(() {
                  delete(dataList[index].id);
                  buildZhenAi();
                });
              },
            ),
          ],
        ),
        child: Card(
          key: Key("key$index"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Container(
            decoration: const BoxDecoration(
                color: MyColors.color_main,
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: ListTile(
              style: ListTileStyle.drawer,
              onTap: () {
                Navigator.push(context, CupertinoPageRoute(builder: (ctx) {
                  return IpThingPage(
                    dataList[index].title,
                    dataList[index].maincontain,
                  );
                })).then((value) => buildZhenAi());
              },
              minLeadingWidth: 8,
              minVerticalPadding: 10,
              leading: Container(
                  color: Colors.white24, child: Text("<${index + 1}>")),
              dense: true,
              title: SizedBox(
                width: 20,
                child: Text(
                  dataList[index].title,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              subtitle: Text(
                dataList[index].amount,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Image(
                image: AssetImage(
                    iconFaceList[int.parse(dataList[index].facemotion)]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
