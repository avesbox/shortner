import 'package:serinus/serinus.dart';
import 'package:shortner/sqlite/sqlite_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteModule extends Module {

  SqliteModule() : super(
    exports: [
      SqliteProvider
    ],
    providers: [
      DeferredProvider(
        inject: [],
        (context) async {
          final dbFactory = databaseFactoryFfi;
          final db = await dbFactory.openDatabase('shortner.db');
          try {
            await db.execute(
              '''
                CREATE TABLE ShortUrls (
                  id INTEGER PRIMARY KEY,
                  url TEXT NOT NULL,
                  shortUrl TEXT NOT NULL,
                  visits INTEGER NOT NULL DEFAULT 0
                )
              '''
            );
          } catch(e) {
            print("Table already exists");
          }
          return SqliteProvider(db);
        }
      )
    ]
  );

  @override
  Future<Module> registerAsync(ApplicationConfig config) async {
    sqfliteFfiInit();
    return this;
  }

}