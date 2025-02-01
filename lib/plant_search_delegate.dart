import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/plants_dict.dart';

class PlantSearchDelegate extends SearchDelegate {
  var searchTerms = plantVarieties.keys;

  PlantSearchDelegate()
      : super(
            searchFieldLabel: 'plant name',
            searchFieldDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.black, fontSize: 18.0),
                hintStyle: TextStyle(color: Colors.grey, fontSize: 18.0),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: CupertinoColors.activeBlue))));

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildQuery(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildQuery(context);
  }

  Widget buildQuery(BuildContext context) {
    List<String> matchQuery = [];
    for (String plant in searchTerms) {
      if (plant.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(plant);
      }
    }
    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: ListView.separated(
        itemCount: matchQuery.length,
        separatorBuilder: (BuildContext context, int index) => Divider(height: 1, indent: 20, endIndent: 20,),
        itemBuilder: (context, index) {
          String result = matchQuery[index];
          return ListTile(
            title: Text(matchQuery[index], style: TextStyle(fontFamily: 'Nunito')),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text(result, style: TextStyle(fontFamily: 'Nunito')),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                              overlayColor:
                                  CupertinoColors.secondarySystemFill),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'cancel',
                            style:
                                TextStyle(color: CupertinoColors.inactiveGray, fontFamily: 'Nunito'),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              overlayColor: CupertinoColors.activeBlue),
                          child: Text(
                            'confirm',
                            style: TextStyle(color: CupertinoColors.activeBlue, fontFamily: 'Nunito'),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            close(context, result);
                          },
                        )
                      ],
                      contentPadding: EdgeInsets.all(20.0),
                      content: Text('''
Harvest Time: ${plantVarieties[result]?['harvest']} Days
Ambient Temperature: ${plantVarieties[result]?['ambientTemp']}
Soil Temperature: ${plantVarieties[result]?['soilTemp']}
Watering Interval: ${plantVarieties[result]?['water']} Days
Sun Exposure: ${plantVarieties[result]?['sun']} Hours''',
                      style: TextStyle(fontFamily: 'Nunito')
                      )
                  )
              );
            },
          );
        },
      ),
    );
  }
}