import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'librarydata.dart';

class LibraryDatabase {
  static final LibraryDatabase instance = LibraryDatabase._init();

  static Database? _database;

  LibraryDatabase._init();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDB('library.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

// id, color, isbold, datetime, facemotion, title, maincontain
  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableLibrarys (
  ${LibraryFields.id} $idType,
   ${LibraryFields.color} $textType,
   ${LibraryFields.isbold} $textType,
   ${LibraryFields.datetime} $textType,
   ${LibraryFields.facemotion} $textType,
   ${LibraryFields.title} $textType,
  ${LibraryFields.maincontain} $textType,
  ${LibraryFields.moneytype} $textType,
  ${LibraryFields.useway} $textType,
  ${LibraryFields.duration} $textType,
  ${LibraryFields.amount} $textType,
  ${LibraryFields.createtime} $textType
  )
''');
  }

  Future<Library> create(Library note) async {
    final db = await instance.database;
    final id = await db!.insert(tableLibrarys, note.toJson());
    return note.copy(id: id);
  }

  Future<Library> readNote(int id) async {
    final db = await instance.database;

    final maps = await db!.query(
      tableLibrarys,
      columns: LibraryFields.values,
      where: '${LibraryFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Library.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

//  读取所有
  Future<List<Library>> readAllNotes() async {
    final db = await instance.database;
    const orderBy = '${LibraryFields.createtime} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableLibrarys ORDER BY $orderBy');

    final result = await db!.query(tableLibrarys, orderBy: orderBy);

    return result.map((json) => Library.fromJson(json)).toList();
  }

//更新
  Future<int> update(Library note) async {
    final db = await instance.database;

    return db!.update(
      tableLibrarys,
      note.toJson(),
      where: '${LibraryFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db!.delete(
      tableLibrarys,
      where: '${LibraryFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db!.close();
  }
}
