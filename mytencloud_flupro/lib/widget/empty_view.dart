import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
String title;
EmptyView({Key? key,required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:[
              Image.asset("assets/images/ic_nodata.png",width: 100,height: 100,),
              SizedBox(height: 10,),
              Text(title,style: TextStyle(fontSize: 18),)
            ],
          ),
        ));
  }
}
