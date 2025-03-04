
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/contact_model.dart';
import '../viewmodels/form_view_model.dart';
import '../viewmodels/contact_list_view_model.dart';
import '../utils/helper_functions.dart';
import 'homepage.dart';

class FormPage extends StatefulWidget {
  static const String routeName = 'form';
  final ContactModel contactModel;

  const FormPage({
    super.key,
    required this.contactModel,
  });

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final companyController = TextEditingController();
  final designationController = TextEditingController();
  final webController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    nameController.text = widget.contactModel.name;
    mobileController.text = widget.contactModel.mobile;
    emailController.text = widget.contactModel.email;
    addressController.text = widget.contactModel.address;
    companyController.text = widget.contactModel.company;
    designationController.text = widget.contactModel.designation;
    webController.text = widget.contactModel.website;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Form Page'),
            backgroundColor: const Color(0xFF6200EE),
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildTextField(
                  controller: nameController,
                  label: 'Contact Name',
                  validator: (value) => viewModel.validateRequired(value, 'Name'),
                  onChanged: (value) => viewModel.updateContact(name: value),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: mobileController,
                  label: 'Mobile Number',
                  keyboardType: TextInputType.phone,
                  validator: viewModel.validateMobile,
                  onChanged: (value) => viewModel.updateContact(mobile: value),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: viewModel.validateEmail,
                  onChanged: (value) => viewModel.updateContact(email: value),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: addressController,
                  label: 'Street Address',
                  onChanged: (value) => viewModel.updateContact(address: value),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: companyController,
                  label: 'Company Name',
                  onChanged: (value) => viewModel.updateContact(company: value),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: designationController,
                  label: 'Designation',
                  onChanged: (value) => viewModel.updateContact(designation: value),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: webController,
                  label: 'Website',
                  onChanged: (value) => viewModel.updateContact(website: value),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _saveContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                      : const Text('Save', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }

  void _saveContact() async {
    if (_formKey.currentState!.validate()) {
      final formViewModel = context.read<FormViewModel>();
      final contactListViewModel = context.read<ContactListViewModel>();

      final success = await formViewModel.saveContact();

      if (success && mounted) {
        // First refresh the contacts list
        await contactListViewModel.loadContacts();

        // Then show success message and navigate
        showMsg(context, 'Saved Successfully');
        if (mounted) {
          context.goNamed(HomePage.routeName);
        }
      } else if (mounted) {
        showMsg(context, 'Failed to save contact');
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    companyController.dispose();
    designationController.dispose();
    webController.dispose();
    super.dispose();
  }
}