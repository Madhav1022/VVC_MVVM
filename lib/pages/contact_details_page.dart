
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/contact_details_view_model.dart';
import 'package:virtual_visiting_card/models/contact_model.dart';
import '../utils/helper_functions.dart';

class ContactDetailsPage extends StatelessWidget {
  static const String routeName = 'details';
  final int id;

  const ContactDetailsPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure ViewModel is initialized
    context.read<ContactDetailsViewModel>().loadContact(id);

    return Consumer<ContactDetailsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Contact Details'),
            backgroundColor: const Color(0xFF6200EE),
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: _buildBody(context, viewModel),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ContactDetailsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(child: Text(viewModel.error!));
    }

    if (viewModel.contact == null) {
      return const Center(child: Text('Contact not found'));
    }

    return FutureBuilder<String?>(
      future: viewModel.getImagePath(),
      builder: (context, imageSnapshot) {
        return ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            if (imageSnapshot.hasData && imageSnapshot.data != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imageSnapshot.data!),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(Icons.person, size: 100, color: Colors.grey),

            const SizedBox(height: 16),

            if (viewModel.contact!.name.isNotEmpty)
              _buildDetailRow(
                context,
                label: viewModel.contact!.name,
                icon: Icons.person,
                color: Colors.purple,
              ),

            if (viewModel.contact!.mobile.isNotEmpty)
              _buildDetailRow(
                context,
                label: viewModel.contact!.mobile,
                onTap: () => _callContact(context, viewModel),
                icon: Icons.phone,
                color: Colors.green,
              ),

            if (viewModel.contact!.email.isNotEmpty)
              _buildDetailRow(
                context,
                label: viewModel.contact!.email,
                onTap: () => _emailContact(context, viewModel),
                icon: Icons.email,
                color: Colors.red,
              ),

            if (viewModel.contact!.address.isNotEmpty)
              _buildDetailRow(
                context,
                label: viewModel.contact!.address,
                onTap: () => _openMap(context, viewModel),
                icon: Icons.location_on,
                color: Colors.purple,
              ),

            if (viewModel.contact!.website.isNotEmpty)
              _buildDetailRow(
                context,
                label: viewModel.contact!.website,
                onTap: () => _openWebsite(context, viewModel),
                icon: Icons.web,
                color: Colors.blue,
              ),

            if (viewModel.contact!.company.isNotEmpty)
              _buildDetailRow(
                context,
                label: viewModel.contact!.company,
                icon: Icons.business,
                color: Colors.teal,
              ),

            if (viewModel.contact!.designation.isNotEmpty)
              _buildDetailRow(
                context,
                label: viewModel.contact!.designation,
                icon: Icons.work,
                color: Colors.orange,
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
        VoidCallback? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _callContact(BuildContext context, ContactDetailsViewModel viewModel) async {
    if (!viewModel.canMakeCall()) return;

    try {
      await viewModel.launchPhoneUrl(viewModel.contact!.mobile);
    } catch (e) {
      if (context.mounted) {
        showMsg(context, 'Failed to make call.');
      }
    }
  }

  Future<void> _emailContact(BuildContext context, ContactDetailsViewModel viewModel) async {
    if (!viewModel.canSendEmail()) return;

    try {
      await viewModel.launchEmailUrl(viewModel.contact!.email);
    } catch (e) {
      if (context.mounted) {
        showMsg(context, 'Failed to send email.');
      }
    }
  }

  Future<void> _openMap(BuildContext context, ContactDetailsViewModel viewModel) async {
    if (!viewModel.canOpenMap()) return;

    try {
      await viewModel.launchMapUrl(viewModel.contact!.address);
    } catch (e) {
      if (context.mounted) {
        showMsg(context, 'Failed to open map.');
      }
    }
  }

  Future<void> _openWebsite(BuildContext context, ContactDetailsViewModel viewModel) async {
    if (!viewModel.canOpenWebsite()) return;

    try {
      await viewModel.launchWebUrl(viewModel.contact!.website);
    } catch (e) {
      if (context.mounted) {
        showMsg(context, 'Failed to open website.');
      }
    }
  }
}