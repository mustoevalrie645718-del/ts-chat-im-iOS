import 'package:flutter/material.dart';

import '../stylesutil/SharedPreferenceUtil.dart';
import '../stylesutil/res_urils.dart';

class SetInfoPage extends StatefulWidget {
  @override
  _SetInfoPageState createState() => _SetInfoPageState();
}

class _SetInfoPageState extends State<SetInfoPage> {
  int cuttenid = 0;
  @override
  void initState() {
    super.initState();
    SharedPreferenceUtil.getInt("logoindex").then((value) => {
          if (value != null) {cuttenid = value, setState(() {})}
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Information setting'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text("Please select a personality profile picture"),
                Container(height: 200, child: _getGridView()),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ));
  }

  GridView _getGridView() => GridView.builder(
      itemCount: headList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //横轴元素个数
          crossAxisCount: 4,
          //纵轴间距
          mainAxisSpacing: 10.0,
          //横轴间距
          crossAxisSpacing: 10.0,
          //子组件宽高长度比例
          childAspectRatio: 1.0),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            SharedPreferenceUtil.setInt("logoindex", index); //头像
            setState(() {
              cuttenid = index;
            });
          },
          child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(
                    color: index == cuttenid ? Colors.red : Colors.white,
                    width: 2),
              ),
              child: Image(image: AssetImage(headList[index]))),
        );
      });
}
