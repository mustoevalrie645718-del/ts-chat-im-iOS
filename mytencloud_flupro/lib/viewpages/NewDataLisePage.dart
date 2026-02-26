import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/tools/my_colors.dart';
import 'package:mytencloud_flupro/widget/empty_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../stylesutil/res_urils.dart';
import '../bean/library_database.dart';
import '../bean/librarydata.dart';
import '../ui_notes/add_record_page.dart';
import 'IPThingsPage.dart';

class YingZiPage extends StatefulWidget {
  @override
  State<YingZiPage> createState() => _YingZiPageState();
}

class _YingZiPageState extends State<YingZiPage> {
  final _myReflash = RefreshController();
  var libdataList = <Library>[];

  @override
  void initState() {
    super.initState();
    getPieDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color_main,
        appBar: AppBar(
          title: const Text('为心情买单'),
          actions: [
            IconButton(onPressed: (){
              showDialog(context: context, builder: (ctx){
                return  AlertDialog(
                  title: Row(
                            children: const [
                              Icon(Icons.print,color: Colors.red,),
                              Text("Tips"),
                            ],
                          ),
                          content: Text("自由记录：根据自己的心情记录当前的账单，是否是自己喜欢的支出。"),
                );
              });
            }, icon: Image(image: AssetImage("assets/icon/icon_question.png"),))
          ],
        ),
        floatingActionButton:FloatingActionButton(
          backgroundColor: Colors.white,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, CupertinoPageRoute(builder: (_) {
              return IpThingPage("", "");
            })).then((value) => getPieDate());
          },
        ),
        body: Column(
          children: [
            sendLaoZhai()
          ],
        ));
  }

  sendLaoZhai() {
    return Expanded(
      child: libdataList.isNotEmpty
          ? SmartRefresher(
              onRefresh: () {
                getPieDate();
                _myReflash.refreshCompleted();
              },
              controller: _myReflash,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                    separatorBuilder: (ctx, index) {
                      return const Divider(
                        height: 3,
                      );
                    },
                    itemCount: libdataList.length,
                    itemBuilder: (ctx, index) {
                      return txtInfo(index);
                    }),
              ),
            )
          : EmptyView(title: "暂无数据",),
    );
  }

  void getPieDate() async {
    libdataList = await LibraryDatabase.instance.readAllNotes();
    setState(() {});
  }

  Widget txtInfo(int index) {
    var data = libdataList[index];
    return  Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        shape: BoxShape.rectangle,color: Colors.white
      ),
      child: Center(
        child: ListTile(
          onLongPress: () {
            showDialog(
                context: context,
                builder: (ctx) {
                  return CupertinoAlertDialog(
                    title: Text("确认删除当前数据?"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("取消",style: TextStyle(color: Colors.black,fontSize: 16),)),
                      TextButton(
                          onPressed: () {
                            delFuture(data.id);
                            _myReflash.requestRefresh();
                            Navigator.pop(context);
                          },
                          child: Text("删除",style: TextStyle(color: Colors.red,fontSize: 16),)),
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
    );
  }

  Future<int> delFuture(int id) async {
    int resid = await LibraryDatabase.instance.delete(id);
    setState(() {});
    return resid;
  }
}
