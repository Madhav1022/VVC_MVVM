import 'package:path/path.dart' as P;
import 'package:sqflite/sqflite.dart';
import '../models/contact_model.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  Database? _db;

  final String _createTableContact = '''
    create table tbl_contact(
      id integer primary key autoincrement,
      name text,
      mobile text,
      email text,
      address text,
      company text,
      designation text,
      website text,
      image text,
      favorite integer)
  ''';

  Future<Database> _getDb() async {
    if (_db != null) return _db!;

    final dbPath = P.join(await getDatabasesPath(), 'contact.db');
    _db = await openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) {
        db.execute(_createTableContact);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion == 1) {
          await db.execute('alter table tbl_contact rename to contact_old');
          await db.execute(_createTableContact);
          final rows = await db.query('contact_old');
          for (var row in rows) {
            await db.insert('tbl_contact', row);
          }
          await db.execute('drop table if exists contact_old');
        }
      },
    );
    return _db!;
  }

  Future<int> insertContact(ContactModel contact) async {
    final db = await _getDb();
    return db.insert(
      'tbl_contact',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ContactModel>> getAllContacts() async {
    final db = await _getDb();
    final List<Map<String, dynamic>> maps = await db.query('tbl_contact');
    return List.generate(maps.length, (i) => ContactModel.fromMap(maps[i]));
  }

  Future<List<ContactModel>> getAllFavoriteContacts() async {
    final db = await _getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'tbl_contact',
      where: 'favorite = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => ContactModel.fromMap(maps[i]));
  }

  Future<ContactModel?> getContactById(int id) async {
    final db = await _getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'tbl_contact',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ContactModel.fromMap(maps.first);
  }

  Future<int> deleteContact(int id) async {
    final db = await _getDb();
    return db.delete(
      'tbl_contact',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateFavorite(int id, int value) async {
    final db = await _getDb();
    return db.update(
      'tbl_contact',
      {'favorite': value},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateContact(ContactModel contact) async {
    final db = await _getDb();
    return db.update(
      'tbl_contact',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }
}







