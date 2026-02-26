import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showRecommendations = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showRecommendations = prefs.getBool('show_recommendations') ?? false;
    });
  }

  Future<void> _toggleRecommendations(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_recommendations', value);
    setState(() {
      _showRecommendations = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('个性化推荐'),
            subtitle: Text('开启后，将根据您的使用习惯推荐相关内容'),
            trailing: Switch(
              value: _showRecommendations,
              onChanged: _toggleRecommendations,
            ),
          ),
        ],
      ),
    );
  }
} 