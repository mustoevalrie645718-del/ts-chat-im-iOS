import 'package:flutter/material.dart';

typedef _CallBack = void Function();

class TextImageViews extends StatefulWidget {
  final _CallBack callback;
  final IconData iconData;
  final String iconName;
  const TextImageViews({Key? key, required this.callback, required this.iconData, required this.iconName})
      : super(key: key);

  @override
  _TextImageViewsState createState() => _TextImageViewsState();
}

class _TextImageViewsState extends State<TextImageViews> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTap: () {
          widget.callback();
        },
        child: SizedBox(
          width: 80,
          height: 80,
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(
              children: [
                SizedBox(
                  width: 50,
                  height: 40,
                  child: Icon(widget.iconData),
                ),
                Column(children: [Text(widget.iconName)])
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 1,
            margin: EdgeInsets.all(1),
          ),
        ),
      ),
    ]);
    ;
  }
}
