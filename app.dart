import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'core/bindings/init_binding.dart';
import 'core/theme/app_themes.dart';
import 'routes/app_pages.dart';
import 'routes/route_observer.dart';
import 'widgets/app_view.dart';

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppView(
      builder: (locale, builder) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        enableLog: true,
        builder: builder,
        logWriterCallback: Logger.print,
        translations: TranslationService(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        fallbackLocale: TranslationService.fallbackLocale,
        locale: locale,
        localeResolutionCallback: (locale, list) {
          Get.locale ??= locale;
          return locale;
        },
        supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
        getPages: AppPages.routes,
        initialBinding: InitBinding(),
        initialRoute: AppRoutes.splash,
        navigatorObservers: [routeObserver], // Register route observer for page visibility tracking
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
