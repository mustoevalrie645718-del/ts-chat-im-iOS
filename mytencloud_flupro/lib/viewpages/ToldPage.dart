import 'package:mytencloud_flupro/tools/my_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ToldDetailPage.dart';

class ToldPage extends StatefulWidget {

  @override
  State<ToldPage> createState() => _ToldPageState();
}

class _ToldPageState extends State<ToldPage> {
  var dataList = <String>[];
  @override
  void initState() {
    super.initState();
    dataList.add("Welcome!Bast Wishes To You!");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Notice'),
        ),
        body: mainView());
  }

  mainView() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (xtc,index){
      return ListTile(
        tileColor: Colors.green[50],
        onTap: (){
          Navigator.push(context, CupertinoPageRoute(builder: (ctx){
            return ToldDetailPage();
          }));
        },
        title: Text(dataList[index]),
        subtitle: const Text("2025-1-25"),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
      );
    },itemCount: dataList.length,);
  }
}
