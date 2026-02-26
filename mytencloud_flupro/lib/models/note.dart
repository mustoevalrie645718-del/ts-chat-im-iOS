import 'package:flutter/material.dart';

class Note {
   String id='';
   String title='';
   String content='';
   String type=''; // 'thought', 'inspiration', 'reading', 'life'
   DateTime createdAt=DateTime.now();
   DateTime updatedAt=DateTime.now();

  Note({
    required this.id,
    required this.title,
    required this.content,
     this.type = 'thought',
    required  this.createdAt,
    required  this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: json['type'] ?? 'thought',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // 获取类型对应的颜色
  Color getTypeColor() {
    switch (type) {
      case 'thought':
        return Color(0xFFE3F2FD); // 浅蓝色
      case 'inspiration':
        return Color(0xFFE8F5E9); // 浅绿色
      case 'reading':
        return Color(0xFFFFF3E0); // 浅橙色
      case 'life':
        return Color(0xFFF3E5F5); // 浅紫色
      default:
        return Color(0xFFE3F2FD);
    }
  }

  // 获取类型对应的图标
  IconData getTypeIcon() {
    switch (type) {
      case 'thought':
        return Icons.psychology;
      case 'inspiration':
        return Icons.lightbulb;
      case 'reading':
        return Icons.book;
      case 'life':
        return Icons.favorite;
      default:
        return Icons.note;
    }
  }

  // 获取类型对应的中文名称
  String getTypeName() {
    switch (type) {
      case 'thought':
        return '思考';
      case 'inspiration':
        return '灵感';
      case 'reading':
        return '读书';
      case 'life':
        return '生活';
      default:
        return '思考';
    }
  }
}

class DailyQuote {
   String title='';
   String content='';
   String type='';
   Color backgroundColor=Colors.white;

  DailyQuote({
    required this.title,
    required this.content,
    required this.type,
    required this.backgroundColor,
  });

  static List<DailyQuote> quotes = [
    DailyQuote(
      title: '关于成长',
      content: '成长不是一蹴而就的，而是日积月累的过程。每天进步一点点，终将成就非凡。',
      type: 'thought',
      backgroundColor: Color(0xFFE3F2FD),
    ),
    DailyQuote(
      title: '关于坚持',
      content: '坚持不是一时的热情，而是持续的行动。每一个伟大的成就，都源于平凡的坚持。',
      type: 'inspiration',
      backgroundColor: Color(0xFFE8F5E9),
    ),
    DailyQuote(
      title: '关于阅读',
      content: '读书不是为了记住，而是为了思考。每一本书都是一扇窗，让我们看到更广阔的世界。',
      type: 'reading',
      backgroundColor: Color(0xFFFFF3E0),
    ),
    DailyQuote(
      title: '关于生活',
      content: '生活不是等待暴风雨过去，而是学会在雨中翩翩起舞。',
      type: 'life',
      backgroundColor: Color(0xFFF3E5F5),
    ),
    DailyQuote(
      title: '关于工作',
      content: '工作不是生活的全部，但也是重要的一部分。',
      type: 'work',
      backgroundColor: Color(0xFFF3E5F5),
    ),
  ];
} 