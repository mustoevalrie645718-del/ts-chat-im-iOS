import 'package:flutter/material.dart';

import '../stylesutil/res_urils.dart';

class GetListDataPage extends StatefulWidget {
  const GetListDataPage({Key? key}) : super(key: key);

  @override
  _GetListDataPageState createState() => _GetListDataPageState();
}

class _GetListDataPageState extends State<GetListDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('This is the podium'),
          centerTitle: true,
        ),
        body: initListData());
  }

  initListData() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/bg_first_sp3.jpg"),
                fit: BoxFit.fitHeight,
                opacity: 0.8)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Center(
                  child: Text(
                "Standard courtesy all the best",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              )),
              iitView(),
              Text(
                "How to get it: Send the screenshot of your homepage, contact address and contact information to the official email Bigmelon2022@163.com, the customer service sister will contact you within 48 hours",
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
              Divider(
                height: 20,
              ),
              Text(
                listGift,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  iitView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Column(
          children: const <Widget>[
            Image(
              image: AssetImage("assets/images/playser_ded2.jpg"),
              width: 80,
              height: 100,
            ),
            Text(
              "First place：\n小霸王游戏机一台",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Column(
          children: const <Widget>[
            Image(
              image: AssetImage("assets/images/playser_ded3.jpg"),
              width: 80,
              height: 100,
            ),
            Text(
              "Second place：\n怀旧掌机一台",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Column(
          children: const <Widget>[
            Image(
              image: AssetImage("assets/images/playser_ded1.jpg"),
              width: 80,
              height: 100,
            ),
            Text(
              "Third place：\n游戏卡带经典款任选4",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
