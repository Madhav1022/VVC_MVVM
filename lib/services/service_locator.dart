import 'package:get_it/get_it.dart';
import '../database/db_helper.dart';
import '../repositories/contact_repository.dart';
import '../viewmodels/contact_list_view_model.dart';
import '../viewmodels/contact_details_view_model.dart';
import '../viewmodels/form_view_model.dart';
import '../viewmodels/camera_view_model.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // Database
  locator.registerLazySingleton<DbHelper>(
        () => DbHelper(),
  );

  // Repository
  locator.registerLazySingleton<ContactRepository>(
        () => ContactRepository(dbHelper: locator<DbHelper>()),
  );

  // ViewModels
  locator.registerFactory<ContactListViewModel>(
        () => ContactListViewModel(locator<ContactRepository>()),
  );
  locator.registerFactory<ContactDetailsViewModel>(
        () => ContactDetailsViewModel(locator<ContactRepository>()),
  );
  locator.registerFactory<FormViewModel>(
        () => FormViewModel(locator<ContactRepository>()),
  );
  locator.registerFactory<CameraViewModel>(
        () => CameraViewModel(),
  );
}

