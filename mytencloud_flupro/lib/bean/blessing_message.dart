import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BlessingCategory {
  final String? id;
  final String? name;
  final String? icon;
  final String? description;

  BlessingCategory({
     this.id,
     this.name,
     this.icon,
     this.description,
  });

  factory BlessingCategory.fromJson(Map<String, dynamic> json) {
    return BlessingCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
    };
  }
}

class BlessingMessage {
  final String? id;
  final String? categoryId;
  final String? content;
  bool isFavorite;

  BlessingMessage({
    this.id,
    this.categoryId,
    this.content,
    this.isFavorite = false,
  });

  factory BlessingMessage.fromJson(Map<String, dynamic> json) {
    return BlessingMessage(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      content: json['content'] as String,
      isFavorite: json['isFavorite'] as bool ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'content': content,
      'isFavorite': isFavorite,
    };
  }
}

// 预定义的祝福短信分类
final List<BlessingCategory> blessingCategories = [
  BlessingCategory(
    id: '1',
    name: '节日祝福',
    icon: 'assets/images/diary/ic_sms_1.png',
    description: '春节、中秋、元旦等节日祝福语',
  ),
  BlessingCategory(
    id: '2',
    name: '生日祝福',
    icon: 'assets/images/diary/ic_sms_2.png',
    description: '生日、寿辰祝福语',
  ),
  BlessingCategory(
    id: '3',
    name: '结婚祝福',
    icon: 'assets/images/diary/ic_sms_6.png',
    description: '新婚、结婚纪念日祝福语',
  ),
  BlessingCategory(
    id: '4',
    name: '开业祝福',
    icon: 'assets/images/diary/ic_sms_4.png',
    description: '开业、乔迁、升职祝福语',
  ),
  BlessingCategory(
    id: '5',
    name: '健康祝福',
    icon: 'assets/images/diary/ic_sms_5.png',
    description: '康复、健康祝福语',
  ),
  BlessingCategory(
    id: '6',
    name: '学业祝福',
    icon: 'assets/images/diary/ic_sms_3.png',
    description: '升学、考试、毕业祝福语',
  ),
];

