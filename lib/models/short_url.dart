import 'package:serinus/serinus.dart';

class ShortUrl with JsonObject {

  final String url;
  final String shortUrl;
  final int visits;
  final int id;

  ShortUrl({
    required this.url,
    required this.shortUrl,
    required this.visits,
    required this.id
  });

  factory ShortUrl.fromJson(Map<String, dynamic> json) {
    return ShortUrl(
      url: json['url'],
      shortUrl: json['shortUrl'],
      visits: json['visits'],
      id: json['id']
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'url': url,
    'shortUrl': shortUrl,
    'visits': visits,
    'id': id
  };

  
}