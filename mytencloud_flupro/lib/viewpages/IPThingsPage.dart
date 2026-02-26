import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mytencloud_flupro/tools/my_colors.dart';

import '../bean/library_database.dart';
import '../bean/librarydata.dart';
import '../models/note.dart';
import '../stylesutil/res_urils.dart';
import '../tools/style_utils.dart';
import '../tools/toast_utils.dart';

class IpThingPage extends StatefulWidget {
  String mtitle;
  String mcontain;
  Library? mlibrar= null;

  IpThingPage(this.mtitle, this.mcontain);

  @override
  _IpThingPageState createState() => _IpThingPageState();
}

class _IpThingPageState extends State<IpThingPage> {
  late TextEditingController _controller; //正文
  late TextEditingController _newContral1;
  late TextEditingController _newContral2;
  late TextEditingController _newContral3;
  late TextEditingController _newContral4;
  bool inids = false;
  List<Color> defaultColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];
  int cunteindex = 0;
  var detaDetail = DateTime.now().toString().substring(0, 11);

  var LibVies = Library(
      color: "0",
      isbold: "0",
      datetime: DateTime.now(),
      facemotion: "0",
      title: "",
      maincontain: "",
      moneytype: "",
      useway: "",
      duration: "",
      amount: "",
      createtime: DateTime.now(), id: 0);

  @override
  void initState() {
    super.initState();
    if (widget.mlibrar != null) {
      LibVies = widget.mlibrar!;
      LibVies.useway = widget.mlibrar!.useway;
      LibVies.duration = widget.mlibrar!.duration;
      LibVies.amount = widget.mlibrar!.amount;
    }
    _controller = TextEditingController(text: widget.mcontain.toString());
    _newContral1 = TextEditingController(text: widget.mtitle.toString());
    _newContral2 = TextEditingController(text: LibVies.useway);
    _newContral3 = TextEditingController(text: LibVies.amount);
    _newContral4 = TextEditingController(text: LibVies.duration);
    LibVies.title = widget.mtitle;
    if (widget.mtitle.isNotEmpty) {
      inids = true;
    }
    LibVies.maincontain = widget.mcontain;
    _loadDailyQuote();
  }
  void _loadDailyQuote() {
    final random = Random();
    _dailyQuote = DailyQuote.quotes[random.nextInt(DailyQuote.quotes.length)];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('添加'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: () {
              if (LibVies.title.isEmpty || LibVies.maincontain.isEmpty) {
                ToastUtil.showMyToast("请完成必填项");
              } else {
                DateTime now = DateTime.now();
                LibVies.duration=now.toString().substring(0, 10);
                getInitData(LibVies);
                ToastUtil.showMyToast("保存成功");
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save',
              style: sty_dijia(),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
              decoration: containBoxDecoration("assets/images/bg_first_sp1.png",
                  opact: 0.5),
              height: MediaQuery.of(context).size.height,
              child: BodyLivew(context)),
        ));
  }

  void getInitData(Library library) {
    print("添加${library.toJson()}");
    if (inids) {
      LibraryDatabase.instance.update(library);
    } else {
      LibraryDatabase.instance.create(library);
    }
  }
  late DailyQuote _dailyQuote;
  Widget _buildDailyQuote() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _dailyQuote.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _dailyQuote.type == 'thought' ? Icons.psychology :
                _dailyQuote.type == 'inspiration' ? Icons.lightbulb :
                _dailyQuote.type == 'reading' ? Icons.book :
                Icons.favorite,
                color: Colors.black54,
              ),
              SizedBox(width: 8),
              Text(
                _dailyQuote.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            _dailyQuote.content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget BodyLivew(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        _buildDailyQuote(),
        //心情选择 shareLis(context);
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: 80,
              height: 80,
              child: InkWell(
                onTap: (){shareLis(context);},
                child: Image(
                  width: 80,
                  fit: BoxFit.fill,
                  height: 80,
                  image: AssetImage(iconFaceList[int.parse(LibVies.facemotion)]),
                ),
              ),
            ),
            setKowd(context)
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        ListTile(
          dense: true,
          style: ListTileStyle.drawer,
          title: Text(
            "类型",
            style: sty_dijia(),
          ),
          trailing: SizedBox(
            width: 200,
            child: TextField(
                textAlign: TextAlign.center,
                controller: _newContral1,
                maxLines: 1,
                onChanged: (value) {
                  LibVies.title = value;
                },
                style: TextStyle(
                  fontSize: 14,
                  color: defaultColors[int.parse(LibVies.color)],
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                    hintText: "请输入", border: UnderlineInputBorder())),
          ),
        ),
        const Divider(
          height: 1,
        ),
        ListTile(   dense: true,
          title: Text("用途", style: sty_dijia()),
          trailing: SizedBox(
            width: 200,
            child: TextField(
                textAlign: TextAlign.center,
                controller: _newContral2,
                maxLines: 1,
                onChanged: (value) {
                  LibVies.useway = value;
                },
                style: TextStyle(
                  fontSize: 14,
                  color: defaultColors[int.parse(LibVies.color)],
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: "请输入",
                )),
          ),
        ),
        const Divider(
          height: 1,
        ),
        ListTile(   dense: true,
          title: Text("金额", style: sty_dijia()),
          trailing: SizedBox(
            width: 200,
            child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                controller: _newContral3,
                maxLines: 1,
                onChanged: (value) {
                  LibVies.amount = value;
                },
                style: TextStyle(
                  fontSize: 14,
                  color: defaultColors[int.parse(LibVies.color)],
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: "请输入",
                )),
          ),
        ),
        const Divider(
          height: 1,
        ),
        // ListTile(   dense: true,
        //   title: Text("时间", style: sty_dijia()),
        //   trailing: SizedBox(
        //     width: 200,
        //     child: TextField(
        //         textAlign: TextAlign.center,
        //         controller: _newContral4,
        //         maxLines: 1,
        //         onChanged: (value) {
        //           LibVies.duration = value;
        //         },
        //         style: TextStyle(
        //           fontSize: 14,
        //           color: defaultColors[int.parse(LibVies.color)],
        //           fontWeight: FontWeight.bold,
        //         ),
        //         decoration: const InputDecoration(
        //           hintText: "请输入",
        //         )),
        //   ),
        // ),
        const SizedBox(
          height: 30,
        ),
         Text("备注",style: sty_dijia(),),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)),
            child: TextField(
                controller: _controller,
                maxLines: 5,
                onChanged: (value) {
                  cunteindex = value.length;
                  LibVies.maincontain = value;
                },
                style: TextStyle(
                  color: defaultColors[int.parse(LibVies.color)],
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  hintText: "请输入",
                  counterText: cunteindex.toString(),
                  border: const OutlineInputBorder(),
                )),
          ),
        ),
        Card(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(signSaiList[Random().nextInt(7)]),
            ))
      ],
    );
  }

  TextStyle sty_dijia() => const TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold);

  setKowd(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: MyColors.color_main,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          //日期选择
          OutlinedButton(
            onPressed: () {
              safeView(context);
            },
            child: Text(LibVies.datetime.toString().substring(0, 11),
                style: const TextStyle(color: Colors.black)),
          ),
          //是否加粗
          Switch(
              value: LibVies.isbold == "1",
              onChanged: (value) {
                setState(() {
                  LibVies.isbold = value ? "1" : "0";
                });
              }),

        ],
      ),
    );
  }

  void shareLis(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SizedBox(
                height: 150,
                width: 150,
                child: GridView.builder(
                    itemCount: iconFaceList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4),
                    itemBuilder: (_, index) {
                      return InkWell(
                          onTap: () {
                            this.setState(() {
                              LibVies.facemotion = index.toString();
                            });
                            setState(() {
                              LibVies.facemotion = index.toString();
                            });
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: index == int.parse(LibVies.facemotion)
                                    ? MyColors.color_main
                                    : Colors.white,
                              ),
                              child: Image(
                                fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                  image: AssetImage(iconFaceList[index]))));
                    }),
              ),
              actions: [
                TextButton(
                  child: const Text('ok'),
                  onPressed: () {
                    this.setState(() {});
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void safeView(BuildContext context) async {
    var result = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        lastDate: DateTime(2025),
        firstDate: DateTime(2022));
    detaDetail = result.toString().substring(0, 11);
    LibVies.datetime = result!;
    setState(() {});
  }
}
