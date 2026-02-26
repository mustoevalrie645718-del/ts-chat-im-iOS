import 'package:flutter/material.dart';

class UserLetterPage extends StatelessWidget {
final str=
    "非常感谢您选择并使用我们的应用！在如今应用选择丰富的时代，能够成为您的选择，我们深感荣幸。您的支持是我们不断进步和前行的动力。"
    "我们始终坚持以用户为中心的理念，力求在功能、体验和服务各方面做到更好。每一次点击、每一次使用，都是对我们的信任与肯定。我们也在不断倾听用户的声音，不断优化产品，希望为您带来更便捷、更愉悦的使用体验。"
    "如果您在使用过程中有任何建议、想法或遇到的问题，欢迎随时告诉我们。我们非常重视每一位用户的反馈，并将认真倾听和改进。您的满意是我们最大的追求。"
    "再次感谢您对我们的支持与信任。未来的日子里，我们将继续努力，不负所托！\n"
"此致"
"敬礼！\n"
"—— 您的应用开发团队";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('鸣谢'),
        ),
        body: Container(
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(15),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEDF2FA),
                Color(0xFFE5E5E5),
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child:  Text.rich(TextSpan(
            children: [
              const TextSpan(text: "尊敬的用户您好:\n",style:
              const TextStyle(fontSize: 22,fontWeight: FontWeight.bold)),
              const WidgetSpan(child: Divider(height: 10,)),
              TextSpan(text: str,style: const TextStyle(fontSize: 18,
              letterSpacing: 2)),
              const WidgetSpan(
                  child: Image(
                    width: 30,height: 30,
                    image: AssetImage("assets/images/applogo.jpg"),))
            ],
          )),
        ));

  }
}
