import 'package:flutter/material.dart';
import 'package:flutter_zakaria_ezzaatari/StationsList.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;


void main(){
  runApp(MaterialApp(
    home:HomePage(),
  ));
}

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() =>_HomePageState();
}

class _HomePageState extends State<HomePage>{


  late Future<List> _future;


  @override
  void initState(){
    _future = getData();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Choisissez une ville"),
        backgroundColor: Colors.lightBlue,
    ),
      body: FutureBuilder<List>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline),
                  const Text('Une erreur s\'est produite'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _future = getData();
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasData) {
            final cityData = snapshot.requireData;
            return ListView.builder(
              itemCount: cityData == null ? 0 : cityData.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: Card(
                    child: Row(
                        children: <Widget>[
                          Text("${cityData[index]["name"]}",
                              textAlign: TextAlign.center),

                        ]
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) =>
                            StationsList(city: cityData[index]["name"])));
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        }

      ),
      );
  }

  Future<List> getData() async{
    http.Response response = await http.get(Uri.parse("https://www.data.corsica/api/records/1.0/search/?dataset=query-outfields-and-where-1-3d1-and-f-geojson&q=&sort=nom_com&facet=nom_com"));
    final data = json.decode(response.body);


      var cityData = data["facet_groups"];
      return cityData[0]["facets"];


  }
}