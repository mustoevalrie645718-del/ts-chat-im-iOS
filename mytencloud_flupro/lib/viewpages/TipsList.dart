import 'package:flutter/material.dart';

import '../tools/style_utils.dart';

class PartListView extends StatefulWidget {
  const PartListView({Key? key}) : super(key: key);

  @override
  _PartListViewState createState() => _PartListViewState();
}

class _PartListViewState extends State<PartListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('我们的那些年'),
        ),
        body: buildListView());
  }

  buildListView() {
    return Container(
      width: double.infinity,
      decoration: bgBoxLI("assets/images/bg_first_sp1.png"),
      child: Column(
        children: <Widget>[Text('dww')],
      ),
    );
  }
}
