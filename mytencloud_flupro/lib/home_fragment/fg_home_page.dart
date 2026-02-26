import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:mytencloud_flupro/bean/photo_bean.dart';
import 'package:mytencloud_flupro/viewpages/BeautifulPage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:mytencloud_flupro/viewpages/saving_tips_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../bean/diary_bean.dart';
import '../pages/habit_list_page.dart';
import '../pages/note_list_page.dart';
import '../stylesutil/SharedPreferenceUtil.dart';
import '../stylesutil/res_urils.dart';
import '../ui_notes/choose_can_detail_page.dart';
import '../viewpages/ArtPage.dart';
import '../viewpages/BeauGirPage.dart';
import '../viewpages/GoleSearchPage.dart';
import '../viewpages/NewDataLisePage.dart';
import '../viewpages/NotesListActivity.dart';
import '../bean/money.dart';
import '../bean/money_database.dart';
import '../localbean/BeaugileBean.dart';
import '../viewpages/ToldPage.dart';
import '../viewpages/blessing_category_page.dart';
import '../viewpages/diary_edit_page.dart';
import '../viewpages/invoice_list_page.dart';
import '../viewpages/waterfall_detail_page.dart';
import 'package:badges/badges.dart' as badges;

//首页
class HomeFragment extends StatefulWidget {
  const HomeFragment({Key? key}) : super(key: key);

  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  List<String> newTItlelist = [
    "省钱妙招",
    "清单",
    "账单",
    "行程",
    "随笔",
    "发票助手",
    "美图鉴赏",
    "祝福短信"
  ];
  List<String> homeimgList = [
    "assets/icon/home_book.png",
    "assets/icon/home_note.png",
    "assets/icon/home_bill.png",
    "assets/icon/home_book.png",
    "assets/icon/home_calendar.png",
    "assets/icon/home_tools.png",
    "assets/icon/home_img.png",
    "assets/icon/home_ms.png",
  ];
  List<String> imgList = [
    "assets/images/ic_banner10.png",
  ];

