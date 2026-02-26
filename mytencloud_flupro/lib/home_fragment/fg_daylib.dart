//日记列表
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mytencloud_flupro/bean/diary_bean.dart';
import 'package:mytencloud_flupro/tools/my_colors.dart';

import '../viewpages/diary_edit_page.dart';

class FragmentDayLib extends StatefulWidget {
  const FragmentDayLib({Key? key}) : super(key: key);

  @override
  State<FragmentDayLib> createState() => _FragmentDayLibState();
}

class _FragmentDayLibState extends State<FragmentDayLib> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color_main2,
      appBar: AppBar(
        title: const Text('日记列表'),
      ),
      body: bodyWidget,
      floatingActionButton: FloatingActionButton(
        child: SizedBox(
          width: 80,
          height: 80,
          child: Lottie.asset("assets/json/json_feijin.json"),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiaryEditPage(diary: DiaryBean(),)),
          );
        },
      ),
    );
  }

  get bodyWidget => null;
}
