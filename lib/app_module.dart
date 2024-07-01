import 'package:serinus/serinus.dart';

import 'app_controller.dart';
import 'sqlite/sqlite_module.dart';

class AppModule extends Module {
  AppModule() : super(
    imports: [
      SqliteModule()
    ],
    controllers: [
      AppController()
    ],
  );
}