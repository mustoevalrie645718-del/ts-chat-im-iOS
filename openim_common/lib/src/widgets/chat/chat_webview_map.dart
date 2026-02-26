import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS/macOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// aMap
class ChatWebViewMap extends StatefulWidget {
  const ChatWebViewMap({
    super.key,
    required this.host,
    required this.webKey,
    required this.webServerKey,
    this.mapThumbnailSize = "1200*600",
    this.mapBackUrl = "http://callback",
    this.latitude,
    this.longitude,
  });

  final String host;
  final String webKey;
  final String webServerKey;
  final String mapThumbnailSize;
  final String mapBackUrl;
  final double? latitude;
  final double? longitude;

  @override
  State<ChatWebViewMap> createState() => _ChatWebViewMapState();
}

class _ChatWebViewMapState extends State<ChatWebViewMap> {
  WebViewController? _controller;

  String url = "";
  double progress = 0;
  double? latitude;
  double? longitude;
  String? description;

  /// 定位获取
  late String locationUrl;
  late String thumbnailUrl;

  /// 根据定位坐标预览
  late String previewLocationUrl;

  late String webKey;
  late String webServerKey;
  late String host;

  void _configUrl() {
    locationUrl = "$host?key=$webKey&serverKey=$webServerKey#/";
    previewLocationUrl = "$host?key=$webKey&serverKey=$webServerKey&location=$longitude,$latitude#/";
  }

  String getStaticMapURL(double longitude, double latitude) {
    final url =
        'https://restapi.amap.com/v3/staticmap?location=$longitude,$latitude&zoom=13&size=200*200&markers=mid,,A:$longitude,$latitude&key=$webServerKey';

    return url;
  }

  bool get isPreview => widget.longitude != null && widget.latitude != null;

  @override
  void initState() {
    super.initState();
    host = widget.host;
    webKey = widget.webKey;
    webServerKey = widget.webServerKey;

    longitude = widget.longitude;
    latitude = widget.latitude;

    _determinePosition().then((position) {
      longitude = position.longitude;
      latitude = position.latitude;

      _configUrl();

      // #docregion platform_features
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
      // #enddocregion platform_features

      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              debugPrint('WebView is loading (progress : $progress%)');
              setState(() {
                this.progress = progress / 100;
              });
            },
            onPageStarted: (String url) {
              debugPrint('Page started loading: $url');
            },
            onPageFinished: (String url) {
              debugPrint('Page finished loading: $url');
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint(
                  'Page resource error: code: ${error.errorCode} description: ${error.description} errorType: ${error.errorType} isForMainFrame: ${error.isForMainFrame}');
            },
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                debugPrint('blocking navigation to ${request.url}');
                return NavigationDecision.prevent;
              }
              debugPrint('allowing navigation to ${request.url}');
              return NavigationDecision.navigate;
            },
            onHttpError: (HttpResponseError error) {
              debugPrint('Error occurred on page: ${error.response?.statusCode}');
            },
            onUrlChange: (UrlChange change) {
              debugPrint('url change to ${change.url}');
            },
            onHttpAuthRequest: (HttpAuthRequest request) {},
          ),
        )
        ..addJavaScriptChannel(
          'getLocaltion',
          onMessageReceived: (JavaScriptMessage message) {
            final value = message.message;
            final params = jsonDecode(value);
            final locationStr = params['location'] as String;
            final locations = locationStr.split(',');
            longitude = double.parse(locations[0]);
            latitude = double.parse(locations[1]);
            final address = params['address'];
            final url = getStaticMapURL(longitude!, latitude!);

            final result = {
              'longitude': longitude,
              'latitude': latitude,
              'url': url,
              'addr': address,
              'name': '',
            };

            description = jsonEncode(result);
            Logger.print('$result');

            _confirm();
          },
        )
        ..loadRequest(Uri.parse(previewLocationUrl));

      print('previewLocationUrl: $previewLocationUrl');
      // setBackgroundColor is not currently supported on macOS.
      if (!Platform.isMacOS) {
        controller.setBackgroundColor(const Color(0x80000000));
      }

      // #docregion platform_features
      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);

        (controller.platform as AndroidWebViewController)
          ..setMediaPlaybackRequiresUserGesture(false)
          ..setUseWideViewPort(true);
      }
      // #enddocregion platform_features

      setState(() {
        _controller = controller;
      });
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _confirm() async {
    if (null == latitude || null == longitude) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: StrRes.plsSelectLocation.toText..style = Styles.ts_0C1C33_17sp_semibold,
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.translucent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: StrRes.determine.toText..style = Styles.ts_0089FF_17sp_semibold,
              ),
            ),
          ],
        ),
      );
      return;
    }
    Navigator.pop(context, {
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TitleBar.back(
        onTap: () async {
          Get.back();
        },
        title: StrRes.location,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _controller == null
                ? const Align(
                    child: CupertinoActivityIndicator(),
                  )
                : WebViewWidget(controller: _controller!),
            progress < 1.0
                ? LinearProgressIndicator(
                    value: progress,
                    color: Colors.blue,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
