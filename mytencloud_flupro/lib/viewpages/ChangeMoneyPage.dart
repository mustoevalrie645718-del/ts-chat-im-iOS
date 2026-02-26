import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangeMinPage extends StatefulWidget {
  const ChangeMinPage({Key? key}) : super(key: key);

  @override
  _ChangeMinPageState createState() => _ChangeMinPageState();
}

class _ChangeMinPageState extends State<ChangeMinPage> {
  TextEditingController _TextHaidi = TextEditingController();
  List<double> datalist = [6.8, 6.84, 0.05];
  String result = "";
  int currentindex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('换算'),
          centerTitle: true,
        ),
        body: initDates());
  }

  initDates() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              OutlinedButton(
                  onPressed: () {
                    currentindex = 0;
                    setState(() {});
                  },
                  child: Text("dollar")),
              Spacer(),
              OutlinedButton(
                  onPressed: () {
                    currentindex = 1;
                    setState(() {});
                  },
                  child: Text("euro")),
              Spacer(),
              OutlinedButton(
                  onPressed: () {
                    currentindex = 2;
                    setState(() {});
                  },
                  child: Text("Japanese yen")),
            ],
          ),
          TextField(
            controller: _TextHaidi,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: "Please enter the amount in foreign currency"),
          ),
          Row(
            children: <Widget>[
              const Text("The conversion result is:"),
              OutlinedButton(
                  onPressed: () {},
                  child: Text(
                      "${double.parse(_TextHaidi.text.isEmpty ? "0" : _TextHaidi.text) * datalist[currentindex]}¥"))
            ],
          ),
          MaterialButton(
            color: Colors.black,
            onPressed: () {
              _TextHaidi.text = "";
              setState(() {});
            },
            child: Text(
              "One-click clear",
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Note: Due to the real-time change of exchange rate, no immediate conversion is available at present. The data is for reference only.",
                style: TextStyle(color: Colors.red),
              ))
        ],
      ),
    );
  }
}
