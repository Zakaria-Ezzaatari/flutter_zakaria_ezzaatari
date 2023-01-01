import "package:flutter/material.dart";
import 'package:flutter_zakaria_ezzaatari/StationDetails.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StationsList extends StatefulWidget {
  final String city;
  const StationsList({Key? key,required this.city}) : super(key: key);


  @override
  State<StationsList> createState() => _StationsListState();
}

class _StationsListState extends State<StationsList> {


  late Future<List> _future;
  Future<List> getData() async{
    http.Response response = await http.get(Uri.parse("https://www.data.corsica/api/records/1.0/search/?dataset=query-outfields-and-where-1-3d1-and-f-geojson&q=&sort=nom_station&facet=nom_station&refine.nom_com=${widget.city}"));
    final data = json.decode(response.body);


      var stationData = data["facet_groups"];
      return stationData[0]["facets"];


  }

  @override
  void initState(){
    _future = getData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choisissez une station méteo"),
        backgroundColor: Colors.cyan,
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
              final stationData = snapshot.requireData;
              return ListView.builder(
                  itemCount: stationData == null ? 0 : stationData.length,
                  itemBuilder: (BuildContext context, int index){
                    return InkWell(
                      child:Card(
                        child:Row(
                            children: <Widget>[
                              Text("${stationData[index]["name"]}",
                                  textAlign: TextAlign.center),

                            ]
                        ),
                      ),
                      onTap: (){Navigator.of(context).push(MaterialPageRoute(builder:(context)=>StationDetails(city: widget.city,station: stationData[index]["name"])));},
                    );
            }
              );
            }
            return const SizedBox.shrink();
          }

      ),





    );
  }
}
