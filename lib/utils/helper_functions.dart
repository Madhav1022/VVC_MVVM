import 'package:flutter/material.dart';

void showMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      backgroundColor: Colors.black87,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

Future<bool?> showConfirmationDialog(
    BuildContext context, {
      String title = 'Confirm',
      String message = 'Are you sure?',
      String confirmText = 'YES',
      String cancelText = 'NO',
    }) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}

// Add image helper functions
String getImagePath(String imageName) {
  if (imageName.isEmpty) return '';
  return imageName;
}

bool isValidEmail(String email) {
  if (email.isEmpty) return true;
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool isValidPhone(String phone) {
  if (phone.isEmpty) return false;
  return phone.length >= 10;
}