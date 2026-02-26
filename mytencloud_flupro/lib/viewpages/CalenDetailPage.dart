import 'dart:math';

import 'package:flutter/material.dart';

import '../stylesutil/canendar_utils.dart';
import '../stylesutil/res_urils.dart';

class CalednDetail extends StatefulWidget {
  @override
  _CalednDetailState createState() => _CalednDetailState();
}

class _CalednDetailState extends State<CalednDetail> {
  DateTime selecttime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Calendar"),
        ),
        body: buildMain());
  }

  buildMain() {
    return Column(
      children: <Widget>[
        CaledatSelect(callback: (sele, foc) {
          selecttime = sele;
          print("选中${selecttime.toString()}");
          setState(() {});
        }),
        _initQiliuHai()
      ],
    );
  }

  _initQiliuHai() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.redAccent,
        child: Container(
          padding: EdgeInsets.all(10),
          width: 300,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill, image: AssetImage("images/bg_mebac.png"))),
          child: Column(
            children: <Widget>[
              Text(
                Chenmen[
                        Random().nextInt(Chenmen.length - 2)]
                    .substring(3),
                style: initZzhongren(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "---- KE",
                  style: TextStyle(color: Colors.red[100], fontSize: 20),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  initZzhongren() {
    return TextStyle(color: Colors.white, fontSize: 18);
  }
}
