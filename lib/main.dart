import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_it/get_it.dart';

// Pages
import 'pages/homepage.dart';
import 'pages/camera_page.dart';
import 'pages/form_page.dart';
import 'pages/contact_details_page.dart';

// Models
import 'models/contact_model.dart';

// ViewModels
import 'viewmodels/contact_list_view_model.dart';
import 'viewmodels/contact_details_view_model.dart';
import 'viewmodels/camera_view_model.dart';
import 'viewmodels/form_view_model.dart';

// Database & Repository
import 'database/db_helper.dart';
import 'repositories/contact_repository.dart';

final GetIt locator = GetIt.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  configureEasyLoading();
  runApp(MyApp());
}

void setupServiceLocator() {
  // Database
  locator.registerLazySingleton<DbHelper>(() => DbHelper());

  // Repository
  locator.registerLazySingleton<ContactRepository>(() =>
      ContactRepository(dbHelper: locator<DbHelper>())
  );

  // ViewModels
  locator.registerFactory(() =>
      ContactListViewModel(locator<ContactRepository>())
  );

  locator.registerFactory(() =>
      ContactDetailsViewModel(locator<ContactRepository>())
  );

  locator.registerFactory(() => CameraViewModel());

  locator.registerFactory(() =>
      FormViewModel(locator<ContactRepository>())
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  late final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ChangeNotifierProvider(
            create: (_) => locator<ContactListViewModel>(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            name: HomePage.routeName,
            path: '/',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                name: ContactDetailsPage.routeName,
                path: 'details/:id',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return ChangeNotifierProvider(
                    create: (_) => locator<ContactDetailsViewModel>()..loadContact(id),
                    child: ContactDetailsPage(id: id),
                  );
                },
              ),
              GoRoute(
                name: CameraPage.routeName,
                path: 'camera',
                builder: (context, state) => ChangeNotifierProvider(
                  create: (_) => locator<CameraViewModel>(),
                  child: const CameraPage(),
                ),
                routes: [
                  GoRoute(
                    name: FormPage.routeName,
                    path: 'form',
                    builder: (context, state) {
                      final contact = state.extra as ContactModel;
                      return ChangeNotifierProvider(
                        create: (_) => locator<FormViewModel>()..initializeContact(contact),
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
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
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
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
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