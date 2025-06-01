import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/contact_details_view_model.dart';

class ContactDetailsPage extends StatelessWidget {
  static const String routeName = 'details';
  final String firebaseId;

  const ContactDetailsPage({super.key, required this.firebaseId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactDetailsViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (vm.error != null) {
          return Scaffold(
            body: Center(child: Text(vm.error!)),
          );
        }
        final c = vm.contact!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Contact Details'),
            backgroundColor: const Color(0xFF6200EE),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: c.image.startsWith('http')
                    ? Image.network(
                  c.image,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 250,
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (c.name.isNotEmpty)
                _buildDetailRow(
                  label: c.name,
                  icon: Icons.person,
                  color: Colors.purple,
                ),

              if (c.mobile.isNotEmpty)
                _buildDetailRow(
                  label: c.mobile,
                  icon: Icons.phone,
                  color: Colors.green,
                  onTap: () => vm.launchPhoneUrl(c.mobile),
                ),

              if (c.email.isNotEmpty)
                _buildDetailRow(
                  label: c.email,
                  icon: Icons.email,
                  color: Colors.red,
                  onTap: () => vm.launchEmailUrl(c.email),
                ),

              if (c.address.isNotEmpty)
                _buildDetailRow(
                  label: c.address,
                  icon: Icons.location_on,
                  color: Colors.purple,
                  onTap: () => vm.launchMapUrl(c.address),
                ),

              if (c.website.isNotEmpty)
                _buildDetailRow(
                  label: c.website,
                  icon: Icons.web,
                  color: Colors.blue,
                  onTap: () => vm.launchWebUrl(c.website),
                ),

              if (c.company.isNotEmpty)
                _buildDetailRow(
                  label: c.company,
                  icon: Icons.business,
                  color: Colors.teal,
                ),

              if (c.designation.isNotEmpty)
                _buildDetailRow(
                  label: c.designation,
                  icon: Icons.work,
                  color: Colors.orange,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
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
            icon: Icon(icon, color: color),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

