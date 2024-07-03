import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Crypto {
  final String id;
  final String symbol;
  final String name;
  final String priceUsd;
  final String percentChange24h;
  final String percentChange1h;
  final String percentChange7d;

  Crypto(
      {required this.id,
      required this.symbol,
      required this.name,
      required this.priceUsd,
      required this.percentChange24h,
      required this.percentChange1h,
      required this.percentChange7d});

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
      priceUsd: json['price_usd'],
      percentChange24h: json['percent_change_24h'],
      percentChange1h: json['percent_change_1h'],
      percentChange7d: json['percent_change_7d'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Bros',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Crypto> _cryptoList = [];
  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCrypto();
  }

  Future<void> _fetchCrypto() async {
    const apiUrl = 'https://api.coinlore.net/api/tickers/';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cryptoJsonList = data['data'];
        final List<Crypto> cryptoList =
            cryptoJsonList.map((json) => Crypto.fromJson(json)).toList();
        setState(() {
          _cryptoList = cryptoList;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Failed to load crypto data');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DefaultTextStyle(
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              child: Text('Crypto Bros')),
          const SizedBox(
            height: 8,
          ),
          const DefaultTextStyle(
              style: TextStyle(fontSize: 12),
              child: Text(
                  "Today's Cryptocurrency Prices by Market Capitalization")),
          const SizedBox(
            height: 28,
          ),
          Scrollbar(
              controller: _scrollController,
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 110,
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _cryptoList.length,
                  itemBuilder: (context, index) {
                    final crypto = _cryptoList[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              right: 10,
                            ),
                            child: Image.network(
                              "https://s2.coinmarketcap.com/static/img/coins/64x64/1.png",
                              width: 28,
                              height: 28,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: DefaultTextStyle(
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                    child: Text(
                                      crypto.name,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                              ),
                              DefaultTextStyle(
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                  child: Text(crypto.symbol))
                            ],
                          ),
                          SizedBox(
                            width: 80,
                            child: DefaultTextStyle(
                                style: const TextStyle(fontSize: 14),
                                child: Text("\$${crypto.priceUsd}")),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: DefaultTextStyle(
                                style: const TextStyle(fontSize: 14),
                                child: Text("${crypto.percentChange1h}% 1h")),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: DefaultTextStyle(
                                style: const TextStyle(fontSize: 14),
                                child: Text("${crypto.percentChange24h}% 24h")),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: DefaultTextStyle(
                                style: const TextStyle(fontSize: 14),
                                child: Text("${crypto.percentChange7d}% 7d")),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ))
        ],
      ),
    );
  }
}
