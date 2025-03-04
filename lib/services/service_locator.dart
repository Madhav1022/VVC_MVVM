import 'package:get_it/get_it.dart';
import '../repositories/contact_repository.dart';
import '../viewmodels/contact_list_view_model.dart';
import '../viewmodels/contact_details_view_model.dart';
import '../viewmodels/camera_view_model.dart';
import '../viewmodels/form_view_model.dart';
import '../database/db_helper.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // Register Database
  locator.registerLazySingleton<DbHelper>(() => DbHelper());

  // Register Repositories
  locator.registerLazySingleton<ContactRepository>(
          () => ContactRepository(dbHelper: locator<DbHelper>())
  );

  // Register ViewModels
  locator.registerFactory<ContactListViewModel>(
          () => ContactListViewModel(repository: locator<ContactRepository>())
  );

  locator.registerFactory<ContactDetailsViewModel>(
          () => ContactDetailsViewModel(repository: locator<ContactRepository>())
  );

  locator.registerFactory<CameraViewModel>(
          () => CameraViewModel()
  );

  locator.registerFactory<FormViewModel>(
          () => FormViewModel(repository: locator<ContactRepository>())
  );
}
