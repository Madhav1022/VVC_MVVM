
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/contact_list_view_model.dart';
import '../models/contact_model.dart';
import '../utils/helper_functions.dart';
import 'camera_page.dart';

class HomePage extends StatelessWidget {
  static const String routeName = '/';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure ViewModel is initialized with contacts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<ContactListViewModel>().loadContacts();
      }
    });

    return Consumer<ContactListViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Contact List'),
            backgroundColor: const Color(0xFF6200EE),
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              final newContact = ContactModel(
                name: '',
                mobile: '',
                email: '',
                address: '',
                company: '',
                designation: '',
                website: '',
                image: '',
                favorite: false,
              );
              context.goNamed(CameraPage.routeName, extra: newContact);
            },
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.add),
            elevation: 8,
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, viewModel),
          body: _buildBody(context, viewModel),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ContactListViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(child: Text(viewModel.error!));
    }

    if (viewModel.contacts.isEmpty) {
      return const Center(child: Text('No contacts found'));
    }

    return ListView.builder(
      itemCount: viewModel.contacts.length,
      itemBuilder: (context, index) {
        final contact = viewModel.contacts[index];
        return _buildContactCard(context, contact, viewModel);
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, ContactListViewModel viewModel) {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 70,
        child: BottomNavigationBar(
          backgroundColor: Colors.grey[100],
          onTap: (index) {
            viewModel.loadContacts(favorites: index == 1);
          },
          currentIndex: viewModel.showingFavorites ? 1 : 0,
          selectedItemColor: const Color(0xFF6200EE),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'All',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, ContactModel contact, ContactListViewModel viewModel) {
    return Dismissible(
      key: ValueKey(contact.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: FractionalOffset.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, size: 25, color: Colors.white),
      ),
      confirmDismiss: (direction) => _showConfirmationDialog(context),
      onDismissed: (_) async {
        await viewModel.deleteContact(contact.id!);
        showMsg(context, 'Deleted Successfully');
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            contact.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          trailing: IconButton(
            onPressed: () => viewModel.toggleFavorite(contact),
            icon: Icon(
              contact.favorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.pink,
            ),
          ),
          onTap: () => context.go('/details/${contact.id}'),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          OutlinedButton(
            onPressed: () => context.pop(false),
            child: const Text('NO'),
          ),
          OutlinedButton(
            onPressed: () => context.pop(true),
            child: const Text('YES'),
          ),
        ],
      ),
    );
  }
}















