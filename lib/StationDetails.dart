import "package:flutter/material.dart";
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StationDetails extends StatefulWidget {
  final String city;
  final String station;
  const StationDetails({Key? key,required this.city,required this.station}) : super(key: key);

  @override
  State<StationDetails> createState() => _StationDetailsState();
}

class _StationDetailsState extends State<StationDetails> {

  late Future<List> _future;

  Future<List> getData() async {
    http.Response response = await http.get(Uri.parse(
        "https://www.data.corsica/api/records/1.0/search/?dataset=query-outfields-and-where-1-3d1-and-f-geojson&q=&sort=date_fin&refine.nom_com=${widget
            .city}&refine.nom_station=${widget.station}"));
    final data = json.decode(response.body);


      var detailsData=[];
      var allData = data["records"];
      for(var elem in allData){
        detailsData.add(elem["fields"]);



    };
      return detailsData;
  }

  @override
  void initState() {
    _future = getData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("10 dérniers polluants"),
          backgroundColor: Colors.cyan,
        ),
        body:
        FutureBuilder<List>(
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
                final detailsData = snapshot.requireData;
                return ListView(
                    children: [
                      _createDataTable(detailsData)
                    ]
                );
              }
              return const SizedBox.shrink();
            }

        ),




    );
  }
  DataTable _createDataTable(List detailsData){
    return DataTable(columns: _createColumns(),rows: _createRows(detailsData));
  }
  List<DataColumn> _createColumns(){
    return [
      DataColumn(label: Text("nom_station")),
      DataColumn(label: Text("nom_poll")),
      DataColumn(label: Text("valeur")),
      DataColumn(label: Text("unite")),
      DataColumn(label: Text("date_fin"))
    ];
  }
  List<DataRow> _createRows(List detailsData){
    return detailsData.map(
        (element) => DataRow(cells:[
          DataCell(Text(element["nom_station"])),
          DataCell(Text(element["nom_poll"])),
          DataCell(Text(element["valeur"])),
          DataCell(Text(element["unite"])),
          DataCell(Text(element["date_fin"])),
        ])
    ).toList();
  }

}