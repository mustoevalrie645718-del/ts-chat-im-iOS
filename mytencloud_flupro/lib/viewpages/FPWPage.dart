import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tools/toast_utils.dart';

class FindPassWordPage extends StatefulWidget {
  @override
  _FindPassWordPageState createState() => _FindPassWordPageState();
}

class _FindPassWordPageState extends State<FindPassWordPage> {
  final TextEditingController TelInt = TextEditingController(); //手机号
  TextEditingController pwd = TextEditingController(); //手机号
  TextEditingController tel_bie = TextEditingController(); //手机号
  TextEditingController therslife = TextEditingController(); //手机号
  late Timer _timer;
  int _current = 60;

  void initDates() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_current == 0) {
        // ToastUtil.showtoast("计时结束");
        _current = 60;
      } else {
        _current--;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Retrieve password"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Row(
            children: [
              Text("phone:  "),
              Expanded(
                child: TextField(
                  controller: TelInt,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      hintText:
                          "Please enter the registered mobile phone number"),
                ),
              ),
              TextButton(
                  onPressed: () {
                    if (_current == 60 &&
                        TelInt.text.isNotEmpty &&
                        TelInt.text.length > 10) {
                      initDates();
                    } else {
                      ToastUtil.showMyToast(
                          "Please check whether the phone number is correct");
                    }
                  },
                  child: postLive())
            ],
          ),
          Row(
            children: [
              Text("Verification code:  "),
              Expanded(
                child: TextField(
                  controller: pwd,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      hintText: "Please enter the verification code"),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text("New password:  "),
              Expanded(
                child: TextField(
                  controller: tel_bie,
                  keyboardType: TextInputType.phone,
                  decoration:
                      InputDecoration(hintText: "Please enter a new password"),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text("reconfirm:  "),
              Expanded(
                child: TextField(
                  controller: therslife,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      hintText: "Please enter the new password again"),
                ),
              ),
            ],
          ),
          Divider(
            height: 120,
          ),
          SizedBox(
            width: 300,
            height: 50,
            child: OutlinedButton(
              style: ButtonStyle(
                  overlayColor:
                      MaterialStateProperty.all<Color>(Colors.blue[500]!),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue[400]!)),
              onPressed: () {
                if (TelInt.value.text.isEmpty ||
                    pwd.value.text.isEmpty ||
                    tel_bie.value.text.isEmpty ||
                    therslife.value.text.isEmpty) {
                  ToastUtil.showMyToast("Please complete the required fields");
                } else {
                  ToastUtil.showMyToast(
                      "Please check whether the verification code is correct");
                }
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  postLive() {
    if (_current == 60 || _current == 0) {
      return Text("Get Code");
    } else {
      return Text("${_current}second to get");
    }
  }
}
