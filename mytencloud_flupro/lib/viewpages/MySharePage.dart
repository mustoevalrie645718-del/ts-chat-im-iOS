import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../stylesutil/SharedPreferenceUtil.dart';
import '../stylesutil/res_urils.dart';
import '../tools/style_utils.dart';

class MySharePage extends StatefulWidget {
  @override
  _MySharePageState createState() => _MySharePageState();
}

class _MySharePageState extends State<MySharePage> {
  String username = "Mike";
  String sign = "Put off tomorrow what you can do today";
  int logiIndex = 0;
  int gongXIan = 0; //贡献值

  @override
  void initState() {
    super.initState();
    styupLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My share"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildColumn(),
            getJonyView(),
            neiZhai(),
            postdata()
          ],
        ),
      ),
    );
  }

  Widget buildColumn() {
    return Container(
      decoration: containBoxDecoration(
          "assets/images/ic_splash_ho2.png",
          opact: 0.5),
      child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Image(
                fit: BoxFit.fill,
                image: AssetImage(headList[logiIndex]),
              ),
            ),
          ),
          title: Text("${username.toString().isEmpty ? "小明" : username}"),
          subtitle: Text(
              "${sign.toString().isEmpty ? "Put off tomorrow what you can do today" : sign}")),
    );
  }

  void styupLoad() async {
    gongXIan = (await SharedPreferenceUtil.getInt("hadtips"))!;
    if (gongXIan == null) {
      gongXIan = 0;
      SharedPreferenceUtil.setInt("hadtips", 0);
    }
    SharedPreferenceUtil.getString("username").then((value) => {
          if (value != null) {username = value, setState(() {})}
        });
    SharedPreferenceUtil.getString("sign").then((value) => {
          if (value != null) {sign = value, setState(() {})}
        });
    SharedPreferenceUtil.getInt("logoindex").then((value) => {
          if (value != null) {logiIndex = value, setState(() {})}
        });
    gongXIan = (await SharedPreferenceUtil.getInt("hadtips"))!;
    if (gongXIan == null) {
      gongXIan = 0;
      SharedPreferenceUtil.setInt("hadtips", 0);
    }
    setState(() {});
  }

  TextStyle buildStyleText() =>
      const TextStyle(fontSize: 22, color: Colors.black);

  TextStyle styBeiRu() =>
      const TextStyle(fontSize: 20, color: Colors.black);

  TextStyle styTitle() =>
      const TextStyle(fontSize: 14, color: Colors.black);

  getJonyView() {
    return Container(
      decoration:
          containBoxDecoration("assets/images/bg_mygotsfengj1.png"),
      child: CalendarDatePicker(
          initialDate: DateTime.now(),
          firstDate: DateTime(2022),
          lastDate: DateTime(2025),
          onDateChanged: (value) {
            if (value.year != DateTime.now().year ||
                value.month != DateTime.now().month ||
                value.day != DateTime.now().day) {
              gongXIan = 0;
            } else {
              styupLoad();
            }
            setState(() {});
          }),
    );
  }

  neiZhai() {
    return Card(
      child: Container(
        height: 200,
        decoration: containBoxDecoration(
            "assets/images/ic_bk_gz.jpg",
            opact: 0.1,
            fit: BoxFit.fitWidth),
        width: double.infinity,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Cumulative contribution value for today",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "$gongXIan",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ],
        )),
      ),
    );
  }

  postdata() {
    return Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        child: Text(
          "Note: Please select the date of the day before screenshots, otherwise it may not be approved!!\n          Use the built-in screenshot tool to save the screenshot。",
          style: TextStyle(color: Colors.red),
        ));
  }
}
