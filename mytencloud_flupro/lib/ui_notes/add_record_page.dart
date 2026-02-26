import 'package:mytencloud_flupro/tools/my_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bean/money.dart';
import '../bean/money_database.dart';
import '../tools/toast_utils.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({Key? key}) : super(key: key);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  TextEditingController _myController = TextEditingController();
  int newUseWays = 0; //选择方式
  int wayTypes = 0; //0支出1收入
  List<String> outName = [
    "食物",
    "购物",
    "交通",
    "日常",
    "水果",
    "零食",
    "蔬菜",
    "运动",
    "娱乐",
    "服饰",
  ];
  List<String> inName = ["薪资", "兼职", "分红", "礼物", "其他"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          choseInfos(),
          SujiaList(),
          ingFuHun(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,height: 48,
              child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => MyColors.color_main)),
                  onPressed: () {
                    if (_myController.text.isEmpty) {
                      ToastUtil.showMyToast("请输入");
                      return;
                    }
                    Money money = Money(
                        type: wayTypes.toString(),
                        money: _myController.text.toString(),
                        datetime: DateTime.now(),
                        useway: newUseWays.toString(), id: 0);
                    zhuiXv(money);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "提交",
                    style: TextStyle(color: MyColors.white, fontSize: 18),
                  )),
            ),
          )
        ]),
      ),
    );
  }

  choseInfos() {
    return Container(
      height: MediaQuery.of(context).size.height / 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          OutlinedButton(
              style: ButtonStyle(
                  backgroundColor: wayTypes == 0
                      ? MaterialStateProperty.resolveWith(
                          (states) => Colors.red)
                      : MaterialStateProperty.resolveWith(
                          (states) => Colors.grey)),
              onPressed: () {
                wayTypes = 0;
                setState(() {});
              },
              child: const Text(
                "支出",
                style: TextStyle(color: Colors.white),
              )),
          OutlinedButton(
              style: ButtonStyle(
                  backgroundColor: wayTypes == 1
                      ? MaterialStateProperty.resolveWith(
                          (states) => Colors.red)
                      : MaterialStateProperty.resolveWith(
                          (states) => Colors.grey)),
              onPressed: () {
                wayTypes = 1;
                setState(() {});
              },
              child: const Text(
                "收入",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }

  SujiaList() {
    return Container(
      height: MediaQuery.of(context).size.height / 10 * 4,
      child: GridView.builder(
          itemCount: wayTypes == 0 ? outName.length : inName.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4),
          itemBuilder: (xtc, index) {
            return itemData(index);
          }),
    );
  }

  itemData(int index) {
    return InkWell(
      onTap: () {
        newUseWays = index;
        setState(() {});
      },
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            padding: const EdgeInsets.all(10),
            height: 50,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Image(
                image: wayTypes == 0
                    ? AssetImage(
                        "assets/images/choice/ic_bk_zc${index + 1}.png")
                    : AssetImage(
                        "assets/images/choice/ic_bk_sr${index + 1}.png"),
                color: index == newUseWays ? Colors.red : MyColors.color_main,
              ),
            ),
          ),
          Text(
            wayTypes == 0 ? outName[index] : inName[index],
            style: _cuttentList(index),
          )
        ],
      ),
    );
  }

  ingFuHun() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      margin: const EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height / 10,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 10),
      child: CupertinoTextField(
        keyboardType:
            const TextInputType.numberWithOptions(signed: true, decimal: false),
        maxLines: 1,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
        autofocus: false,
        placeholder: "请输入金额",
        controller: _myController,
        suffix: Text("¥     "),
        prefix: Text(
          "金额:",
          style: TextStyle(fontSize: 20, color: Colors.red),
        ),
        decoration: BoxDecoration(shape: BoxShape.circle),
        textInputAction: TextInputAction.done,
        onEditingComplete: () {
          // print("输入完成");
          if (_myController.text.isEmpty) {
            ToastUtil.showMyToast("请输入");
            return;
          }
          Money money = Money(
              type: wayTypes.toString(),
              money: _myController.text.toString(),
              datetime: DateTime.now(),
              useway: newUseWays.toString(), id: 0);
          zhuiXv(money);
          Navigator.pop(context);
        },
      ),
    );
  }

  void zhuiXv(Money money) {
    MoneyDatabase.instance.create(money);
  }

  _cuttentList(int index) {
    if (index == newUseWays) {
      return TextStyle(color: Colors.red);
    } else {
      return TextStyle(color: Colors.blue);
    }
  }
}
