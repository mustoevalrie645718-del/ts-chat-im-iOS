import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mytencloud_flupro/models/habit.dart';
import 'package:mytencloud_flupro/pages/habit_edit_page.dart';
import 'package:mytencloud_flupro/stylesutil/SharedPreferenceUtil.dart';
import 'package:mytencloud_flupro/tools/my_colors.dart';
import 'package:mytencloud_flupro/widget/empty_view.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class HabitListPage extends StatefulWidget {
  @override
  _HabitListPageState createState() => _HabitListPageState();
}

class _HabitListPageState extends State<HabitListPage> {
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final String? habitsJson = await SharedPreferenceUtil.getString('habits');
    if (habitsJson != null) {
      final List<dynamic> decoded = json.decode(habitsJson);
      setState(() {
        _habits = decoded.map((item) => Habit.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveHabits() async {
    final String encoded = json.encode(_habits.map((habit) => habit.toJson()).toList());
    await SharedPreferenceUtil.setString('habits', encoded);
  }

  Future<void> _addHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitEditPage(),
      ),
    );

    if (result == true) {
      _loadHabits();
    }
  }

  Future<void> _editHabit(Habit habit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitEditPage(habit: habit),
      ),
    );

    if (result == true) {
      _loadHabits();
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认删除'),
          content: Text('确定要删除习惯"${habit.name}"吗？此操作不可恢复。'),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _habits.remove(habit);
      });
      await _saveHabits();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('习惯已删除')),
      );
    }
  }

  Future<void> _addRecord(Habit habit) async {
    final now = DateTime.now();
    final todayRecords = habit.records.where((record) =>
    record.date.year == now.year &&
        record.date.month == now.month &&
        record.date.day == now.day
    ).toList();

    if (todayRecords.length >= habit.targetCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('今日目标已完成！')),
      );
      return;
    }

    final record = HabitRecord(
      id: const Uuid().v4(),
      date: now,
      value: 1,
    );

    setState(() {
      habit.records.add(record);
    });
    await _saveHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color_main4,
      appBar: AppBar(
        centerTitle:  true,
        backgroundColor: MyColors.color_main4,
        title: const Text('习惯打卡'),
      ),
      body: _habits.isEmpty
          ? Center(
        child: EmptyView(title: '暂无习惯，点击右下角添加'),
      )
          : ListView.builder(
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          final habit = _habits[index];
          final now = DateTime.now();
          final todayRecords = habit.records.where((record) =>
          record.date.year == now.year &&
              record.date.month == now.month &&
              record.date.day == now.day
          ).toList();

          final progress = todayRecords.length / habit.targetCount;
          final weeklyRate = habit.getWeeklyCompletionRate();
          final streakDays = habit.getStreakDays();
          final random = Random();
          int number = random.nextInt(3) + 1; // 生成 1~3 的整数
          return GestureDetector(
            onLongPress: () => _deleteHabit(habit),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                // color: MyColors.color_main2,
                image: DecorationImage(
                  opacity: 0.4,
                  image: AssetImage('assets/images/ban_home_ban${number}.jpg'),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editHabit(habit),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? Colors.green : Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '今日进度: ${todayRecords.length}/${habit.targetCount}次',
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '本周完成率: ${(weeklyRate * 100).toStringAsFixed(1)}%',
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        '连续打卡: $streakDays天',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _addRecord(habit),
                    child: Text('打卡'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 36),
                    ),
                  ), SizedBox(height: 5),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: Icon(Icons.add),
      ),
    );
  }
}