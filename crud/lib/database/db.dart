import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        isDone INTEGER
      )
    ''');
  }

  // CREATE
  Future<int> insertTodo(Map<String, dynamic> todo) async {
    Database db = await database;
    return await db.insert('todos', todo);
  }

  // READ
  Future<List<Map<String, dynamic>>> getTodos() async {
    Database db = await database;
    return await db.query('todos');
  }

  // UPDATE
  Future<int> updateTodo(Map<String, dynamic> todo) async {
    Database db = await database;
    int id = todo['id'];
    return await db.update('todos', todo, where: 'id = ?', whereArgs: [id]);
  }

  // DELETE
  Future<int> deleteTodo(int id) async {
    Database db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
