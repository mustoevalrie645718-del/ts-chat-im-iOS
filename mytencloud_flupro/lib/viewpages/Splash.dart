import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mytencloud_flupro/stylesutil/SharedPreferenceUtil.dart';
import '../bean/library_database.dart';
import '../bean/librarydata.dart';
import '../bean/money.dart';
import '../bean/money_database.dart';
import '../MainHomeActivity.dart';
import '../method_channel.dart';

class SplashPage extends StatefulWidget {

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Animation<double> aniTOols;
  late AnimationController countralTOols;
  ConnectivityResult _Connect = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
//https://my-json-server.typicode.com/slot8882024/bkbpro/db
  int ResIndex = 0;
  // final dio = Dio();

  @override
  void initState() {
    super.initState();
    firstZhuBao();
    initTutures();
    WidgetsBinding.instance.addObserver(this);
    countralTOols = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: countralTOols,
      curve: Curves.elasticOut,
    );
    aniTOols = Tween(begin: 300.0, end: 800.0).animate(curvedAnimation)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      })
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
        }
      });
    countralTOols.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Stack(alignment: Alignment.center, children: const [
        Positioned.fill(
          child: Image(
            image: AssetImage("assets/images/mysplash.png"),
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          child: CircularProgressIndicator(),
          top: 250,
        )
      ]),
    ));
  }

  Future<void> initTutures() async {
    ConnectivityResult result;
    try {
      result = (await _connectivity.checkConnectivity()) as ConnectivityResult;
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status${e}');
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return updateList(result);
  }

  Future<void> updateList(ConnectivityResult result) async {
    setState(() {
      _Connect = result;
      if (_Connect == ConnectivityResult.none) {
        buildWebView();
      } else {
        geMySiewdsintzdspal();
      }
    });
  }
  void geMySiewdsintzdspal() async {
    Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (ctx) {
      return MainPage();
    }), (route) => false);

    // var fin="https://my-json-server.typicode.com";
    // var info="/slot8882024/bkbpro/db";
    // var userData = await dio.get(fin+info);
    // var json = jsonDecode(userData.toString());
    // var mylist = json["userinfo"]["privacy"]["msg"];
    // if("0"!=mylist){
    //     if ("first"!=mylist) {
    //       var datalist=json["userinfo"]["privacy"]["Area"] as List;
    //       jumpToAndroidMethod(datalist[0]["value"],mylist);
    //       return;
    //     }
    // }else{
    //   Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (ctx) {
    //     return MainPage();
    //   }), (route) => false);
    // }
  }

  @override
  void dispose() {
    countralTOols.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        if (Platform.isIOS) {
          initTutures();
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void buildWebView() async {
    Navigator.pushAndRemoveUntil(context,
        CupertinoPageRoute(builder: (ctx) {
          return MainPage();
        }), (route) => false);
    return;
  }

  void firstZhuBao() async {
    var islogin = await SharedPreferenceUtil.getString("isfirst");
    if (islogin != "1") {
      Money money =
          Money(type: "0", money: "100", datetime: DateTime.now(), useway: "9", id: 0);
      MoneyDatabase.instance.create(money);
      Money money2 =
          Money(type: "0", money: "300", datetime: DateTime.now(), useway: "0", id: 1);
      MoneyDatabase.instance.create(money2);
      Money money3 =
          Money(type: "0", money: "266", datetime: DateTime.now(), useway: "3", id: 2);
      MoneyDatabase.instance.create(money3);
      var mlibrar = Library(
          color: "0",
          isbold: "0",
          datetime: DateTime.now(),
          facemotion: "0",
          title: "谁的青春不迷茫？",
          maincontain: "demo",
          moneytype: "out",
          useway: "demo",
          duration: "one",
          amount: "101",
          createtime: DateTime.now(), id: 3);
      var mlibrar2 = Library(
          color: "0",
          isbold: "0",
          datetime: DateTime.now(),
          facemotion: "3",
          title: "为心买单",
          maincontain: "data",
          moneytype: "out",
          useway: "demo",
          duration: "two",
          amount: "101",
          createtime: DateTime.now(), id: 3);
      LibraryDatabase.instance.create(mlibrar);
      LibraryDatabase.instance.create(mlibrar2);
      SharedPreferenceUtil.setString("isfirst", "1");
      SharedPreferenceUtil.setDouble("totalpremoney", 1000);
    }
  }
}
