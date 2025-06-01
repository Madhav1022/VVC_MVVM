import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as P;
import '../models/contact_model.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static const _dbName    = 'contact.db';
  static const _dbVersion = 3;

  Database? _db;

  final String _createTableContact = '''
    CREATE TABLE tbl_contact(
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      firebase_id  TEXT,
      name         TEXT,
      mobile       TEXT,
      email        TEXT,
      address      TEXT,
      company      TEXT,
      designation  TEXT,
      website      TEXT,
      image        TEXT,
      favorite     INTEGER
    )
  ''';

  Future<Database> _getDb() async {
    if (_db != null) return _db!;
    final path = P.join(await getDatabasesPath(), _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute(_createTableContact);
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 3) {
          await db.execute(
              'ALTER TABLE tbl_contact ADD COLUMN firebase_id TEXT;'
          );
        }
      },
    );
    return _db!;
  }

  Future<int> insertContact(ContactModel c) async {
    final db = await _getDb();
    return db.insert(
      'tbl_contact',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateContact(ContactModel c) async {
    final db = await _getDb();
    return db.update(
      'tbl_contact',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  Future<List<ContactModel>> getAllContacts() async {
    final db = await _getDb();
    final maps = await db.query('tbl_contact');
    return maps.map((m) => ContactModel.fromMap(m)).toList();
  }

  Future<List<ContactModel>> getAllFavoriteContacts() async {
    final db = await _getDb();
    final maps = await db.query(
      'tbl_contact',
      where: 'favorite = ?',
      whereArgs: [1],
    );
    return maps.map((m) => ContactModel.fromMap(m)).toList();
  }

  Future<ContactModel?> getContactById(int id) async {
    final db = await _getDb();
    final maps = await db.query(
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

  /// Clears out all local contacts (for fresh sync)
  Future<int> clearContacts() async {
    final db = await _getDb();
    return db.delete('tbl_contact');
  }
}
