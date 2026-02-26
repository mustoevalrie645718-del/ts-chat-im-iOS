import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PricyPage extends StatefulWidget {
  String tag='';

  PricyPage({Key? key, required this.tag}) : super(key: key);

  @override
  State<PricyPage> createState() => _PricyPageState();
}
// https://www.termsfeed.com/live/994522c1-4a67-4e45-9223-172b54191e6d
class _PricyPageState extends State<PricyPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Privacy"),
        ),
        body: bodyWidget);
  }

  get bodyWidget => InAppWebView(
    initialUrlRequest: URLRequest(
      url: WebUri("http://www.cssdcloud.xyz/king/privacyAgreement.html"),
    ),
  );
}
