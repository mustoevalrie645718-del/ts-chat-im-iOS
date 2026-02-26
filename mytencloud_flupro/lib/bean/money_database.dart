import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'money.dart';

class MoneyDatabase {
  static final MoneyDatabase instance = MoneyDatabase._init();

  static Database? _database;

  MoneyDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('money.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableNotes ( 
  ${MoneyFields.id} $idType, 
   ${MoneyFields.type} $textType,
   ${MoneyFields.money} $textType,
   ${MoneyFields.useway} $textType,
  ${MoneyFields.datetime} $textType
  )
''');
  }

  Future<Money> create(Money note) async {
    final db = await instance.database;

    // final json = note.toJson();
    // final columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

    final id = await db.insert(tableNotes, note.toJson());
    return note.copy(id: id);
  }

  Future<Money?> readNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNotes,
      columns: MoneyFields.values,
      where: '${MoneyFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Money.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

//  读取所有
  Future<List<Money>> readAllNotes() async {
    final db = await instance.database;
    const orderBy = '${MoneyFields.datetime} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableNotes, orderBy: orderBy);

    return result.map((json) => Money.fromJson(json)).toList();
  }

//更新
  Future<int> update(Money note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${MoneyFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNotes,
      where: '${MoneyFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
