import 'package:cron/cron.dart';
import 'package:serinus/serinus.dart';
import '../models/short_url.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteProvider extends Provider with OnApplicationInit{

  final Logger logger = Logger('SqliteProvider');
  
  final Database _db;

  SqliteProvider(this._db);

  Future<List<ShortUrl>> getAll({
    int? limit,
    int? offset
  }) async {
    final results = await _db.query('ShortUrls', limit: limit, offset: offset);
    return [
      ...results.map((e) => ShortUrl.fromJson(Map<String, dynamic>.from(e)))
    ];
  }

  Future<ShortUrl?> get(String param) async {
    final result = (await _db.query('ShortUrls', where: 'shortUrl = ?', whereArgs: [param])).firstOrNull;
    if(result == null){
      return null;
    }
    return ShortUrl.fromJson(Map<String, dynamic>.from(result));
  }

  Future<void> incrementVisits(ShortUrl result) async {
    await _db.update(
      'ShortUrls',
      {'visits': (result.visits) + 1},
      where: 'id = ?',
      whereArgs: [result.id]
    );
  }

  Future<Map<String, Object?>?> getVisits(String shortUrl) async {
    return (await _db.query('ShortUrls', columns: ['visits'], where: 'shortUrl = ?', whereArgs: [shortUrl])).firstOrNull;
  }

  Future<ShortUrl?> create(String url) async {
    await _db.insert('ShortUrls', {
      'url': url,
      'shortUrl': url.hashCode.toRadixString(36),
      'visits': 0
    });
    return await getByUrl(url);
  }

  Future<ShortUrl?> getByUrl(String url) async {
    final result = (await _db.query('ShortUrls', where: 'url = ?', whereArgs: [url])).firstOrNull;
    if(result == null){
      return null;
    }
    return ShortUrl.fromJson(Map<String, dynamic>.from(result));
  }

  Future<int> count() async {
    return (await _db.query('ShortUrls')).length;
  }
  
  @override
  Future<void> onApplicationInit() async {
    final cron = Cron();
    cron.schedule(Schedule.parse('*/15 * * * *'), () async {
      logger.info('Deleting all entries in ShortUrls table');
      await _db.delete('ShortUrls');
    });
  }

}