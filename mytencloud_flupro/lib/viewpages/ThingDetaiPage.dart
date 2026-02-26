import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../stylesutil/SharedPreferenceUtil.dart';
import '../tools/toast_utils.dart';
import 'GetListPage.dart';

class HuaJiaPage extends StatefulWidget {
  const HuaJiaPage({Key? key}) : super(key: key);

  @override
  _HuaJiaPageState createState() => _HuaJiaPageState();
}

class _HuaJiaPageState extends State<HuaJiaPage> {
  //事先声明
  final ImagePicker _picker = ImagePicker();
  late Widget cropImage;
  final cropFit = BoxFit.contain;
  late File _imgPath;
  TextEditingController _newFils = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Tips'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, CupertinoPageRoute(builder: (cyx) {
                  return GetListDataPage();
                }));
              },
              icon: Icon(CupertinoIcons.question))
        ],
        centerTitle: true,
      ),
      backgroundColor: Colors.green[50],
      body: initDataVi(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          if (_newFils.text.isEmpty || _imgPath == null) {
            ToastUtil.showMyToast("Please complete the information");
            return;
          }
          showCupertinoDialog(
              context: context,
              builder: (ctx) {
                return CupertinoAlertDialog(
                  title: Text('Confirm sharing？'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('cancel'),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        ToastUtil.showMyToast("Upload successfully");
                        Navigator.of(context).pop();
                        buildBodys();
                      },
                      child: Text('ok'),
                    ),
                  ],
                );
              });
        },
        child: Icon(Icons.exposure),
      ),
    );
  }

  initDataVi() {
    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeMethod("TextInput.hide");
      },
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/ic_splash_ho1.png"),
                  fit: BoxFit.fill,
                  opacity: 0.7)),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("    Please upload pictures."),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Center(
                      child: InkWell(
                        child: buildText(),
                        onTap: () {
                          _openListds();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        maxLines: 4,
                        textAlign: TextAlign.start,
                        controller: _newFils,
                        decoration: const InputDecoration(
                            hintText: "Please enter the introduction of tips",
                            hintStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 5))),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                height: 30,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Pay attention：",
                        style: TextStyle(color: Colors.red),
                      ),
                      Text(
                        "1.Please upload clear original picture of the game, otherwise the reviewer may refuse to change the information display",
                        style: TextStyle(color: Colors.red),
                      ),
                      Text(
                        "2.Content description as detailed and perfect as possible, at least 100 words, otherwise do not participate in the activity count：",
                        style: TextStyle(color: Colors.red),
                      ),
                      Text(
                        "3.The Tips just uploaded need to be reviewed by the reviewer. If you cannot see them immediately, please wait patiently",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildText() {
    if (_imgPath == null) {
      return const Icon(
        Icons.add,
        size: 100.0,
        color: Colors.grey,
      );
    } else {
      return Image.file(
        _imgPath,
        width: double.infinity,
        height: 200,
        fit: BoxFit.fitWidth,
      );
    }
  }

  _openListds() async {
    print("相1册");
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    print("相册${image}");
    setState(() {
      _imgPath = File(image!.path!);
    });
  }

  void buildBodys() async {
    var hadtups = await SharedPreferenceUtil.getInt("hadtips");
    if (hadtups == null) {
      hadtups = 0;
      SharedPreferenceUtil.setInt("hadtips", 0);
    }
    hadtups = hadtups + 1;
    SharedPreferenceUtil.setInt("hadtips", hadtups);
  }
}
