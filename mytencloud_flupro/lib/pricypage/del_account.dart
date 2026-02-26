import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mytencloud_flupro/tools/toast_utils.dart';

class DelaccountPage extends StatefulWidget {

  @override
  State<DelaccountPage> createState() => _DelaccountPageState();
}

class _DelaccountPageState extends State<DelaccountPage> {
   int _secondsLeft=0;
  late Timer _timer;
  bool _isCountingDown = false;
  int countdownSeconds = 60;
  TextEditingController _countral = TextEditingController();

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认账户注销?'),
        content: const Text(
            '取消帐户将永久删除数据。你想继续吗?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('SURE'),
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.red,
            ),
            onPressed: () {
              ToastUtil.showMyToast("请检查验证码");
              Navigator.of(ctx).pop(); // 关闭弹窗
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注销账号')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '取消您的帐户将永久删除您的帐户信息，包括登录数据、个人设置和所有相关内容。该操作不可恢复.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            Text("phone :18812345678"),
            TextField(
              controller: _countral,
              autofocus: false,
              decoration: InputDecoration(
                labelText: '验证码',
                hintText: '请输入验证码',
                suffixIcon: ElevatedButton(
                  onPressed: () {
                    _handleTap();
                  },
                  child: Text(
                    _isCountingDown
                        ? '（$_secondsLeft s）后获取验证码'
                        : '获取验证码',
                  ),
                ),
              ),
            ),
            SizedBox(height: 40,),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.red,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () {
                  if (_countral.value.text.isEmpty) {
                    ToastUtil.showMyToast("输入验证码");
                  } else {
                    _showConfirmDialog(context);
                  }
                },
                child: const Text('注销账号'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startCountdown() {
    setState(() {
      _secondsLeft = countdownSeconds;
      _isCountingDown = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
        });
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _handleTap() {
    if (!_isCountingDown) {
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
