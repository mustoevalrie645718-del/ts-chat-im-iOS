import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../bean/photo_bean.dart';
import 'package:mytencloud_flupro/bean/waterfall_item.dart';
import 'package:mytencloud_flupro/viewpages/share_image_page.dart';

class WaterfallDetailPage extends StatelessWidget {
  final PhotoBean item;

  const WaterfallDetailPage({Key? key,  required this.item}) : super(key: key);

  Future<void> _saveImage(BuildContext context) async {
    // final result = await ImageSaverUtil.saveNetworkImage(
    //   item.imageUrl,
    //   fileName: "${item.title}_${DateTime.now().millisecondsSinceEpoch}.jpg"
    // );
    // ImageSaverUtil.showSaveResult(context, result);
  }

  void _navigateToSharePage(BuildContext context) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareImagePage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 全屏图片
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.network(
                item.imageUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 16),
                        Text(
                          '图片加载失败',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // 顶部返回按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // 底部按钮组
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _navigateToSharePage(context),
                  icon: Icon(Icons.share),
                  label: Text('分享图片'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shadowColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 