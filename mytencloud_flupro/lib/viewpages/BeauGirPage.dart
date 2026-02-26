import 'package:flutter/material.dart';

class GirleViewPage extends StatefulWidget {
  String imgurl = "";

  GirleViewPage(this.imgurl);

  @override
  State<GirleViewPage> createState() => _GirleViewPageState();
}

class _GirleViewPageState extends State<GirleViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Hero(tag: widget.imgurl, child: Image.network(widget.imgurl)),
          ),
        ));
  }
}
