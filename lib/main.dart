import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Pages
import 'pages/auth_wrapper.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/profile_page.dart';
import 'pages/homepage.dart';
import 'pages/camera_page.dart';
import 'pages/form_page.dart';
import 'pages/contact_details_page.dart';

// Core & DI
import 'database/db_helper.dart';
import 'repositories/contact_repository.dart';
import 'models/contact_model.dart';
import 'package:get_it/get_it.dart';

// ViewModels
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/contact_list_view_model.dart';
import 'viewmodels/contact_details_view_model.dart';
import 'viewmodels/camera_view_model.dart';
import 'viewmodels/form_view_model.dart';

final GetIt locator = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupServiceLocator();
  configureEasyLoading();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

void setupServiceLocator() {
  locator.registerLazySingleton(() => DbHelper());
  locator.registerLazySingleton(
        () => ContactRepository(dbHelper: locator<DbHelper>()),
  );
  locator.registerFactory(
        () => ContactListViewModel(locator<ContactRepository>()),
  );
  locator.registerFactory(
        () => ContactDetailsViewModel(locator<ContactRepository>()),
  );
  locator.registerFactory(() => CameraViewModel());
  locator.registerFactory(
        () => FormViewModel(locator<ContactRepository>()),
  );
}

late final GoRouter _router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: AuthWrapper.routeName,
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/login',
      name: LoginPage.routeName,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: RegisterPage.routeName,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: ForgotPasswordPage.routeName,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/profile',
      name: ProfilePage.routeName,
      builder: (context, state) => const ProfilePage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return ChangeNotifierProvider(
          create: (_) => locator<ContactListViewModel>(),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          name: HomePage.routeName,
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'details/:fid',
              name: ContactDetailsPage.routeName,
              builder: (context, state) {
                final fid = state.pathParameters['fid']!;
                return ChangeNotifierProvider(
                  create: (_) =>
                  locator<ContactDetailsViewModel>()..loadContactRemote(fid),
                  child: ContactDetailsPage(firebaseId: fid),
                );
              },
            ),
            GoRoute(
              path: 'camera',
              name: CameraPage.routeName,
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => locator<CameraViewModel>(),
                child: const CameraPage(),
              ),
              routes: [
                GoRoute(
                  path: 'form',
                  name: FormPage.routeName,
                  builder: (context, state) {
                    final contact = state.extra as ContactModel;
                    return ChangeNotifierProvider(
                      create: (_) =>
                      locator<FormViewModel>()..initializeContact(contact),
                      child: FormPage(contactModel: contact),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error: ${state.error}',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Contact Manager',
      routerConfig: _router,
      builder: EasyLoading.init(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6200EE),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle:
          TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.deepPurple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}

void configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black.withOpacity(0.7)
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.black.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}
