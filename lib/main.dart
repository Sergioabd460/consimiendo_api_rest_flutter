import 'dart:convert';
import 'dart:developer';

import 'package:consimiendo_api_rest_flutter/models/gif.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Gif>> _listadoGifs;

  Future<List<Gif>>? _getGifs() async {
    final response = await http.get(Uri.parse(
        "https://api.giphy.com/v1/gifs/trending?api_key=wpdDl6zQI9pkZrl7td0m62x73liSgU6T&limit=25&rating=g"));

    List<Gif> lista = [];
    if (response.statusCode == 200) {
      String cuerpo = utf8.decode(response.bodyBytes);
      final jsondate = jsonDecode(cuerpo);
      debugPrint(jsondate["data"][0]["type"]);

      for (var item in jsondate["data"]) {
        lista.add(Gif(item["title"], item["images"]["downsized"]["url"]));
      }

      return lista;
    } else {
      throw Exception("Fallo la conexion");
    }
  }

  @override
  void initState() {
    super.initState();
    _listadoGifs = _getGifs()!;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Consumiendo Api',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CosumiendoAPI'),
        ),
        body: FutureBuilder(
          future: _listadoGifs,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              (snapshot.data);
              return GridView.count(
                  crossAxisCount: 4, children: _listGifs(snapshot.data));
            } else if (snapshot.hasError) {
              log(snapshot.error.toString());
              return const Text("ERROR");
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  List<Widget> _listGifs(data) {
    List<Widget> gifs = [];

    for (var gif in data) {
      gifs.add(Card(
          child: Column(
        children: [
          Expanded(child: Image.network(gif.url)),
        ],
      )));
    }
    return gifs;
  }
}
