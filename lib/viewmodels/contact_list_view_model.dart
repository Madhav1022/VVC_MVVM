
import 'package:flutter/foundation.dart';
import '../models/contact_model.dart';
import '../repositories/contact_repository.dart';
import 'base_view_model.dart';

class ContactListViewModel extends BaseViewModel {
  final ContactRepository _repository;
  List<ContactModel> _contacts = [];
  bool _showingFavorites = false;

  ContactListViewModel(this._repository) {
    // Load contacts immediately when ViewModel is created
    loadContacts();
  }

  List<ContactModel> get contacts => _contacts;
  bool get showingFavorites => _showingFavorites;

  Future<void> loadContacts({bool favorites = false}) async {
    await executeOperation(() async {
      _showingFavorites = favorites;
      _contacts = favorites
          ? await _repository.getFavoriteContacts()
          : await _repository.getAllContacts();
      notifyListeners();
    });
  }

  Future<void> deleteContact(int id) async {
    await executeOperation(() async {
      await _repository.deleteContact(id);
      await loadContacts(favorites: _showingFavorites);
      notifyListeners();
    });
  }

  Future<void> toggleFavorite(ContactModel contact) async {
    await executeOperation(() async {
      await _repository.updateFavorite(
          contact.id!,
          contact.favorite ? 0 : 1
      );
      await loadContacts(favorites: _showingFavorites);
      notifyListeners();
    });
  }

  Future<ContactModel?> getContactById(int id) async {
    try {
      setLoading(true);
      setError(null);
      final contact = await _repository.getContactById(id);
      if (contact == null) {
        setError('Contact not found');
      }
      return contact;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }
}