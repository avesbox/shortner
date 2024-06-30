import 'package:acanthis/acanthis.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return HomePage(short: settings.name);
          },
        );
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return HomePage(short: settings.name);
          },
        );
      }
    );
  }
}

class HomePage extends StatefulWidget {

  final String? short;

  const HomePage({this.short, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _urlController = TextEditingController();
  final AcanthisString _shortUrl = string().pattern(RegExp(r'^https?://.*$')).min(1).max(1024);
  final List<ShortUrl> _shortUrls = <ShortUrl>[];
  final Dio _client = Dio(BaseOptions(baseUrl: 'http://localhost:8080', followRedirects: true));

  @override
  void initState() {
    super.initState();
    _getShortUrls();
    if(widget.short != null){
      _client.get('/${widget.short}').then((res) {
        final shortUrl = ShortUrl.fromJson(res.data);
        launchUrlString(shortUrl.url, webOnlyWindowName: '_self');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _urlController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Shortner'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: size.width * 0.5,
                    child: TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL',
                      ),
                      validator: (value) {
                        final result = _shortUrl.tryParse(value ?? '');
                        return result.success ? null : result.errors.values.join(';');
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        _client.post('/', data: {'url': _urlController.text}).then((res) {
                          _getShortUrls();
                          _urlController.clear();
                        });
                        // _client.postUrl(Uri.parse('http://localhost:3000/')).then((HttpClientRequest request) {
                        //   request.headers.contentType = ContentType.json;
                        //   request.write('{"url": "${_urlController.text}"}');
                        //   return request.close();
                        // }).then((HttpClientResponse response) {
                        //   response.transform(const Utf8Decoder()).listen((contents) {
                        //     print(contents);
                        //   });
                        // });
                        }
                    },
                    child: const Text('Shorten'),
                  ),
                ],
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: size.height * 0.8),
            child: ListView.builder(
              itemCount: _shortUrls.length,
              itemBuilder: (context, index) {
                final shortUrl = _shortUrls[index];
                return ListTile(
                  onTap: () async {
                    await Navigator.of(context).pushNamed(shortUrl.shortUrl);
                  },
                  leading: const Icon(Icons.link),
                  title: Text(shortUrl.shortUrl),
                  subtitle: Text(shortUrl.url),
                  trailing: Text(shortUrl.visits.toString()),
                );
              },
            ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Future<void> _getShortUrls() async {
    final res = await _client.get('/');
    setState(() {
      _shortUrls.clear();
      _shortUrls.addAll(List<ShortUrl>.from(res.data.map((e) => ShortUrl.fromJson(e))));
    });
    // final request = await _client.getUrl(Uri.parse('http://localhost:3000/'));
    // final response = await request.close();
    // final contents = await response.transform(const Utf8Decoder()).join();
    // print(contents);
  }
}


class ShortUrl {

  final String url;
  final String shortUrl;
  final int visits;

  ShortUrl({
    required this.url,
    required this.shortUrl,
    required this.visits,
  });

  factory ShortUrl.fromJson(Map<String, dynamic> json) {
    return ShortUrl(
      url: json['url'] as String,
      shortUrl: json['shortUrl'] as String,
      visits: json['visits'] as int,
    );
  }

}