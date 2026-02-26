import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';

class AccountDeletionPage extends StatefulWidget {
   AccountDeletionPage({super.key});

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  bool _isDeleting = false;

  Future<void> _handleAccountDeletion() async {
    // 显示确认对话框
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text('del_2'.tr),
          content:  Text(
            'del_3'.tr+"\n\n"
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:  Text('del_6'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child:  Text('del_7'.tr),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isDeleting = true;
      });

      // 模拟注销请求
      await Future.delayed( Duration(seconds: 2));

      if (mounted) {
        // 显示注销成功对话框
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title:  Text('Tips'),
              content:  Text('del_8'.tr),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 返回到登录页面或首页
                    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx){
                    //   return LoginPage();
                    // }), (route) => false);
                    // AppNavigator.startLogin();
                    Get.offAllNamed(AppRoutes.login);
                    // Navigator.of(context).popUntil((route) => LoginPage());
                  },
                  child:  Text('del_9'.tr),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('del_10'.tr),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding:  EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 警告图标和标题
            Center(
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 80,
                    color: Colors.orange.shade400,
                  ),
                   SizedBox(height: 16),
                  Text(
                    'del_11'.tr,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
             SizedBox(height: 32),

            // 警告信息卡片
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding:  EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.info_outline,
                          color: Colors.red.shade700,
                        ),
                         SizedBox(width: 8),
                        Text(
                          'del_11'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                     SizedBox(height: 12),
                    Text(
                      'del_12'.tr,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                     SizedBox(height: 8),
                    _buildWarningItem('del_13'.tr),
                    _buildWarningItem('del_14'.tr),
                  ],
                ),
              ),
            ),
             SizedBox(height: 24),

            // 说明文字
            Text(
              'del_15'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
             SizedBox(height: 8),
            Text(
              "del_16".tr+'•\n',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
            ),
             SizedBox(height: 32),

            // 注销按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isDeleting ? null : _handleAccountDeletion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:  EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isDeleting
                    ?  SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    :  Text(
                        'del_18'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
             SizedBox(height: 16),

            // 取消按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding:  EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:  Text(
                  'del_6'.tr,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding:  EdgeInsets.only(top: 4.0),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.remove_circle_outline,
            size: 16,
            color: Colors.red.shade700,
          ),
           SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

