import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'MainHomeActivity.dart';
import 'viewpages/Splash.dart';
import 'tools/my_colors.dart';

void main() async {
  SystemUiOverlayStyle systemUiOverlayStyle =
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  WidgetsFlutterBinding.ensureInitialized();

  // runApp(MyHomeApp());
}

// class MyHomeApp extends StatelessWidget {
//   const MyHomeApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context);
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'LsKing',
//       theme: ThemeData.from(
//         colorScheme: const ColorScheme.light(
//             secondary: Colors.green, primary: MyColors.color_main),
//       ).copyWith(
//         pageTransitionsTheme: const PageTransitionsTheme(
//           builders: <TargetPlatform, PageTransitionsBuilder>{
//             TargetPlatform.android: ZoomPageTransitionsBuilder(),
//           },
//         ),
//       ),
//       routes: <String, WidgetBuilder>{
//         '/myhome': (context) => const MainPage(),
//       },
//       // locale: const Locale('zh'),
//       // supportedLocales: S.delegate.supportedLocales,
//       // localizationsDelegates: const [
//       //   S.delegate,
//       //   GlobalMaterialLocalizations.delegate,
//       //   GlobalWidgetsLocalizations.delegate,
//       //   GlobalCupertinoLocalizations.delegate,
//       // ],
//       home: const SplashPage(),
//     );
//   }
// }
