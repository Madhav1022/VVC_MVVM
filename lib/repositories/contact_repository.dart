import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/db_helper.dart';
import '../models/contact_model.dart';

class ContactRepository {
  final DbHelper _dbHelper;
  final FirebaseAuth     _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage   _storage   = FirebaseStorage.instance;

  ContactRepository({ required DbHelper dbHelper })
      : _dbHelper = dbHelper;

  /// Insert or update in SQLite, then sync to Firestore & Storage.
  Future<int> insertContact(ContactModel contact) async {
    final id = await _dbHelper.insertContact(contact);
    contact.id = id;
    await _syncToFirebase(contact);
    return id;
  }

  /// Only local insert (used when bootstrapping from remote)
  Future<void> insertContactLocal(ContactModel contact) =>
      _dbHelper.insertContact(contact);

  /// Clear all local contacts (for fresh sync)
  Future<void> clearLocalContacts() => _dbHelper.clearContacts();

  Future<List<ContactModel>> getAllContacts() =>
      _dbHelper.getAllContacts();

  Future<List<ContactModel>> getAllFavoriteContacts() =>
      _dbHelper.getAllFavoriteContacts();

  Future<ContactModel?> getContactById(int id) =>
      _dbHelper.getContactById(id);

  /// Update favorite in SQLite, then in Firestore if we have a firebaseId.
  Future<int> updateFavorite(int id, int value) async {
    // 1) local
    final res = await _dbHelper.updateFavorite(id, value);
    // 2) remote
    final model = await _dbHelper.getContactById(id);
    if (model?.firebaseId != null) {
      await updateFavoriteByFirebaseId(model!.firebaseId!, value == 1);
    }
    return res;
  }

  /// Deletes locally + remotely (and associated storage files).
  Future<int> deleteContact(int id) async {
    final model = await _dbHelper.getContactById(id);
    final res   = await _dbHelper.deleteContact(id);
    if (model?.firebaseId != null) {
      final uid = _auth.currentUser!.uid;
      await _firestore
          .collection('users').doc(uid)
          .collection('contacts').doc(model!.firebaseId)
          .delete();

      final folder = _storage.ref('users/$uid/contacts/${model.firebaseId}');
      final list   = await folder.listAll();
      for (var item in list.items) {
        await item.delete();
      }
    }
    return res;
  }

  /// Fetch all contacts for the current user from Firestore.
  Future<List<ContactModel>> fetchContactsFromFirebase() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final snap = await _firestore
        .collection('users').doc(uid)
        .collection('contacts')
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return ContactModel(
        id:          null,
        firebaseId:  doc.id,
        name:        data['name']        ?? '',
        mobile:      data['mobile']      ?? '',
        email:       data['email']       ?? '',
        address:     data['address']     ?? '',
        company:     data['company']     ?? '',
        designation: data['designation'] ?? '',
        website:     data['website']     ?? '',
        image:       data['image']       ?? '',
        favorite:    data['favorite']    ?? false,
      );
    }).toList();
  }

  /// Fetch a single contact by its Firestore document ID.
  Future<ContactModel> getRemoteContact(String firebaseId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    final doc = await _firestore
        .collection('users').doc(uid)
        .collection('contacts')
        .doc(firebaseId)
        .get();
    final data = doc.data()!;
    return ContactModel(
      id:          null,
      firebaseId:  doc.id,
      name:        data['name']        ?? '',
      mobile:      data['mobile']      ?? '',
      email:       data['email']       ?? '',
      address:     data['address']     ?? '',
      company:     data['company']     ?? '',
      designation: data['designation'] ?? '',
      website:     data['website']     ?? '',
      image:       data['image']       ?? '',
      favorite:    data['favorite']    ?? false,
    );
  }

  Future<void> updateFavoriteByFirebaseId(String firebaseId, bool fav) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    await _firestore
        .collection('users').doc(uid)
        .collection('contacts')
        .doc(firebaseId)
        .update({'favorite': fav});
  }


  Future<void> _syncToFirebase(ContactModel contact) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final col = _firestore.collection('users').doc(uid).collection('contacts');
    late DocumentReference<Map<String, dynamic>> docRef;

    if (contact.firebaseId == null) {
      docRef = col.doc();
      contact.firebaseId = docRef.id;
    } else {
      docRef = col.doc(contact.firebaseId);
    }

    // Upload image if present
    var imageUrl = contact.image;
    if (imageUrl.isNotEmpty) {
      final dir  = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$imageUrl');
      if (await file.exists()) {
        final storageRef =
        _storage.ref('users/$uid/contacts/${docRef.id}/$imageUrl');
        await storageRef.putFile(file);
        imageUrl = await storageRef.getDownloadURL();
      }
    }

    // Write Firestore document
    await docRef.set({
      'name':        contact.name,
      'mobile':      contact.mobile,
      'email':       contact.email,
      'address':     contact.address,
      'company':     contact.company,
      'designation': contact.designation,
      'website':     contact.website,
      'favorite':    contact.favorite,
      'image':       imageUrl,
    });

    // Persist firebaseId locally
    await _dbHelper.updateContact(contact);
  }

  Future<void> launchPhoneUrl(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> launchEmailUrl(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> launchMapUrl(String address) async {
    final uri = Uri.parse(Platform.isAndroid
        ? 'geo:0,0?q=$address'
        : 'https://maps.apple.com/?q=$address');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> launchWebUrl(String website) async {
    final uri =
    Uri.parse(website.startsWith('http') ? website : 'https://$website');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
