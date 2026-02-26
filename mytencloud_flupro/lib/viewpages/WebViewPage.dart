import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewPages extends StatefulWidget {
  String url = "";
  ChromeSafariBrowser browser = ChromeSafariBrowser();

  WebViewPages(this.url);

  @override
  _WebViewPagesState createState() => _WebViewPagesState();
}

class _WebViewPagesState extends State<WebViewPages> {
  final GlobalKey webViewKey = GlobalKey();
  bool isloading = false;
  late InAppWebViewController webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
        supportMultipleWindows: true,
        allowFileAccess: true,
        needInitialFocus: true,
        useShouldInterceptRequest: true,
        useHybridComposition: true,
        allowContentAccess: true),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );
  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    // var isp = await Permission.camera.isGranted;
    // if (!isp) {
    //   await Permission.camera.request();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("隐私政策及协议"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: feedQizi(),
              ),
              // busfe(),
            ],
          ),
        ));
  }

  Row rowBuildView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        IconButton(
            onPressed: () {
              webViewController.canGoBack().then((value) {
                if (value) {
                  webViewController.goBack();
                }
              });
              // setState(() {});
            },
            icon: const Image(
              image: AssetImage('assets/images/nar_web1.png'),
            )),
        IconButton(
            onPressed: () {
              webViewController.canGoForward().then((value) {
                if (value) {
                  webViewController.goForward();
                }
              });
            },
            icon: const Image(
              image: AssetImage('assets/images/nar_web2.png'),
            )),
        IconButton(
            onPressed: () {
              webViewController.loadUrl(
                  // urlRequest: URLRequest(url: Uri.parse(widget.url)));
                  urlRequest: URLRequest(url: WebUri(widget.url)));
            },
            icon: const Image(
              image: AssetImage('assets/images/nar_web3.png'),
            )),
        IconButton(
            onPressed: () {
              webViewController.reload();
            },
            icon: const Image(
              image: AssetImage('assets/images/nar_web4.png'),
            )),
      ],
    );
  }

  void localBorder() async {
    await widget.browser.open(
        // url: Uri.parse(widget.url),
        url: WebUri(widget.url),
        options: ChromeSafariBrowserClassOptions(
            android: AndroidChromeCustomTabsOptions(
                shareState: CustomTabsShareState.SHARE_STATE_OFF),
            ios: IOSSafariOptions(barCollapsingEnabled: true)));
  }

  feedQizi() {
    return InAppWebView(
      key: webViewKey,
      initialOptions: options,
      // initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      onProgressChanged: (con, pro) {
        // print("卡卡西进度$pro");
        if (pro == 100) {
          isloading = false;
        } else {
          isloading = true;
        }
      },
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      androidOnPermissionRequest: (contral, navi, resources) async {
        return PermissionRequestResponse(
            resources: resources,
            action: PermissionRequestResponseAction.GRANT);
      },
      onWebViewCreated: (controller) async {
        webViewController = controller;
      },
      onConsoleMessage: (controller, msg) {},
      onLoadStop: (controller, url) {
        controller.addJavaScriptHandler(
            handlerName: "goHistory",
            callback: (value) {
              print("卡卡西androidJsonLoadStop>${value.toString()}");
            });
        controller.addWebMessageListener(WebMessageListener(
            jsObjectName: "goHistory",
            onPostMessage: (val1, val2, val3, val4) {
              print("卡卡西aaddWebMessageListener${val1}");
            }));
        controller.addJavaScriptHandler(
            handlerName: "android",
            callback: (value) {
              print("卡卡西androidJsonLoadStop>${value.toString()}");
            });
        print("卡卡西onLoadStop>${url}");
      },
    );
  }
}
