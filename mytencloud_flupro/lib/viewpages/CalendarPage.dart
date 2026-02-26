import 'package:flutter/material.dart';

import '../tools/my_colors.dart';

class CalendatPage extends StatefulWidget {
  const CalendatPage({Key? key}) : super(key: key);

  @override
  State createState() => CalendatPageState();
}

class CalendatPageState extends State<CalendatPage> {
  var num1 = 0, num2 = 0, sum = 0;

  final TextEditingController text1 = TextEditingController(text: "0");
  final TextEditingController text2 = TextEditingController(text: "0");

  void titleView() {
    setState(() {
      print("doAddition---begin");
      num1 = int.parse(text1.text);
      num2 = int.parse(text2.text);
      sum = num1 + num2;
    });
  }

  void getHuangZi() {
    setState(() {
      print("doSub---begin");
      num1 = int.parse(text1.text);
      num2 = int.parse(text2.text);
      sum = num1 - num2;
    });
  }

  void RelectView() {
    setState(() {
      print("doSub---begin");
      num1 = int.parse(text1.text);
      num2 = int.parse(text2.text);
      sum = num1 * num2;
    });
  }

  void _getNote() {
    setState(() {
      print("doSub---begin");
      num1 = int.parse(text1.text);
      num2 = int.parse(text2.text);
      sum = num1 ~/ num2;
    });
  }

  void thisView() {
    setState(() {
      print("doSub---begin");
      text1.text = "0";
      text2.text = "0";
      sum = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("computer"),
        centerTitle: true,
      ),
      backgroundColor: MyColors.color_main,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(45.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    hintText: "Please enter the first digit"),
                controller: text1,
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    hintText: "Please enter the second number"),
                controller: text2,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 18.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "The calculation result is: $sum",
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 18.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    child: const Text(
                      "+",
                      style: TextStyle(fontSize: 30),
                    ),
                    color: Colors.greenAccent,
                    onPressed: titleView,
                  ),
                  MaterialButton(
                    child: const Text("-", style: TextStyle(fontSize: 30)),
                    color: Colors.greenAccent,
                    onPressed: getHuangZi,
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 18.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    child: const Text("*", style: TextStyle(fontSize: 30)),
                    color: Colors.greenAccent,
                    onPressed: RelectView,
                  ),
                  MaterialButton(
                    child: const Text("/", style: TextStyle(fontSize: 30)),
                    color: Colors.greenAccent,
                    onPressed: _getNote,
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 18.0),
              ),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                minWidth: 150,
                child: const Text(
                  "Clear",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                color: Colors.black,
                onPressed: thisView,
              )
            ],
          ),
        ),
      ),
    );
  }
}
