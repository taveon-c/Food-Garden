import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/database.dart';
import 'package:flutter_application/plant.dart';
import 'package:flutter_application/plant_home_widget.dart';
import 'package:flutter_application/plant_search_delegate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GardenDB _gardenDB = GardenDB.instance;
  final SearchController controller = SearchController();
  late Timer _timer;

  readData() async {
    var plants = await _gardenDB.readData('SELECT * FROM plants');
    return plants;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leadingWidth: 60,
          toolbarHeight: 70,
          leading: const Image(image: AssetImage('assets/FoodGardenAppLogo.png')),
          title: Text('Food Garden', style: TextStyle(color: Colors.white, fontFamily: 'Nunito', fontSize: 40)),
          backgroundColor: const Color.fromARGB(255, 19, 160, 19),
        ),
        body: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.black, size: 30.0),
                onPressed: () async {
                  var plantName = await showSearch(
                    context: context,
                    delegate: PlantSearchDelegate(),
                  );
                  if (plantName != null) {
                    setState(() {
                      _gardenDB.insertData('''
                  INSERT INTO plants(name, date) VALUES("$plantName","${DateTime.now().toString()}")
                    ''');
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    _timer.cancel();
                    return ListView.separated(
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        Plant plant = Plant(
                            snapshot.data![index]['name'],
                            snapshot.data![index]['date'],
                            snapshot.data![index]['id']);
                        if (plant.getProgress() != 1.0 &&
                            _timer.isActive == false) {
                          _timer =
                              Timer.periodic(Duration(seconds: 1), (timer) {
                            setState(() {});
                          });
                        }
                        return PlantWidget(plant, _gardenDB, setState);
                      },
                    );
                  } else {
                    return const Center();
                  }
                },
                future: readData(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}