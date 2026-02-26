import 'package:flutter/material.dart';

class KissViewPage extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final IconData myiconData;
  final double size;
  final Color textColor;

  const KissViewPage({
    Key? key,
    required this.color,
    required this.text,
    required this.myiconData,
    required this.isSquare,
    this.size = 12,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Icon(myiconData),
        Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        )
      ],
    );
  }
}
