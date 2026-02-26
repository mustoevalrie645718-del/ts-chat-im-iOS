import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/bean/diary_bean.dart';
import 'package:mytencloud_flupro/tools/my_colors.dart';
import 'package:mytencloud_flupro/widget/empty_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'diary_edit_page.dart';

class DiaryListPage extends StatefulWidget {
  @override
  _DiaryListPageState createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  List<DiaryBean> _diaries = [];
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _monthFormat = DateFormat('yyyy年MM月');

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    final prefs = await SharedPreferences.getInstance();
    final diariesJson = prefs.getStringList('diaries') ?? [];
    final diaries = diariesJson
        .map((json) => DiaryBean.fromJson(jsonDecode(json)))
        .toList();
    
    // 按日期升序排序（从早到晚）
    diaries.sort((a, b) => a.date.compareTo(b.date));
    
    setState(() {
      _diaries = diaries;
    });
  }

  Future<void> _deleteDiary(DiaryBean diary) async {
    final prefs = await SharedPreferences.getInstance();
    final diariesJson = prefs.getStringList('diaries') ?? [];
    final diaries = diariesJson
        .map((json) => DiaryBean.fromJson(jsonDecode(json)))
        .toList();
    
    diaries.removeWhere((d) => d.id == diary.id);
    
    await prefs.setStringList(
      'diaries',
      diaries.map((d) => jsonEncode(d.toJson())).toList(),
    );
    
    _loadDiaries();
  }

  // 获取心情图标
  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case '开心':
        return Icons.sentiment_very_satisfied;
      case '平静':
        return Icons.sentiment_satisfied;
      case '难过':
        return Icons.sentiment_dissatisfied;
      case '生气':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  // 获取心情颜色
  Color _getMoodColor(String mood) {
    switch (mood) {
      case '开心':
        return Colors.orange;
      case '平静':
        return Colors.green;
      case '难过':
        return Colors.blue;
      case '生气':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 获取天气图标
  IconData _getWeatherIcon(String weather) {
    switch (weather) {
      case '晴天':
        return Icons.wb_sunny;
      case '多云':
        return Icons.cloud;
      case '阴天':
        return Icons.cloud_queue;
      case '雨天':
        return Icons.beach_access;
      case '雪天':
        return Icons.ac_unit;
      default:
        return Icons.wb_sunny;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_diaries.isEmpty) {
      return Scaffold(
        backgroundColor: MyColors.color_main3,
        appBar: AppBar(
          backgroundColor: MyColors.color_main3,
          centerTitle:  true,
          title: const Text('我的日记',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
        ),
        body: Center(
          child:EmptyView(title: '还没有写日记哦',),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: MyColors.color_main3,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiaryEditPage(
                  diary: DiaryBean(
                    id: '',
                    title: '',
                    content: '',
                    date: _dateFormat.format(DateTime.now()),
                    mood: '平静',
                    weather: '',
                    images: [],
                  ),
                ),
              ),
            );
            if (result == true) {
              _loadDiaries();
            }
          },
          child: Icon(Icons.add,color: MyColors.white,),
        ),
      );
    }

    return Scaffold(backgroundColor: MyColors.color_main3,
      appBar: AppBar(backgroundColor: MyColors.color_main3,
        centerTitle:  true,
        title: Text('我的日记',style: const TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDiaries,
        child: ListView.builder(
          itemCount: _diaries.length,
          itemBuilder: (context, index) {
            final diary = _diaries[index];
            final showMonth = index == 0 || 
                _monthFormat.format(_dateFormat.parse(_diaries[index - 1].date)) != 
                _monthFormat.format(_dateFormat.parse(diary.date));

            return Column(
              children: [
                if (showMonth)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    color: MyColors.color_main3,
                    child: Center(
                      child: Text(
                        _monthFormat.format(_dateFormat.parse(diary.date)),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 时间轴
                      Container(
                        width: 60,
                        child: Column(
                          children: [
                            Text(
                              _dateFormat.format(_dateFormat.parse(diary.date)),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 100,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      ),
                      // 日记内容
                      Expanded(
                        child: GestureDetector(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('删除日记'),
                                content: Text('确定要删除这篇日记吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteDiary(diary);
                                    },
                                    child: Text('删除'),
                                    style: TextButton.styleFrom(
                                      shadowColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiaryEditPage(diary: diary),
                              ),
                            );
                            if (result == true) {
                              _loadDiaries();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getMoodIcon(diary.mood),
                                        color: _getMoodColor(diary.mood),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        diary.mood,
                                        style: TextStyle(
                                          color: _getMoodColor(diary.mood),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (diary.weather.isNotEmpty) ...[
                                        SizedBox(width: 16),
                                        Icon(_getWeatherIcon(diary.weather)),
                                        SizedBox(width: 8),
                                        Text(diary.weather),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    diary.content,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                  if (diary.images.isNotEmpty) ...[
                                    SizedBox(height: 12),
                                    Container(
                                      height: 100,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: diary.images.length,
                                        itemBuilder: (context, imageIndex) {
                                          return Container(
                                            width: 100,
                                            margin: EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              image: DecorationImage(
                                                image: AssetImage(diary.images[imageIndex]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryEditPage(
                diary: DiaryBean(
                  id: '',
                  title: '',
                  content: '',
                  date: _dateFormat.format(DateTime.now()),
                  mood: '平静',
                  weather: '',
                  images: [],
                ),
              ),
            ),
          );
          if (result == true) {
            _loadDiaries();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
} 