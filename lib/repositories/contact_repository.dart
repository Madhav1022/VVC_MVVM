
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../database/db_helper.dart';
import '../models/contact_model.dart';

class ContactRepository {
  final DbHelper _dbHelper;

  ContactRepository({required DbHelper dbHelper}) : _dbHelper = dbHelper;

  Future<int> insertContact(ContactModel contact) async {
    return await _dbHelper.insertContact(contact);
  }

  Future<List<ContactModel>> getAllContacts() async {
    return await _dbHelper.getAllContacts();
  }

  Future<List<ContactModel>> getFavoriteContacts() async {
    return await _dbHelper.getAllFavoriteContacts();
  }

  Future<ContactModel?> getContactById(int id) async {
    return await _dbHelper.getContactById(id);
  }

  Future<int> deleteContact(int id) async {
    // Delete associated image if exists
    final contact = await getContactById(id);
    if (contact != null && contact.image.isNotEmpty) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${contact.image}');
      if (await file.exists()) {
        await file.delete();
      }
    }
    return await _dbHelper.deleteContact(id);
  }

  Future<int> updateFavorite(int id, int value) async {
    return await _dbHelper.updateFavorite(id, value);
  }

  Future<String?> getImagePath(String imageName) async {
    if (imageName.isEmpty) return null;
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$imageName');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  Future<int> updateContact(ContactModel contact) async {
    return await _dbHelper.updateContact(contact);
  }
}