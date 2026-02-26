import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'kkxpricy_page.dart';

/// 隐私政策弹窗组件
class PrivacyPolicyDialog extends StatelessWidget {
  /// 隐私政策文本内容（可替换为从网络加载/本地文件读取）
  final String privacyContent;

  /// 同意隐私政策回调
  final VoidCallback onAgree;

  /// 拒绝隐私政策回调（默认退出应用）
  final VoidCallback? onDisagree;

  const PrivacyPolicyDialog({
    super.key,
    required this.privacyContent,
    required this.onAgree,
    this.onDisagree,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // 取消点击外部关闭弹窗
      // barrierDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题区域
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const Text(
                '隐私政策与用户协议',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),

            // 分割线
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // 隐私政策内容区域（可滚动）
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: RichText(text: TextSpan(
                  children: [
                    TextSpan(
                      text: privacyContent,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                    TextSpan(
                      text: "查看隐私政策详细内容",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(context, MaterialPageRoute(builder: (c){
                            return KkxPricyPage();
                          }));
                        },
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        height: 1.5,
                      ),
                    ),
                  ]
                ))
                
                ,
              ),
            ),

            // 按钮区域
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  // 拒绝按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onDisagree ??
                              () {
                            // 退出应用
                            SystemNavigator.pop();
                            // iOS退出方式（需导入foundation库，或使用exit(0)）
                            // exit(0);
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F5),
                        foregroundColor: const Color(0xFF666666),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('拒绝'),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 同意按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAgree,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('同意并继续'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示隐私政策弹窗
  static void show({
    required BuildContext context,
    required String privacyContent,
    required VoidCallback onAgree,
    VoidCallback? onDisagree,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止点击遮罩关闭
      barrierColor: const Color(0x80000000), // 半透明遮罩
      builder: (context) => PrivacyPolicyDialog(
        privacyContent: privacyContent,
        onAgree: onAgree,
        onDisagree: onDisagree,
      ),
    );
  }
}