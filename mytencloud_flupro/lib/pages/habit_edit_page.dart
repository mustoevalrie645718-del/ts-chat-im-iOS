import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/models/habit.dart';
import 'package:mytencloud_flupro/models/note.dart';
import 'package:mytencloud_flupro/stylesutil/SharedPreferenceUtil.dart';
import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';

class HabitEditPage extends StatefulWidget {
   Habit? habit;

  HabitEditPage({this.habit});

  @override
  _HabitEditPageState createState() => _HabitEditPageState();
}

class _HabitEditPageState extends State<HabitEditPage> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  String _selectedType = 'running';
  bool _isEditing = false;
  DailyQuote? _dailyQuote;

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _targetController.text = widget.habit!.targetCount.toString();
      _selectedType = widget.habit!.type;
      _isEditing = true;
    }
    _loadDailyQuote();
  }

  void _loadDailyQuote() {
    final random = Random();
    _dailyQuote = DailyQuote.quotes[random.nextInt(DailyQuote.quotes.length)];
  }

  Future<void> _saveHabit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入习惯名称')),
      );
      return;
    }

    if (_targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入目标打卡次数')),
      );
      return;
    }

    final targetCount = int.tryParse(_targetController.text);
    if (targetCount == null || targetCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入有效的目标打卡次数')),
      );
      return;
    }

    final String? habitsJson = await SharedPreferenceUtil.getString('habits');
    List<Habit> habits = [];
    
    if (habitsJson != null) {
      final List<dynamic> decoded = json.decode(habitsJson);
      habits = decoded.map((item) => Habit.fromJson(item)).toList();
    }

    final now = DateTime.now();
    final habit = Habit(
      id: _isEditing ? widget.habit!.id : const Uuid().v4(),
      name: _nameController.text,
      type: _selectedType,
      targetCount: targetCount,
      createdAt: _isEditing ? widget.habit!.createdAt : now,
      updatedAt: now,
      records: _isEditing ? widget.habit!.records : [],
    );

    if (_isEditing) {
      final index = habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        habits[index] = habit;
      }
    } else {
      habits.add(habit);
    }

    await SharedPreferenceUtil.setString('habits', json.encode(habits.map((h) => h.toJson()).toList()));
    Navigator.pop(context, true);
  }

  Widget _buildDailyQuote() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _dailyQuote!.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _dailyQuote!.type == 'thought' ? Icons.psychology :
                _dailyQuote!.type == 'inspiration' ? Icons.lightbulb :
                _dailyQuote!.type == 'reading' ? Icons.book :
                Icons.favorite,
                color: Colors.black54,
              ),
              SizedBox(width: 8),
              Text(
                _dailyQuote!.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            _dailyQuote!.content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_isEditing ? '编辑习惯' : '新建习惯'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveHabit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDailyQuote(),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '习惯名称',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedType,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'running',
                            child: Row(
                              children: [
                                Icon(Icons.directions_run, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('运动'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'reading',
                            child: Row(
                              children: [
                                Icon(Icons.book, color: Colors.green),
                                SizedBox(width: 8),
                                Text('学习'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'water',
                            child: Row(
                              children: [
                                Icon(Icons.water_drop, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('养生'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _targetController,
                    decoration: InputDecoration(
                      labelText: '目标打卡次数',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
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
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }
}