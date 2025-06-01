import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/contact_model.dart';
import 'base_view_model.dart';

class CameraViewModel extends BaseViewModel {
  String _name = '';
  String _mobile = '';
  String _email = '';
  String _company = '';
  String _designation = '';
  String _address = '';
  String _website = '';
  String _image = '';
  List<String> _lines = [];
  bool _isScanOver = false;

  // Getters
  String get name => _name;
  String get mobile => _mobile;
  String get email => _email;
  String get company => _company;
  String get designation => _designation;
  String get address => _address;
  String get website => _website;
  String get image => _image;
  List<String> get lines => _lines;
  bool get isScanOver => _isScanOver;
  bool get isFormValid => _name.isNotEmpty && _mobile.isNotEmpty && _email.isNotEmpty;

  Future<void> getImage(ImageSource source) async {
    await executeOperation(() async {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath = '${appDir.path}/$fileName';

        final File newImage = await File(pickedFile.path).copy(newPath);
        _image = fileName;

        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final recognizedText = await textRecognizer.processImage(
            InputImage.fromFile(newImage)
        );

        _lines = [];
        for (var block in recognizedText.blocks) {
          for (var line in block.lines) {
            _lines.add(line.text);
          }
        }
        _isScanOver = true;
        notifyListeners();
      }
    });
  }

  void updatePropertyValue(String property, String value) {
    if (value.isEmpty) return;

    switch (property) {
      case 'Name':
        _name = _name.isEmpty ? value : "$_name $value";
        break;
      case 'Mobile':
        _mobile = _mobile.isEmpty ? value : "$_mobile $value";
        break;
      case 'Email':
        _email = _email.isEmpty ? value : "$_email, $value";
        break;
      case 'Company':
        _company = _company.isEmpty ? value : "$_company $value";
        break;
      case 'Designation':
        _designation = _designation.isEmpty ? value : "$_designation $value";
        break;
      case 'Address':
        _address = _address.isEmpty ? value : "$_address, $value";
        break;
      case 'Website':
        _website = _website.isEmpty ? value : "$_website, $value";
        break;
    }
    notifyListeners();
  }

  void clearPropertyValue(String property) {
    switch (property) {
      case 'Name':
        _name = '';
        break;
      case 'Mobile':
        _mobile = '';
        break;
      case 'Email':
        _email = '';
        break;
      case 'Company':
        _company = '';
        break;
      case 'Designation':
        _designation = '';
        break;
      case 'Address':
        _address = '';
        break;
      case 'Website':
        _website = '';
        break;
    }
    notifyListeners();
  }

  String getPropertyValue(String property) {
    switch (property) {
      case 'Name':
        return _name;
      case 'Mobile':
        return _mobile;
      case 'Email':
        return _email;
      case 'Company':
        return _company;
      case 'Designation':
        return _designation;
      case 'Address':
        return _address;
      case 'Website':
        return _website;
      default:
        return '';
    }
  }

  ContactModel createContact() {
    return ContactModel(
      name: _name,
      mobile: _mobile,
      email: _email,
      address: _address,
      company: _company,
      designation: _designation,
      website: _website,
      image: _image,
    );
  }
}