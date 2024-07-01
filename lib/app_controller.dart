import 'package:serinus/serinus.dart';

import 'sqlite/sqlite_provider.dart';

class AppController extends Controller {

  AppController({super.path = '/'}){
    on(Route.get('/'), getAll);
    on(Route.get('/<shortUrl>'), getUrl);
    on(Route.post('/'), create, schema: ParseSchema(
      body: object({
        'url': string().pattern(RegExp(r'^https?://.*$')),
      })
    ));
    on(Route.get('/<shortUrl>/visits'), getVisits);
  }
  
  Future<Response> getAll(RequestContext context) async {
    final provider = context.use<SqliteProvider>();
    final limit = int.tryParse(context.query['limit'] ?? '10');
    final offset = ((int.tryParse(context.query['page'] ?? '1') ?? 1) - 1) * (limit ?? 10);
    final result = await provider.getAll(limit: limit, offset: offset);
    return Response.render(View('home', {'list': result.map((e) => e.toJson()).toList()}));
  }

  Future<Response> getUrl(RequestContext context) async {
    final provider = context.use<SqliteProvider>();
    final result = await provider.get(context.params['shortUrl']);
    if(result == null){
      throw NotFoundException();
    }
    await provider.incrementVisits(result);
    return Response.redirect(result.url);
  }

  Future<Response> create(RequestContext context) async {
    final provider = context.use<SqliteProvider>();
    final body = context.body.json;
    if(body == null){
      throw BadRequestException(message: 'Invalid body');
    }
    final url = body['url'];
    final result = await provider.getByUrl(url);
    if(result != null){
      throw BadRequestException(message: 'ShortUrl already exists');
    }
    final entity = await provider.create(url);
    return Response.json(entity);
  }


  Future<Response> getVisits(RequestContext context) async {
    final provider = context.use<SqliteProvider>();
    final result = await provider.getVisits(context.params['shortUrl']);
    return Response.json(result);
  }
}