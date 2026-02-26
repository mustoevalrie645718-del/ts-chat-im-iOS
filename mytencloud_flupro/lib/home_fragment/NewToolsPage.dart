import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import '../pages/feedback_page.dart';
import '../pages/note_list_page.dart';
import '../tools/my_colors.dart';
import '../viewpages/ArtPage.dart';
import '../viewpages/BeautifulPage.dart';
import '../viewpages/blessing_category_page.dart';
import '../viewpages/invoice_list_page.dart';

class NewToolsPage extends StatefulWidget {


  @override
  State<NewToolsPage> createState() => _NewToolsPageState();
}

class _NewToolsPageState extends State<NewToolsPage> {
  List<String> imgList = [
    "assets/images/ic_banner_11.png",
  ];
  List<String> newTItlelist = [
    "随笔",
    "发票助手",
    "美图鉴赏",
    "祝福短信",
    "需求你来定"
  ];
  List<String> homeimgList = [
    "assets/icon/ic_find_suibi.png",
    "assets/icon/ic_find_fp.png",
    "assets/icon/home_img.png",
    "assets/icon/home_ms.png",
    "assets/icon/ic_find_xq.png",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color_main2,
        appBar: AppBar(
          centerTitle:  true,
          backgroundColor: MyColors.color_main2,
          title: const Text('发现',style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold)),
        ),
        body: Column(
        children: <Widget>[
          GuanTOng(),
          headView(),
        ]
      ),
    );
  }
  Widget GuanTOng() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: MediaQuery.of(context).size.width ,
      height: 160,
      child: AspectRatio(
        // 配置宽高比
        aspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.width / 6 * 9),
        child: Swiper(
          indicatorLayout: PageIndicatorLayout.SCALE,
          itemBuilder: (BuildContext context, int index) {
            // 配置图片地址
            return InkWell(
                onTap: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (_) {
                    return YiShuPage();
                  }));
                },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image(
                            fit: BoxFit.cover,
                            image: AssetImage(imgList[index])))));
          },
          // // 配置图片数量
          itemCount: imgList.length,
          // 底部分页器
          pagination: const SwiperPagination(),
          // 左右箭头
          // control: DotSwiperPaginationBuilder(),
          // 无限循环
          loop: true,
          // 自动轮播
          autoplay: true,
        ),
      ),
    );
  }
  headView() => Expanded(
    child: Padding(
      padding: const EdgeInsets.only(left: 15.0,right: 15,top: 10),
      child: GridView.builder(
        shrinkWrap:  true,
          itemCount: homeimgList.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: 120,
              crossAxisCount: 2, mainAxisSpacing: 5,
          crossAxisSpacing: 5),
          itemBuilder: (ctx, index1) {
            return GestureDetector(
              onTap: () {
                switch (index1) {
                  case 0: Navigator.push(context,
                      CupertinoPageRoute(builder: (_) {
                        return NoteListPage();
                      }));break;
                  case 1:
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (_) {
                        return  InvoiceListPage();
                      }));
                    break;
                  case 2:
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (_) {
                          return BeautifulPage();
                        }));
                    break;

                  case 3:
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (_) {
                          return BlessingCategoryPage();
                        }));
                    break;
                  case 4:
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (_) {
                          return FeedbackPage();
                        }));
                    break;
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  shape: BoxShape.rectangle,
                  color: Colors.white
                ),
                margin: const EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage(homeimgList[index1]),
                      width: 50,
                      height: 50,
                    ),
                    Text(
                      newTItlelist[index1],
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
            );
          }),
    ),
  );
}
