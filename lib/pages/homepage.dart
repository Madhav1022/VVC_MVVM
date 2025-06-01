import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/contact_list_view_model.dart';
import '../viewmodels/auth_view_model.dart';
import '../models/contact_model.dart';
import '../utils/helper_functions.dart';

import 'camera_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  static const String routeName = 'home';
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<ContactListViewModel>().loadContacts();
      }
    });

    return Consumer<ContactListViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Contact List'),
            backgroundColor: const Color(0xFF6200EE),
            titleTextStyle:
            const TextStyle(color: Colors.white, fontSize: 24),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle,
                    color: Colors.white),
                tooltip: 'Profile',
                onPressed: () =>
                    context.pushNamed(ProfilePage.routeName),
              ),
            ],
          ),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
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
              context.goNamed(CameraPage.routeName,
                  extra: newContact);
            },
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.add),
            elevation: 8,
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.grey[100],
            currentIndex: vm.showingFavorites ? 1 : 0,
            onTap: (i) => vm.loadContacts(favorites: i == 1),
            selectedItemColor: const Color(0xFF6200EE),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'All'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'Favorites'),
            ],
          ),
          body: SafeArea(
            top: true,
            bottom: true, // Changed to true to let SafeArea handle bottom padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Consumer<AuthViewModel>(
                  builder: (_, auth, __) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Welcome, ${auth.user?.displayName ?? 'User'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6200EE),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                      child: CircularProgressIndicator())
                      : vm.error != null
                      ? Center(child: Text(vm.error!))
                      : vm.contacts.isEmpty
                      ? const Center(
                      child: Text('No contacts found'))
                      : ListView.builder(
                    physics:
                    const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 80), // Simple padding for FAB space
                    itemCount: vm.contacts.length,
                    itemBuilder:
                        (context, index) {
                      final c =
                      vm.contacts[index];
                      return Dismissible(
                        key: ValueKey(
                            c.firebaseId),
                        direction: DismissDirection
                            .endToStart,
                        background: Container(
                          padding:
                          const EdgeInsets
                              .only(right: 20),
                          alignment: Alignment
                              .centerRight,
                          color: Colors.red,
                          child: const Icon(
                              Icons.delete,
                              color:
                              Colors.white),
                        ),
                        confirmDismiss: (_) =>
                            showConfirmationDialog(
                                context),
                        onDismissed: (_) {
                          vm.deleteContact(
                              c.id!);
                          showMsg(context,
                              'Deleted Successfully');
                        },
                        child: Card(
                          margin: const EdgeInsets
                              .symmetric(
                              vertical: 8,
                              horizontal: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  15)),
                          elevation: 4,
                          child: ListTile(
                            contentPadding:
                            const EdgeInsets
                                .all(
                                16),
                            title: Text(
                              c.name,
                              style:
                              const TextStyle(
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                  fontSize:
                                  18),
                            ),
                            trailing: IconButton(
                              icon: Icon(c.favorite
                                  ? Icons.favorite
                                  : Icons
                                  .favorite_border),
                              color: Colors.pink,
                              onPressed: () =>
                                  vm.toggleFavorite(
                                      c),
                            ),
                            onTap: () => context.go(
                              '/home/details/${c.firebaseId}',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
