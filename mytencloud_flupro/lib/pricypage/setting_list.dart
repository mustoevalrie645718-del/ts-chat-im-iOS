import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/pricypage/pricy_page.dart';
import 'package:mytencloud_flupro/pricypage/set_password_page.dart';

import 'del_account.dart';

class SettingListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('安全'),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text('设置密码'),
              leading: Icon(Icons.lock),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (cxt) {
                  return SetPasswordPage();
                }));
              },
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              title: Text('隐私政策'),
              leading: Icon(Icons.account_circle),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (cxt) {
                  return PricyPage(tag: '',);
                }));
              },
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              title: Text('注销账户'),
              leading: Icon(Icons.account_circle),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (cxt) {
                  return DelaccountPage();
                }));
              },
              trailing: Icon(Icons.arrow_forward_ios),
            )
          ],
        ));
  }
}
