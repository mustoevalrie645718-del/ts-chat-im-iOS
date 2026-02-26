import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mytencloud_flupro/bean/blessing_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../tools/my_colors.dart';
import 'add_blessing_page.dart';

class BlessingListPage extends StatefulWidget {
  final BlessingCategory category;

  const BlessingListPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  _BlessingListPageState createState() => _BlessingListPageState();
}

class _BlessingListPageState extends State<BlessingListPage> {
  List<BlessingMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final customBlessingsJson = prefs.getString('custom_blessings') ?? '{}';
      final customBlessings = Map<String, List<BlessingMessage>>.from(
        jsonDecode(customBlessingsJson).map(
          (key, value) => MapEntry(
            key,
            (value as List).map((e) => BlessingMessage.fromJson(e)).toList(),
          ),
        ),
      );

      final defaultMessages = blessingMessages[widget.category.id] ?? [];
      final customCategoryMessages = customBlessings[widget.category.id] ?? [];

      // 获取收藏状态
      final favoritesJson = prefs.getString('favorite_blessings') ?? '[]';
      final favorites = (jsonDecode(favoritesJson) as List)
          .map((e) => BlessingMessage.fromJson(e))
          .toList();
      final favoriteIds = favorites.map((e) => e.id).toSet();

      // 更新消息的收藏状态
      final allMessages = [...defaultMessages, ...customCategoryMessages];
      for (var message in allMessages) {
        message.isFavorite = favoriteIds.contains(message.id);
      }

      setState(() {
        _messages = allMessages;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败：$e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(BlessingMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorite_blessings') ?? '[]';
      final favorites = (jsonDecode(favoritesJson) as List)
          .map((e) => BlessingMessage.fromJson(e))
          .toList();

      if (message.isFavorite) {
        favorites.removeWhere((m) => m.id == message.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已取消收藏')),
        );
      } else {
        favorites.add(message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已收藏')),
        );
      }

      await prefs.setString(
        'favorite_blessings',
        jsonEncode(favorites.map((e) => e.toJson()).toList()),
      );

      // 更新消息的收藏状态
      setState(() {
        message.isFavorite = !message.isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败：$e')),
      );
    }
  }

  Future<void> _deleteMessage(BlessingMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customBlessingsJson = prefs.getString('custom_blessings') ?? '{}';
      final customBlessings = Map<String, List<BlessingMessage>>.from(
        jsonDecode(customBlessingsJson).map(
          (key, value) => MapEntry(
            key,
            (value as List).map((e) => BlessingMessage.fromJson(e)).toList(),
          ),
        ),
      );

      if (customBlessings.containsKey(widget.category.id)) {
        customBlessings[widget.category.id]!.removeWhere((m) => m.id == message.id);
        await prefs.setString(
          'custom_blessings',
          jsonEncode(customBlessings.map(
            (key, value) => MapEntry(
              key,
              value.map((e) => e.toJson()).toList(),
            ),
          )),
        );
        _loadMessages();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          title:  Text(widget.category.name!,style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_messages.isEmpty) {
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
          title:  Text(widget.category.name!,style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.message, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '暂无祝福语',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddBlessingPage(
                ),
              ),
            );
            if (result == true) {
              _loadMessages();
            }
          },
          child: Icon(Icons.add),
        ),
      );
    }

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
        title:  Text(widget.category.name!,style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isCustom = !blessingMessages[widget.category.id!]
              !.any((m) => m.id == message.id) ??
              true;
          return Card(
            elevation: 2,
            color: isCustom ? Colors.white : Colors.blueAccent[50],
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content!,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isCustom)
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('删除祝福语'),
                                content: Text('确定要删除这条祝福语吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteMessage(message);
                                    },
                                    child: Text('删除'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          message.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: message.isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(message),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: message.content!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('已复制到剪贴板'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.color_main3,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBlessingPage(
              ),
            ),
          );
          if (result == true) {
            _loadMessages();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
} 