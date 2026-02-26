import 'package:uuid/uuid.dart';

class Habit {
   String id='';
   String name='';
   String type=''; // 'running', 'reading', 'water'
   int targetCount=0; // 目标打卡次数
   DateTime createdAt=DateTime.now();
   DateTime updatedAt=DateTime.now();
   List<HabitRecord> records=[];

  Habit({
    required this.id,
    required this.name,
    required this.type,
    required this.targetCount,
    required  this.createdAt,
    required  this.updatedAt,
    required this.records,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      targetCount: json['targetCount'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      records: (json['records'] as List)
          .map((record) => HabitRecord.fromJson(record))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'targetCount': targetCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'records': records.map((record) => record.toJson()).toList(),
    };
  }

  double getWeeklyCompletionRate() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));

    final weekRecords = records.where((record) =>
        record.date.isAfter(weekStart.subtract(Duration(days: 1))) &&
        record.date.isBefore(weekEnd.add(Duration(days: 1))));

    if (weekRecords.isEmpty) return 0.0;

    final completedDays = weekRecords
        .map((record) => record.date.day)
        .toSet()
        .length;

    return completedDays / weekRecords.length;
  }

  int getStreakDays() {
    if (records.isEmpty) return 0;

    final sortedRecords = List<HabitRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime currentDate = DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    for (var record in sortedRecords) {
      final recordDate = DateTime(
          record.date.year, record.date.month, record.date.day);
      if (recordDate.isAtSameMomentAs(currentDate)) {
        streak++;
        currentDate = currentDate.subtract(Duration(days: 1));
      } else if (recordDate.isBefore(currentDate)) {
        break;
      }
    }

    return streak;
  }
}

class HabitRecord {
   String id='';
   DateTime date=DateTime.now();
   int value=0;

  HabitRecord({
    required this.id,
    required this.date,
    required this.value,
  });

  factory HabitRecord.fromJson(Map<String, dynamic> json) {
    return HabitRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'value': value,
    };
  }
} 