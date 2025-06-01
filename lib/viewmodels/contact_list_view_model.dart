import 'package:firebase_auth/firebase_auth.dart';
import '../models/contact_model.dart';
import '../repositories/contact_repository.dart';
import 'base_view_model.dart';
import '../utils/helper_functions.dart';

class ContactListViewModel extends BaseViewModel {
  final ContactRepository _repository;
  List<ContactModel> _contacts = [];
  bool _showingFavorites = false;

  ContactListViewModel(this._repository) {
    loadContacts();
  }

  List<ContactModel> get contacts => _contacts;
  bool get showingFavorites => _showingFavorites;

  // /// Always pull fresh from Firestore
  // Future<void> loadContacts({bool favorites = false}) async {
  //   await executeOperation(() async {
  //     _showingFavorites = favorites;
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       _contacts = [];
  //     } else {
  //       var remote = await _repository.fetchContactsFromFirebase();
  //       if (favorites) {
  //         remote = remote.where((c) => c.favorite).toList();
  //       }
  //       _contacts = remote;
  //     }
  //     notifyListeners();
  //   });
  // }

  /// Always pull fresh from Firestore with latency measurement
  Future<void> loadContacts({bool favorites = false}) async {
    await executeOperation(() async {
      _showingFavorites = favorites;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _contacts = [];
      } else {
        // Measure Firestore fetch latency
        final startTime = DateTime.now();
        var remote = await _repository.fetchContactsFromFirebase();
        final endTime = DateTime.now();
        final durationMs = endTime.difference(startTime).inMilliseconds;

        // Log Firestore latency
        await logLatency('Fetch Contacts from Firestore', durationMs, source: 'Firestore');

        if (favorites) {
          remote = remote.where((c) => c.favorite).toList();
        }
        _contacts = remote;
      }
      notifyListeners();
    });
  }

  Future<void> deleteContact(int id) async {
    await executeOperation(() async {
      await _repository.deleteContact(id);
      await loadContacts(favorites: _showingFavorites);
    });
  }

  /// Toggle favorite by Firestore ID to avoid null-id crashes
  Future<void> toggleFavorite(ContactModel contact) async {
    final fid = contact.firebaseId;
    if (fid == null) return;  // nothing to do without a Firestore ID

    await executeOperation(() async {
      final newFav = !contact.favorite;
      // 1) update remote
      await _repository.updateFavoriteByFirebaseId(fid, newFav);

      // 2) locally update in-memory list
      contact.favorite = newFav;

      // 3) if we're showing favorites and user unfavorited, remove it
      if (_showingFavorites && !newFav) {
        _contacts.removeWhere((c) => c.firebaseId == fid);
      }

      notifyListeners();
    });
  }
}
