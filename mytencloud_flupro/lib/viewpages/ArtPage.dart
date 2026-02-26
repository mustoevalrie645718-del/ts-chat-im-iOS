import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../localbean/BeaugileBean.dart';
import '../tools/my_colors.dart';
import 'BeauGirPage.dart';

class YiShuPage extends StatefulWidget {
  @override
  State<YiShuPage> createState() => _YiShuPageState();
}

class _YiShuPageState extends State<YiShuPage> {
  List<String> imglistss = [];
  String buatimg =
      "https://mxnzp.com/api/image/girl/list/random?app_id=ebojeugvrmkcjxsm&app_secret=70HxBYZsrz3vlOvn3zaybPIL3hrqkLei";

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    Dio dio = Dio();
    var igdata = await dio.post(buatimg);
    print("美图" + igdata.data.toString());
    Beautyimgbean data = Beautyimgbean.fromJson(igdata.data);
    for (var item in data.data) {
      imglistss.add(item.imageUrl);
    }
    setState(() {
      print("美图请求${imglistss.length}");
    });
    if (imglistss.isEmpty || imglistss.length < 50) {
      Future.delayed(Duration(seconds: 3), () {
        initData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color_main2,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
          ),
          backgroundColor: MyColors.color_main2,
          title: const Text('活动中心',style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: buildHeadView(),
        ));
  }


  buildHeadView() {
    return Column(
      children: <Widget>[
        Stack(
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Image(
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/ic_banner_12.png")),
            ),
          ],
        )
      ],
    );
  }

  huaFuDi() {
    return SizedBox(
      height: 7200,
      child: Expanded(
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: imglistss.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return GirleViewPage(imglistss[index]);
                }));
              },
              child: Card(
                elevation: 5,
                margin: EdgeInsets.all(8),
                child: Hero(
                    tag: imglistss[index],
                    child: Image.network(imglistss[index])),
              ),
            );
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 每行显示 3 列
            crossAxisSpacing: 10, // 列之间的间距
            mainAxisSpacing: 10, // 行之间的间距
            childAspectRatio: 1, // 控制网格项的宽高比
          ),
        ),
      ),
    );
  }
}
