import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/stylesutil/constfinal.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'MoshiBean.dart';

class LiangbiaoDetail extends StatefulWidget {
  var id = "";

  LiangbiaoDetail(this.id);

  @override
  State<LiangbiaoDetail> createState() => _LiangbiaoDetailState();
}

class _LiangbiaoDetailState extends State<LiangbiaoDetail> {
  var url = "";
  var title = "";
  var time = "";
  var auth = "";
  late InAppWebViewController webViewController;

  @override
  void initState() {
    super.initState();
    getDataList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: initBodyWigets());
  }

  initBodyWigets() {
    return Column(
      children: <Widget>[
        alignBuild("作者：" + auth),
        alignBuild("开发时间" + time),
        const Divider(
          height: 10,
          thickness: 2,
        ),
        Expanded(
            child: InAppWebView(
          onWebViewCreated: (controller) async {
            webViewController = controller;
          },
          initialUrlRequest: URLRequest(url: WebUri(url)),
        ))
        // Expanded(child: appmsApppwd(url))
      ],
    );
  }

  Align alignBuild(String title) => Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ));

  void getDataList() async {
    Map data = Map();
    data["act"] = "getMedicalScalesDetail";
    data["id"] = widget.id;
    data["uid"] = "10074013";
    var datacheck =
        "ZXlKMWMyVnlRV05qYjNWdWRDSTZJbmhvTWlJc0luQmhjM04zYjNKa0lqb2lNVEl6TkRVMklpd2lj"
        "MjkxY21ObFpteGhaeUk2SW1GagpZMjkxYm5SZmJHOW5hVzRpTENKdGIySndhRzl1WlNJNklqRTNO"
        "VEl4TXpFMU1qRXhJaXdpYzI5MWNtTmxJam9pUVc1a2NtOXBaQ0lzCkluWmxjbk5wYjI0aU9pSTFM"
        "akl1T1NJc0ltMXZaR1ZzSWpvaVNGVkJWMFZKVEVsUExVRk9NREFpTENKemVYTjBaVzEyWlhKemFX"
        "OXUKSWpvaU1USWlmUT09Cg==";
    var jiami1 = utf8.encode(base64Encode(utf8.encode(json.encode(data))));
    var jiami2 = base64Encode(jiami1);
    print("详情加密卡卡西${jiami2}");
    FormData formData = FormData.fromMap({
      "data": jiami2,
      "datacheck": datacheck,
    });
    var userData = await Dio().post(
      ConstSlwFinal.BASE_URL,
      data: formData,
    );
    var jsons = utf8.decode(base64Decode(userData.data.toString()));
    var jsonss = utf8.decode(base64Decode(jsons));
    SomeRootEntity bean = SomeRootEntity.fromJson(jsonDecode(jsonss));
    print("卡卡西jsons${bean.data!.data!.htmlUrl}");
    // msdatalist = bean.data.data.list;
    url = bean.data!.data!.htmlUrl;
    title = bean.data!.data!.title;
    time = bean.data!.data!.developTime;
    auth = bean.data!.data!.auth;
    webViewController.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    setState(() {});
    // Future.delayed(Duration(seconds: 2), () {
    //   setState(() {});
    // });
  }
}
