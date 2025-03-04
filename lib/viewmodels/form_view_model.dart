
import '../models/contact_model.dart';
import '../repositories/contact_repository.dart';
import 'base_view_model.dart';

class FormViewModel extends BaseViewModel {
  final ContactRepository _repository;
  late ContactModel _contact;

  FormViewModel(this._repository);

  ContactModel get contact => _contact;

  void initializeContact(ContactModel contact) {
    _contact = contact;
    notifyListeners();
  }

  void updateContact({
    String? name,
    String? mobile,
    String? email,
    String? address,
    String? company,
    String? designation,
    String? website,
  }) {
    _contact = ContactModel(
      id: _contact.id,
      name: name ?? _contact.name,
      mobile: mobile ?? _contact.mobile,
      email: email ?? _contact.email,
      address: address ?? _contact.address,
      company: company ?? _contact.company,
      designation: designation ?? _contact.designation,
      website: website ?? _contact.website,
      image: _contact.image,
      favorite: _contact.favorite,
    );
    notifyListeners();
  }

  Future<bool> saveContact() async {
    return await executeOperation(() async {
      await _repository.insertContact(_contact);
      return true;
    }) ?? false;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (value.length < 10) {
      return 'Mobile number must be at least 10 digits';
    }
    return null;
  }
}