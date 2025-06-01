import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_view_model.dart';
import 'homepage.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  static const String routeName = 'auth-wrapper';
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    // Redirect based on the user state.
    if (authViewModel.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(LoginPage.routeName);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(HomePage.routeName);
      });
    }
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
