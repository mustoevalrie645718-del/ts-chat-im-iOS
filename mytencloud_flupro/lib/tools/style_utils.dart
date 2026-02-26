import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'my_colors.dart';

BoxDecoration containBoxDecoration(String imgurl,
    {double? opact, BoxFit? fit}) {
  return BoxDecoration(
      image: DecorationImage(
          opacity: opact ?? 1,
          fit: fit ?? BoxFit.fill,
          image: AssetImage(imgurl)));
}

class StyleUtilsUtils {
  //通用渐变色主题
  static BoxDecoration mainBoxBackDecoration() {
    return const BoxDecoration(
        gradient: LinearGradient(
            colors: [MyColors.color_main, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.center));
  }

  static BoxDecoration bottomBoxBackDecoration() {
    return const BoxDecoration(
        gradient: LinearGradient(
            colors: [MyColors.color_main, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter));
  }

  static BoxDecoration bottomBoxBackBackDecorationtomor() {
    return const BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xff415612), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter));
  }
}

//背景图片本地
BoxDecoration bgBoxLI(String img) {
  return BoxDecoration(
      image: DecorationImage(image: AssetImage(img), fit: BoxFit.fill));
}
