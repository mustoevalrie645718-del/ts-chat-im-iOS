import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../stylesutil/res_urils.dart';

class ToldDetailPage extends StatefulWidget {

  @override
  State<ToldDetailPage> createState() => _ToldDetailPageState();
}

class _ToldDetailPageState extends State<ToldDetailPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('NoticeDetail'),
        ),
        body: bodyWidget);
  }
  get bodyWidget => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
        children: [
          SizedBox(
              width: 50,height: 50,
              child: Lottie.asset("assets/json/json_xiayibo.json")),
          Text(NoticeDetail,style: TextStyle(fontSize: 16),)
        ],
    )
  );
}
