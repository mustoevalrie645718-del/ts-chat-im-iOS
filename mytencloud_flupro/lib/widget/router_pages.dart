import 'package:flutter/cupertino.dart';

//从下弹出路由
Route createRoute(Widget newpage) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => newpage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0, 1);
        const end = Offset.zero;
        const curve = Curves.easeIn;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}
