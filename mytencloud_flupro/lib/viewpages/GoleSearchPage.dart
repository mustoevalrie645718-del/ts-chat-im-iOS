import 'package:flutter/material.dart';

import '../bean/money.dart';
import '../bean/money_database.dart';
import '../stylesutil/res_urils.dart';

class GoleSearchPage extends StatefulWidget {
  @override
  State<GoleSearchPage> createState() => _GoleSearchPageState();
}

class _GoleSearchPageState extends State<GoleSearchPage> {
  List<Money> dataList = []; //列表数据

  TextEditingController _contral = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('搜索'),
        ),
        body: bodyWidget);
  }

  get bodyWidget => Column(
        children: [
          Container(
              height: 70,
              child: Row(children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    height: 70,
                    child: TextField(
                      controller: _contral,
                      onSubmitted: (value) {
                        searchDate(value);
                      },
                      onChanged: (str){
                        searchDate(str);
                      },
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: '输入关键字（如 购物）',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.delete_forever_outlined),
                            onPressed: () {
                              _contral.value = TextEditingValue(text: "");
                              setState(() {});
                            },
                          ),
                          prefixIcon: Icon(Icons.search)),
                    ),
                  ),
                ),
              ])),
          mainBodys(),
        ],
      );

  mainBodys() {
    return Expanded(
        child:  ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (ctx, index) {
              return itemSanfuren(index);
            }));
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.blueAccent[50],
      child: ListTile(
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
  }

  Future searchDate(String str) async {
    dataList.clear();
    List<Money> alldata = []; //列表数据
    alldata = await MoneyDatabase.instance.readAllNotes();
    if(str.isEmpty){
      dataList.addAll(alldata);
      print("搜索长度"+str+">>"+dataList.length.toString());
      setState(() {
      });
      return;
    }
    alldata.forEach((element) {
      print(outName[int.parse(element.useway)] + ">>" + "搜索1");
      if (outName[int.parse(element.useway)].contains(str.toUpperCase())) {
        dataList.add(element);
      }
    });
    dataList.sort((a, b) {
      return b.datetime.isAfter(a.datetime) ? 1 : -1;
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    readFutureView(2025, 1);
  }
}
