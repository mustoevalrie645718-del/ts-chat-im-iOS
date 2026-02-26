import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/viewpages/WebViewPage.dart';

class KkxPricyPage extends StatelessWidget {
  const KkxPricyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: bodyWidget);
  }
  get bodyWidget => WebViewPages("https://app.asdap.xin/privacy.html");
}
