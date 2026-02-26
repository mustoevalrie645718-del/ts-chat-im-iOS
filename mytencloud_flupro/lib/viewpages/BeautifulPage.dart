import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/bean/photo_bean.dart';

import '../tools/my_colors.dart';
import 'waterfall_detail_page.dart';

class BeautifulPage extends StatefulWidget {
  @override
  State<BeautifulPage> createState() => _BeautifulPageState();
}

class _BeautifulPageState extends State<BeautifulPage> {
  get bodyWidget => GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: photoList.length,
      itemBuilder: (ctx, index) {
        return InkWell(
          onTap: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (xtc) {
                  return WaterfallDetailPage(item: photoList[index]);
                }));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              photoList[index].imageUrl!,
              fit: BoxFit.cover,
            ),
          ),
        );
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColors.color_main2,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
          ),
          backgroundColor: MyColors.color_main2,
          title: const Text('美图鉴赏',style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
        ),
        body: bodyWidget);
  }
}
