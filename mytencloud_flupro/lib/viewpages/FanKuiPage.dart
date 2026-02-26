import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/tools/my_colors.dart';
import 'package:mytencloud_flupro/tools/toast_utils.dart';

class FanKuiPage extends StatefulWidget {
  const FanKuiPage({Key? key}) : super(key: key);

  @override
  State<FanKuiPage> createState() => _FanKuiPageState();
}

class _FanKuiPageState extends State<FanKuiPage> {
  final _contral = TextEditingController();
  int _radioGroupA = 0;
  var isload = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('反馈'),
        ),
        body: jingMing());
  }

  jingMing() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(children: [
        Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "请选择反馈类型：",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
            Row(
              children: <Widget>[
                Radio(
                    value: 0,
                    groupValue: _radioGroupA,
                    onChanged: (value) {
                      setList(value);
                    }),
                const Text("功能"),
                Radio(
                    value: 1,
                    groupValue: _radioGroupA,
                    onChanged: (value) {
                      setList(value);
                    }),
                const Text("数据"),
                Radio(
                    value: 2,
                    groupValue: _radioGroupA,
                    onChanged: (value) {
                      setList(value);
                    }),
                const Text("优化"),
              ],
            ),
            const Divider(
              height: 20,
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "请输入具体的意见或问题：",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
            TextField(
              controller: _contral,
              maxLines: 8,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "请输入",
              ),
            ),
            const Divider(
              height: 10,
            ),
            const Text(
              "tips：如果您有任何疑问，您可以向后台反馈，由相关人员进行处理。",
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
            const Divider(
              height: 80,
            ),
            Center(
              child: Card(
                color: MyColors.color_main,
                child: SizedBox(
                  width: 200,
                  child: CupertinoButton(
                    child: const Text(
                      "submit",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_contral.text.toString().isEmpty) {
                        ToastUtil.showMyToast("请输入您的意见");
                      } else {
                        isload = true;
                        setState(() {});
                        await Future.delayed(const Duration(seconds: 2), () {
                          ToastUtil.showMyToast("提交成功，后台审稿人将定期对其进行验证");
                          Navigator.pop(context);
                        });
                      }
                    },
                  ),
                ),
              ),
            )
          ],
        ),
        Visibility(
            visible: isload,
            child: Center(
              child: CircularProgressIndicator(),
            ))
      ]),
    );
  }

  void setList(value) {
    _radioGroupA = value;
    setState(() {});
  }
}