  List<Money> dataList = []; //列表数据
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  final RefreshController _refreshController2 =
      RefreshController(initialRefresh: true);
  double inTotal = 0; //收入合计
  double outTotal = 0; //支出合计
  String year = DateTime.now().year.toString(); //
  String month = DateTime.now().month.toString(); //
  List pickList = [
    "2025",
    "2026",
    "2027",
  ];
  int selectIndex = 0;
  String buatimg =
      "https://mxnzp.com/api/image/girl/list/random?app_id=ebojeugvrmkcjxsm&app_secret=70HxBYZsrz3vlOvn3zaybPIL3hrqkLei";
  List pickMonth = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
  ];
  int selectcourse = 0;
  int currenIndex = 0;

  final _preMoney = TextEditingController();
  List<String> imglistss = [];
  final TextEditingController text1 = TextEditingController(text: "0");

  @override
  void initState() {
    super.initState();
    readCbView(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () {
          readCbView(DateTime.now().year, DateTime.now().month);
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 20, right: 0, bottom: 15),
                title: const Text(
                  'WELCOME BACK ',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                background: Image.asset(
                  'assets/icon/ban_sp2.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Set'),
                          content: TextField(
                            controller: _preMoney,
                            decoration:
                                const InputDecoration(hintText: "Please enter"),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text(
                                'ok',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                SharedPreferenceUtil.setDouble(
                                    "totalpremoney",
                                    double.parse(_preMoney.text.toString()) ??
                                        1000);
                                Navigator.of(dialogContext)
                                    .pop(); // Dismiss alert dialog
                              },
                            ),
                            TextButton(
                              child: const Text(
                                'cancel',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.of(dialogContext)
                                    .pop(); // Dismiss alert dialog
                              },
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      year = DateTime.now().year.toString();
                      month = DateTime.now().month.toString();
                      _refreshController.requestRefresh();
                    },
                    icon: Icon(Icons.refresh)),
                badges.Badge(
                  badgeContent: Center(
                      child: Text(
                    "0",
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  )),
                  child: IconButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (xtc) {
                          return ToldPage();
                        }));
                      },
                      icon: const Icon(Icons.add_alert_sharp)),
                  position: badges.BadgePosition.topEnd(top: 5, end: 5),
                )
              ],
            ),
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (xtc) {
                    return GoleSearchPage();
                  }));
                },
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Row(children: const <Widget>[
                      Icon(Icons.search),
                      SizedBox(width: 10),
                      Center(child: Text("Please Enter Word!"))
                    ]),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  headView(),
                  SizedBox(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GuanTOng(),
                        GuanTOng1(),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage("assets/images/ban_home_ban1.jpg"),
                      opacity: 0.3,
                      fit: BoxFit.cover,
                    )),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              currenIndex = 0;
                              _didClickSelectedGender(pickList, selectIndex);
                            },
                            child: ListTile(
                              title: Text(
                                year,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios_rounded),
                            ),
                          ),
                        ),
                        topView(),
                        topTools(),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                  ),
                  StaggeredGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      staggeredTiles: photoList.map((e) {
                        return StaggeredTile.count(1, 1);
                      }).toList(),
                      children: photoList
                          .map((e) => InkWell(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (xtc) {
                                  return WaterfallDetailPage(item: e);
                                }));
                              },
                              child: Image.network(
                                e.imageUrl!,
                                height: 100,
                              )))
                          .toList()),
                  const Divider(
                    height: 5,
                  ),
                ]),
              ),
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(context, createRoute(const AddNotePage()))
      //         .then((value) => _refreshController2.requestRefresh());
      //   },
      //   backgroundColor: MyColors.color_main,
      //   elevation: 0,
      //   child: SizedBox(
      //     width: 80,
      //     height: 80,
      //     child: Lottie.asset("assets/json/json_feijin.json"),
      //   ),
      // ),
    );
  }

  Widget MyAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextButton(
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Set'),
                  content: TextField(
                    controller: _preMoney,
                    decoration: const InputDecoration(hintText: "Please enter"),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text(
                        'ok',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        SharedPreferenceUtil.setDouble("totalpremoney",
                            double.parse(_preMoney.text.toString()) ?? 1000);
                        Navigator.of(dialogContext)
                            .pop(); // Dismiss alert dialog
                      },
                    ),
                    TextButton(
                      child: const Text(
                        'cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext)
                            .pop(); // Dismiss alert dialog
                      },
                    )
                  ],
                );
              },
            );
          },
          child: const Icon(
            Icons.settings,
            color: Colors.white,
          ),
        ),
        IconButton(
            onPressed: () async {
              year = DateTime.now().year.toString();
              month = DateTime.now().month.toString();
              _refreshController2.requestRefresh();
            },
            icon: Image.asset(
              "assets/images/ic_home_reflash.png",
              width: 20,
              height: 20,
            )),
      ],
    );
  }

  AppBar qijibaiHUai(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: const Text("HOME"),
      leading: TextButton(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Set'),
                content: TextField(
                  controller: _preMoney,
                  decoration: const InputDecoration(hintText: "Please enter"),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      'ok',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      SharedPreferenceUtil.setDouble("totalpremoney",
                          double.parse(_preMoney.text.toString()) ?? 1000);
                      Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                    },
                  ),
                  TextButton(
                    child: const Text(
                      'cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                    },
                  )
                ],
              );
            },
          );
        },
        child: const Icon(
          Icons.settings,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
            onPressed: () async {
              year = DateTime.now().year.toString();
              month = DateTime.now().month.toString();
              _refreshController2.requestRefresh();
            },
            icon: Image.asset(
              "assets/images/ic_home_reflash.png",
              width: 20,
              height: 20,
            )),
      ],
    );
  }

  Widget GuanTOng() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 20,
      height: 120,
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
  Widget GuanTOng1() {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, CupertinoPageRoute(builder: (_) {
          return DiaryEditPage(diary: DiaryBean(),);
        }));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 20,
          height: 120,
          child: Stack(
            children:  [
              const Opacity(
                opacity: 0.7,
                child: Image(
                    width: double.infinity,
                    fit: BoxFit.cover,
                    image: AssetImage(
                      "assets/images/diary/bg_diary5.jpg",
                    )),
              ),
              Positioned(
                left: 10,
                right: 0,bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: const Text("写日记",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  headView() => Padding(
        padding: const EdgeInsets.all(5.0),
        child: SizedBox(
          height: 180,
          child: GridView.builder(
              itemCount: homeimgList.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, mainAxisSpacing: 0, crossAxisSpacing: 5),
              itemBuilder: (ctx, index1) {
                return GestureDetector(
                  onTap: () {
                    switch (index1) {
                      case 0: //省钱妙招
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (_) {
                          return SavingTipsPage();
                        }));
                        break;
                      case 1:
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (_) {
                          return NotesListPages();
                        }));
                        break;
                      case 2: //账单
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (_) {
                          return  ChoseBillYearPage();
                        }));
                        break;

                      case 3:
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (_) {
                          return YingZiPage();
                        }));
                        break;
                      case 4:
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (_) {
                          return NoteListPage();
                        }));
                        break;
                      case 5:
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (_) {
                          return  InvoiceListPage();
                        }));
                        break;
                      case 6:
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (_) {
                          return BeautifulPage();
                        }));
                        break;
                      case 7:
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (_) {
                          return BlessingCategoryPage();
                        }));
                        break; case 8:
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (_) {
                          return HabitListPage();
                        }));
                        break;
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      Image(
                        image: AssetImage(homeimgList[index1]),
                        width: 40,
                        height: 40,
                      ),
                      Text(
                        newTItlelist[index1],
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                );
              }),
        ),
      );

  topView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          SizedBox(
              width: 50,
              child: Image(
                image: AssetImage("assets/icon/home_note.png"),
                width: 30,
                height: 30,
              )),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[Text("收入"), Text("支出")],
            ),
          ),
        ],
      ),
    );
  }

  topTools() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Card(
            child: TextButton(
              onPressed: () {
                currenIndex = 1;
                _didClickSelectedGender(pickMonth, selectcourse);
              },
              child: Text(
                "${month}",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  inTotal.toStringAsFixed(2),
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  outTotal.toStringAsFixed(2),
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void getData() async {
    Dio dio = Dio();
    var igdata = await dio.post(buatimg);
    Beautyimgbean data = Beautyimgbean.fromJson(igdata.data);
    for (var item in data.data) {
      imglistss.add(item.imageUrl);
    }
    setState(() {
      print("美图请求${imglistss.length}");
    });
    if (imglistss.isEmpty || imglistss.length < 50) {
      Future.delayed(Duration(seconds: 3), () {
        getData();
      });
    }
  }

  Widget buildNIngYi(int index, bool isout, String icname) {
    TextEditingController _counert = TextEditingController();
    return Slidable(
      key: const ValueKey(0),
      endActionPane: ActionPane(
        dismissible: DismissiblePane(onDismissed: () {
          var temp = dataList[index];
          deleMoney(dataList[index].id);
          dataList.remove(temp);
          setState(() {});
          _refreshController.requestRefresh();
        }),
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            borderRadius: BorderRadius.circular(10),
            flex: 2,
            backgroundColor: const Color(0xFFFF0000),
            foregroundColor: Colors.white,
            icon: CupertinoIcons.delete,
            label: '删除',
            onPressed: (BuildContext context) {
              var temp = dataList[index];
              deleMoney(dataList[index].id);
              dataList.remove(temp);
              setState(() {});
              _refreshController.requestRefresh();
            },
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.blueAccent[50],
        child: ListTile(
          onTap: () {
            _counert.text = dataList[index].money;
            showDialog(
                context: context,
                builder: (ctx) {
                  return CupertinoAlertDialog(
                    content: CupertinoTextField(
                      keyboardType: TextInputType.number,
                      controller: _counert,
                      placeholder: "请输入",
                    ),
                    title: Text("修改"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "cancel",
                            style: TextStyle(color: Colors.red),
                          )),
                      TextButton(
                          onPressed: () {
                            Money mon = dataList[index];
                            mon.money = _counert.text;
                            futureUpdate(mon);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "ok",
                            style: TextStyle(color: Colors.red),
                          )),
                    ],
                  );
                });
          },
          subtitle: Text(dataList[index].datetime.toString().substring(0, 10)),
          title: Text(isout
              ? outName[int.parse(dataList[index].useway.toString())]
              : inName[int.parse(dataList[index].useway.toString())]),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image(
              image: AssetImage(
                  "assets/images/choice/$icname${int.parse(dataList[index].useway.toString()) + 1}.png"),
              color: isout ? Colors.red[200] : Colors.green[200],
            ),
          ),
          trailing: Text("${isout ? "-" : "+"}${dataList[index].money}¥"),
        ),
      ),
    );
  }

  Future readCbView(int year, int month) async {
    dataList.clear();
    List<Money> alldata = []; //列表数据
    alldata = await MoneyDatabase.instance.readAllNotes();
    alldata.forEach((element) {
      if (element.datetime.year == year && element.datetime.month == month) {
        dataList.add(element);
      }
    });
    dataList.sort((a, b) {
      return b.datetime.isAfter(a.datetime) ? 1 : -1;
    });
    setState(() {});
    _refreshController.refreshCompleted();
    _refreshController2.refreshCompleted();
    outTotal = 0;
    inTotal = 0;
    for (var value in dataList) {
      if (value.datetime.year == year && value.datetime.month == month) {
        //当月
        if (value.type == "0") {
          //支出
          outTotal = double.parse(value.money) + outTotal;
        } else {
          //收入
          inTotal = double.parse(value.money) + inTotal;
        }
      }
    }
  }

  Future futureUpdate(Money money) async {
    await MoneyDatabase.instance.update(money);
    _refreshController.requestRefresh();
  }

  Future deleMoney(int id) async {
    await MoneyDatabase.instance.delete(id);
    _refreshController.requestRefresh();
  }

  void addMony(Money money) {
    MoneyDatabase.instance.create(money);
    _refreshController.requestRefresh();
  }

  void _didClickSelectedGender(List pickerChildren, int selectedyear) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          var controllr =
              FixedExtentScrollController(initialItem: selectedyear);
          return Container(
            // padding: EdgeInsets.all(10),
            height: 250,
            color: Colors.grey[200],
            child: Column(
              children: <Widget>[
                Container(
                  height: 40,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "cancel",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          selectedyear = controllr.selectedItem;
                          Navigator.pop(context, pickerChildren[selectedyear]);
                        },
                        child: Text(
                          "OK",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                    ),
                    child: Container(
                      height: 200,
                      child: CupertinoPicker(
                        scrollController: controllr,
                        // diameterRatio: 1.5,
                        // offAxisFraction: 0.2, //轴偏离系数
                        // useMagnifier: true, //使用放大镜
                        // magnification: 1.5, //当前选中item放大倍数
                        itemExtent: 32, //行高
                        // backgroundColor: Colors.amber, //选中器背景色
                        onSelectedItemChanged: (value) {
                          selectedyear = value;
                          // print("value = $value, 性别：${pickerChildren[value]}");
                          // year = pickerChildren[value];
                          // readData();
                        },
                        children: pickerChildren.map((data) {
                          return Center(
                            child: Text(data),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).then((value) {
      if (value != selectedyear && value != null) {
        if (currenIndex == 0) {
          setState(() {
            year = value;
          });
        } else {
          setState(() {
            month = value;
          });
        }
        readCbView(int.parse(year), int.parse(month));
      }
    });
  }

  void TOastshowMsg(String content) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  JiangNIng() {
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
