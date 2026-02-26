import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../stylesutil/res_urils.dart';
import 'WebViewPage.dart';

class AppPage extends StatelessWidget {
  const AppPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("关于"),
        centerTitle: true,
      ),
      body: bodyView(context),
    );
  }

  bodyView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 50,
          ),
          const Center(
            child: CircleAvatar(
              maxRadius: 40,
              child: Image(
                image: AssetImage("assets/images/applogo.jpg"),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.all(8.0),
              child: Text(
                appAbout,
                style: const TextStyle(
                  color: Colors.black,
                  wordSpacing: 1,
                  textBaseline: TextBaseline.alphabetic,
                  fontSize: 18,
                  fontFamily: 'Roboto',height: 1.5
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (ctx) {
              return WebViewPages("https://beian.miit.gov.cn/");
            }));
          }, child: Text("湘ICP备2025119376号-1A",style: const TextStyle(fontSize: 16,color: Colors.blue),)),
          const SizedBox(
            height: 200,
          ),
        ],
      ),
    );
  }
}