// 预定义的祝福短信内容
final Map<String, List<BlessingMessage>> blessingMessages = {
  '1': [
    BlessingMessage(
      id: '1-1',
      categoryId: '1',
      content: '新春佳节到，祝福送不停。愿您在新的一年里，事业蒸蒸日上，家庭幸福美满，身体健康平安！',
    ),
    BlessingMessage(
      id: '1-2',
      categoryId: '1',
      content: '中秋月圆人团圆，祝福声声传千里。愿您阖家欢乐，幸福安康，万事如意！',
    ),
    BlessingMessage(
      id: '1-3',
      categoryId: '1',
      content: '元旦快乐！愿新的一年里，您事业腾飞，生活美满，幸福安康！',
    ),
    BlessingMessage(
      id: '1-4',
      categoryId: '1',
      content: '元宵佳节到，祝您阖家团圆，幸福美满，万事如意！',
    ),
    BlessingMessage(
      id: '1-5',
      categoryId: '1',
      content: '端午安康！愿您生活如粽子般甜蜜，事业如龙舟般腾飞！',
    ),
  ],
  '2': [
    BlessingMessage(
      id: '2-1',
      categoryId: '2',
      content: '生日快乐！愿您在新的一岁里，心想事成，万事如意，幸福安康！',
    ),
    BlessingMessage(
      id: '2-2',
      categoryId: '2',
      content: '祝您福如东海，寿比南山，年年有今日，岁岁有今朝！',
    ),
    BlessingMessage(
      id: '2-3',
      categoryId: '2',
      content: '愿您生日快乐，青春永驻，幸福安康！',
    ),
    BlessingMessage(
      id: '2-4',
      categoryId: '2',
      content: '祝您生日快乐，前程似锦，万事如意！',
    ),
    BlessingMessage(
      id: '2-5',
      categoryId: '2',
      content: '愿您生日快乐，事业有成，家庭美满！',
    ),
  ],
  '3': [
    BlessingMessage(
      id: '3-1',
      categoryId: '3',
      content: '祝你们新婚快乐，百年好合，永结同心，白头偕老！',
    ),
    BlessingMessage(
      id: '3-2',
      categoryId: '3',
      content: '愿你们的爱情如美酒般醇香，如蜜糖般甜蜜，幸福美满！',
    ),
    BlessingMessage(
      id: '3-3',
      categoryId: '3',
      content: '祝你们新婚快乐，早生贵子，幸福美满！',
    ),
    BlessingMessage(
      id: '3-4',
      categoryId: '3',
      content: '愿你们执子之手，与子偕老，幸福美满！',
    ),
    BlessingMessage(
      id: '3-5',
      categoryId: '3',
      content: '祝你们新婚快乐，百年好合，幸福美满！',
    ),
  ],
  '4': [
    BlessingMessage(
      id: '4-1',
      categoryId: '4',
      content: '开业大吉，生意兴隆，财源广进，万事如意！',
    ),
    BlessingMessage(
      id: '4-2',
      categoryId: '4',
      content: '乔迁之喜，新居如意，生活美满，幸福安康！',
    ),
    BlessingMessage(
      id: '4-3',
      categoryId: '4',
      content: '祝您升职加薪，前程似锦，事业腾飞！',
    ),
    BlessingMessage(
      id: '4-4',
      categoryId: '4',
      content: '开业大吉，财源广进，生意兴隆！',
    ),
    BlessingMessage(
      id: '4-5',
      categoryId: '4',
      content: '乔迁之喜，新居如意，幸福安康！',
    ),
  ],
  '5': [
    BlessingMessage(
      id: '5-1',
      categoryId: '5',
      content: '祝您早日康复，身体健康，平安喜乐！',
    ),
    BlessingMessage(
      id: '5-2',
      categoryId: '5',
      content: '愿您身体康健，精神焕发，幸福安康！',
    ),
    BlessingMessage(
      id: '5-3',
      categoryId: '5',
      content: '祝您早日康复，身体健康，万事如意！',
    ),
    BlessingMessage(
      id: '5-4',
      categoryId: '5',
      content: '愿您身体康健，平安喜乐，幸福安康！',
    ),
    BlessingMessage(
      id: '5-5',
      categoryId: '5',
      content: '祝您早日康复，身体健康，生活美满！',
    ),
  ],
  '6': [
    BlessingMessage(
      id: '6-1',
      categoryId: '6',
      content: '祝您金榜题名，前程似锦，学业有成！',
    ),
    BlessingMessage(
      id: '6-2',
      categoryId: '6',
      content: '愿您学有所成，前程似锦，未来可期！',
    ),
    BlessingMessage(
      id: '6-3',
      categoryId: '6',
      content: '祝您考试顺利，金榜题名，前程似锦！',
    ),
    BlessingMessage(
      id: '6-4',
      categoryId: '6',
      content: '愿您学业有成，前程似锦，未来可期！',
    ),
    BlessingMessage(
      id: '6-5',
      categoryId: '6',
      content: '祝您考试顺利，金榜题名，前程似锦！',
    ),
  ],
};

// 获取收藏的祝福短信
Future<List<BlessingMessage>> getFavoriteBlessings() async {
  final prefs = await SharedPreferences.getInstance();
  final favoritesJson = prefs.getString('favorite_blessings') ?? '[]';
  final favorites = (jsonDecode(favoritesJson) as List)
      .map((e) => BlessingMessage.fromJson(e))
      .toList();
  return favorites;
}

// 添加收藏
Future<void> addFavorite(BlessingMessage message) async {
  final prefs = await SharedPreferences.getInstance();
  final favoritesJson = prefs.getString('favorite_blessings') ?? '[]';
  final favorites = (jsonDecode(favoritesJson) as List)
      .map((e) => BlessingMessage.fromJson(e))
      .toList();
  
  if (!favorites.any((m) => m.id == message.id)) {
    favorites.add(message);
    await prefs.setString(
      'favorite_blessings',
      jsonEncode(favorites.map((e) => e.toJson()).toList()),
    );
  }
}

// 取消收藏
Future<void> removeFavorite(String messageId) async {
  final prefs = await SharedPreferences.getInstance();
  final favoritesJson = prefs.getString('favorite_blessings') ?? '[]';
  final favorites = (jsonDecode(favoritesJson) as List)
      .map((e) => BlessingMessage.fromJson(e))
      .toList();
  
  favorites.removeWhere((m) => m.id == messageId);
  await prefs.setString(
    'favorite_blessings',
    jsonEncode(favorites.map((e) => e.toJson()).toList()),
  );
}

// 检查是否已收藏
Future<bool> isFavorite(String messageId) async {
  final prefs = await SharedPreferences.getInstance();
  final favoritesJson = prefs.getString('favorite_blessings') ?? '[]';
  final favorites = (jsonDecode(favoritesJson) as List)
      .map((e) => BlessingMessage.fromJson(e))
      .toList();
  
  return favorites.any((m) => m.id == messageId);
} 