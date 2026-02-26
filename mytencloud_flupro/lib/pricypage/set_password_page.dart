import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/stylesutil/SharedPreferenceUtil.dart';

class SetPasswordPage extends StatefulWidget {
  @override
  _SetPasswordPageState createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordSet = false;

  @override
  void initState() {
    super.initState();
    _checkPasswordStatus();
  }

  void _checkPasswordStatus() async {
    String? password = await SharedPreferenceUtil.getString("app_password");
    setState(() {
      _isPasswordSet = password != null && password.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isPasswordSet ? '修改密码' : '设置密码'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isPasswordSet)
              TextField(
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  labelText: '当前密码',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: '新密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: '确认新密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handlePasswordChange,
              child: Text(_isPasswordSet ? '修改密码' : '设置密码'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePasswordChange() async {
    if (_isPasswordSet) {
      // 修改密码逻辑
      String? currentPassword = await SharedPreferenceUtil.getString("app_password");
      if (_oldPasswordController.text != currentPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('当前密码错误')),
        );
        return;
      }
    }

    if (_newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入新密码')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('两次输入的密码不一致')),
      );
      return;
    }

    await SharedPreferenceUtil.setString("app_password", _newPasswordController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isPasswordSet ? '密码修改成功' : '密码设置成功')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
} 