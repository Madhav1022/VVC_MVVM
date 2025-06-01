import '../models/contact_model.dart';
import '../repositories/contact_repository.dart';
import 'base_view_model.dart';

class ContactDetailsViewModel extends BaseViewModel {
  final ContactRepository _repository;
  ContactModel? _contact;
  ContactModel? get contact => _contact;

  ContactDetailsViewModel(this._repository);

  /// Load the contact from Firestore by its document ID.
  Future<void> loadContactRemote(String firebaseId) async {
    await executeOperation(() async {
      _contact = await _repository.getRemoteContact(firebaseId);
      if (_contact == null) setError('Contact not found');
    });
  }

  /// Toggle the favorite flag locally and remotely.
  Future<void> toggleFavorite() async {
    if (_contact == null || _contact!.id == null) return;

    // Prepare the new value (1 = true, 0 = false).
    final newVal = _contact!.favorite ? 0 : 1;

    await executeOperation(() async {
      // 1) Update local SQLite & Firestore (via repository)
      await _repository.updateFavorite(_contact!.id!, newVal);

      // 2) Update the in-memory model and notify listeners
      _contact = ContactModel(
        id:          _contact!.id,
        firebaseId:  _contact!.firebaseId,
        name:        _contact!.name,
        mobile:      _contact!.mobile,
        email:       _contact!.email,
        address:     _contact!.address,
        company:     _contact!.company,
        designation: _contact!.designation,
        website:     _contact!.website,
        image:       _contact!.image,
        favorite:    newVal == 1,
      );
      notifyListeners();
    });
  }

  /// Delegate URL launches to the repository
  Future<void> launchPhoneUrl(String phoneNumber) =>
      _repository.launchPhoneUrl(phoneNumber);
  Future<void> launchEmailUrl(String email) =>
      _repository.launchEmailUrl(email);
  Future<void> launchMapUrl(String address) =>
      _repository.launchMapUrl(address);
  Future<void> launchWebUrl(String website) =>
      _repository.launchWebUrl(website);

  bool canMakeCall()    => _contact?.mobile.isNotEmpty  == true;
  bool canSendEmail()   => _contact?.email.isNotEmpty   == true;
  bool canOpenMap()     => _contact?.address.isNotEmpty == true;
  bool canOpenWebsite() => _contact?.website.isNotEmpty == true;
}
