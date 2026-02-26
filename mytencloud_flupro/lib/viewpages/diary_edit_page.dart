import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/bean/diary_bean.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../tools/my_colors.dart';

class DiaryEditPage extends StatefulWidget {
  final DiaryBean diary;

  const DiaryEditPage({Key? key, required this.diary}) : super(key: key);

  @override
  _DiaryEditPageState createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends State<DiaryEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  String _selectedMood = '平静';
  String _selectedWeather = '';
  DateTime _selectedDate = DateTime.now();
  String _selectedBackground = 'assets/images/diary/bg_diary1.jpg';
  String _selectedFont = '默认字体';
  List<String> _images = [];
  final _dateFormat = DateFormat('yyyy-MM-dd');

  final List<String> _moods = ['开心', '平静', '难过', '生气'];
  final List<String> _weathers = ['晴天', '多云', '阴天', '雨天', '雪天'];
  final List<String> _backgrounds = [
    'assets/images/diary/bg_diary1.jpg',
    'assets/images/diary/bg_diary2.jpg',
    'assets/images/diary/bg_diary3.jpg',
    'assets/images/diary/bg_diary4.jpg',
    'assets/images/diary/bg_diary5.jpg',
  ];
  final List<String> _fonts = ['默认字体', '手写体', '楷体', '宋体'];

  @override
  void initState() {
    super.initState();
    if (widget.diary != null) {
      _contentController.text = widget.diary.content;
      _selectedMood = widget.diary.mood;
      _selectedWeather = widget.diary.weather;
      _selectedDate = _dateFormat.parse(widget.diary.date);
      _images = List.from(widget.diary.images);
      _selectedBackground = widget.diary.background;
      _selectedFont = widget.diary.font;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color_main3,
      appBar: AppBar(
          backgroundColor: MyColors.color_main3,
        title: Text(widget.diary?.id == null ? '写日记' : '编辑日记'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDiary,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // 顶部功能区
            Container(
              margin: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 心情选择
                  DropdownButton<String>(
                    value: _selectedMood,
                    items: _moods.map((String mood) {
                      return DropdownMenuItem<String>(
                        value: mood,
                        child: Row(
                          children: [
                            Icon(
                              _getMoodIcon(mood),
                              color: _getMoodColor(mood),
                            ),
                            SizedBox(width: 8),
                            Text(mood),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedMood = newValue;
                        });
                      }
                    },
                  ),
                  // 天气选择
                  DropdownButton<String>(
                    value: _selectedWeather,
                    items: [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('天气'),
                      ),
                      ..._weathers.map((String weather) {
                        return DropdownMenuItem<String>(
                          value: weather,
                          child: Row(
                            children: [
                              Icon(_getWeatherIcon(weather)),
                              SizedBox(width: 8),
                              Text(weather),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedWeather = newValue ?? '';
                      });
                    },
                  ),
                  // 日期选择
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text(_dateFormat.format(_selectedDate)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 内容编辑区
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 15,right: 15,top: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                      image: AssetImage(_selectedBackground),
                      fit: BoxFit.cover,opacity: 0.4
                  ),
                ),
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: '今天发生了什么...',
                    prefixIconColor: MyColors.color_main3,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: null,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: _getFontFamily(_selectedFont),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入内容';
                    }
                    return null;
                  },
                ),
              ),
            ),
            // 底部功能区
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 背景选择
                  PopupMenuButton<String>(
                    icon: Icon(Icons.photo),
                    onSelected: (String background) {
                      setState(() {
                        _selectedBackground = background;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return _backgrounds.map((String background) {
                        return PopupMenuItem<String>(
                          value: background,
                          child: Container(
                            width: 100,
                            height: 60,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(background),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
                  // 字体选择
                  PopupMenuButton<String>(
                    icon: Icon(Icons.font_download),
                    onSelected: (String font) {
                      setState(() {
                        _selectedFont = font;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return _fonts.map((String font) {
                        return PopupMenuItem<String>(
                          value: font,
                          child: Text(
                            font,
                            style: TextStyle(
                              fontFamily: _getFontFamily(font),
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveDiary() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final diariesJson = prefs.getStringList('diaries') ?? [];
      final diaries = diariesJson
          .map((json) => DiaryBean.fromJson(jsonDecode(json)))
          .toList();

      final diary = DiaryBean(
        id: widget.diary.id.isEmpty ? Uuid().v4() : widget.diary.id,
        title: _dateFormat.format(_selectedDate),
        content: _contentController.text,
        date: _dateFormat.format(_selectedDate),
        mood: _selectedMood,
        weather: _selectedWeather,
        images: _images,
        background: _selectedBackground,
        font: _selectedFont,
      );

      if (widget.diary.id.isNotEmpty) {
        final index = diaries.indexWhere((d) => d.id == widget.diary.id);
        if (index != -1) {
          diaries[index] = diary;
        }
      } else {
        diaries.add(diary);
      }

      await prefs.setStringList(
        'diaries',
        diaries.map((d) => jsonEncode(d.toJson())).toList(),
      );

      Navigator.pop(context, true); // 返回true表示数据已更新
    }
  }



  String _getFontFamily(String font) {
    switch (font) {
      case '手写体':
        return 'MaShanZheng';
      case '楷体':
        return 'KaiTi';
      case '宋体':
        return 'SimSun';
      default:
        return '';
    }
  }

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
} 