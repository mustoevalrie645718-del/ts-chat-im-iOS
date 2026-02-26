import 'dart:convert';

class DiaryBean {
  final String id;
  final String title;
  final String content;
  final String date;
  final String mood;
  final String weather;
  final List<String> images;
  final String background;
  final String font;

  DiaryBean({
    this.id = '',
    this.title = '',
    this.content = '',
    this.date = '',
    this.mood = '平静',
    this.weather = '',
    this.images = const [],
    this.background = 'assets/images/diary/bg1.jpg',
    this.font = '默认字体',
  });

  // 从JSON转换为对象
  factory DiaryBean.fromJson(Map<String, dynamic> json) {
    return DiaryBean(
      id: json['id'] as String ?? '',
      title: json['title'] as String ?? '',
      content: json['content'] as String ?? '',
      date: json['date'] as String ?? '',
      mood: json['mood'] as String ?? '平静',
      weather: json['weather'] as String ?? '',
      images: List<String>.from(json['images'] as List ?? []),
      background: json['background'] as String ?? 'assets/images/diary/bg1.jpg',
      font: json['font'] as String ?? '默认字体',
    );
  }

  // 从对象转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
      'weather': weather,
      'images': images,
      'background': background,
      'font': font,
    };
  }

  // 创建新的日记对象（用于编辑时创建副本）
  DiaryBean copyWith({
    String? id,
    String? title,
    String? content,
    String? date,
    String? mood,
    String? weather,
    List<String>? images,
    String? background,
    String? font,
  }) {
    return DiaryBean(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      weather: weather ?? this.weather,
      images: images ?? List.from(this.images),
      background: background ?? this.background,
      font: font ?? this.font,
    );
  }

  @override
  String toString() {
    return 'DiaryBean{id: $id, title: $title, date: $date, mood: $mood, weather: $weather}';
  }
} 