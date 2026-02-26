import 'package:flutter/material.dart';

class BaseShots extends StatefulWidget {
  final IconData? iconData;
  final String? iconName;
  const BaseShots({Key? key, this.iconData, this.iconName})
      : super(key: key);

  @override
  _BaseShotsState createState() => _BaseShotsState();
}

class _BaseShotsState extends State<BaseShots> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 140,
        height: 120,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 40,
                child: Icon(widget.iconData),
              ),
              Column(children: [Text(widget.iconName!)])
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(5),
        ),
      ),
    ]);
    ;
  }
}
