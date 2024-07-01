import 'package:serinus/serinus.dart';
import 'package:serinus_cors/serinus_cors.dart';
import 'package:serinus_rate_limiter/serinus_rate_limiter.dart';
import 'entity_hook.dart';
import 'view_engine/view_engine.dart';

import 'app_module.dart';

Future<void> bootstrap() async {
  final app = await serinus.createApplication(
    entrypoint: AppModule(),
    host: '0.0.0.0',
    port: 9090,
  );
  app.use(RateLimiterHook(maxRequests: 100, duration: Duration(minutes: 1)));
  app.use(EntityHook());
  app.use(CorsHook());
  app.useViewEngine(MustacheViewEngine());
  await app.serve();
}
