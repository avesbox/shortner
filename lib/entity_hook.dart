import 'package:serinus/serinus.dart';
import 'sqlite/sqlite_provider.dart';

class EntityHook extends Hook {

  final Logger logger = Logger('EntityHook');

  @override
  Future<void> onRequest(Request request, InternalResponse response) async {
    if (request.method == 'OPTIONS') {
      response.headers({
        'Content-Length': '0',
      });
    }
  }

  @override
  Future<void> beforeHandle(RequestContext context) async {
    final sqlite = context.use<SqliteProvider>();
    final elements = await sqlite.count();
    logger.info('There are $elements short urls in the database');
    if (elements >= 100) {
      logger.warning('There are more than 100 short urls in the database');
      throw BadRequestException(message: 'There are more than 100 short urls in the database');
    }
  }

}