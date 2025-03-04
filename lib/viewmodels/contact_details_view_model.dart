
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact_model.dart';
import '../repositories/contact_repository.dart';
import 'base_view_model.dart';

class ContactDetailsViewModel extends BaseViewModel {
  final ContactRepository _repository;
  ContactModel? _contact;

  ContactDetailsViewModel(this._repository);

  ContactModel? get contact => _contact;

  Future<void> loadContact(int id) async {
    await executeOperation(() async {
      _contact = await _repository.getContactById(id);
      if (_contact == null) {
        setError('Contact not found');
      }
    });
  }

  Future<void> toggleFavorite() async {
    if (_contact == null) return;

    await executeOperation(() async {
      await _repository.updateFavorite(
          _contact!.id!,
          _contact!.favorite ? 0 : 1
      );
      // Update local state
      _contact = ContactModel(
        id: _contact!.id,
        name: _contact!.name,
        mobile: _contact!.mobile,
        email: _contact!.email,
        address: _contact!.address,
        company: _contact!.company,
        designation: _contact!.designation,
        website: _contact!.website,
        image: _contact!.image,
        favorite: !_contact!.favorite,
      );
      notifyListeners();
    });
  }

  Future<String?> getImagePath() async {
    if (_contact == null || _contact!.image.isEmpty) return null;

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${_contact!.image}';
    final file = File(path);

    if (await file.exists()) {
      return path;
    }
    return null;
  }

  Future<void> launchPhoneUrl(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> launchEmailUrl(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> launchMapUrl(String address) async {
    final url = Uri.parse(Platform.isAndroid
        ? 'geo:0,0?q=$address'
        : 'https://maps.apple.com/?q=$address');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> launchWebUrl(String website) async {
    final url = Uri.parse(website.startsWith('http') ? website : 'https://$website');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  bool canMakeCall() => _contact != null && _contact!.mobile.isNotEmpty;
  bool canSendEmail() => _contact != null && _contact!.email.isNotEmpty;
  bool canOpenMap() => _contact != null && _contact!.address.isNotEmpty;
  bool canOpenWebsite() => _contact != null && _contact!.website.isNotEmpty;
}