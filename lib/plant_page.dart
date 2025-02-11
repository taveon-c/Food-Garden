import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/plant.dart';
import 'package:flutter_application/plants_dict.dart';
import 'package:intl/intl.dart';

class PlantPage extends StatefulWidget {
  final Plant plant;

  const PlantPage(this.plant, {super.key});

  @override
  State<PlantPage> createState() => _PlantPageState();
}

class _PlantPageState extends State<PlantPage> {
  late Timer _timer;
  late Color progressColor;
  late String progress;
  late IconData progressIcon;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String soilTemp = '${plantVarieties[widget.plant.name]?['soilTemp']}';
    String water = '${plantVarieties[widget.plant.name]?['water']} Days';
    String sun = '${plantVarieties[widget.plant.name]?['sun']} Hours';
    String ambientTemp = '${plantVarieties[widget.plant.name]?['ambientTemp']}';
    String harvest = '${plantVarieties[widget.plant.name]?['harvest']} Days';
    if (widget.plant.getProgress() == 1.0) {
      _timer.cancel();
      progressColor = Colors.green;
      progressIcon = Icons.check_circle;
      progress = '''Ready To
Harvest''';
    } else if (widget.plant.shouldWater()) {
      progressColor = const Color.fromARGB(255, 24, 120, 199);
      progressIcon = Icons.water_drop;
      progress = '${widget.plant.getDaysLeft()} Days Left';
    } else {
      progressColor = Colors.blue;
      progressIcon = Icons.access_time_filled;
      progress = '${widget.plant.getDaysLeft()} Days Left';
    }
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            toolbarHeight: 70,
            leading: BackButton(color: Colors.white),
            title: Text(widget.plant.name, style: TextStyle(color: Colors.white, fontFamily: 'Nunito', fontSize: 40)),
            backgroundColor: const Color.fromARGB(255, 19, 160, 19)),
        body: ListView(
          padding: EdgeInsets.all(8.0),
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                SizedBox(
                  width: 500,
                  height: 500,
                  child: CircularProgressIndicator(
                      value: widget.plant.getProgress(),
                      strokeWidth: 10,
                      color: progressColor,
                      backgroundColor:
                          const Color.fromARGB(255, 202, 202, 202)),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(progress, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 40)),
                    Icon(progressIcon, color: progressColor, size: 60.0)
                  ],
                )
              ],
            ),
            Column(
              spacing: 8.0,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Divider(color: Colors.black, thickness: 2.0),
                Text('Plant Recommendations/Info', style: TextStyle(color: Colors.black, fontFamily: 'Nunito', fontSize: 35.0)),
                Divider(color: Colors.black, thickness: 2.0),
                InfoAttribute(attribute: 'Soil Temperature:', attributeVal: soilTemp),
                Divider(height: 2.0, indent: 4, endIndent: 10),
                InfoAttribute(attribute: 'Watering Interval:', attributeVal: water),
                Divider(height: 2.0, indent: 4, endIndent: 10),
                InfoAttribute(attribute: 'Sun Exposure:', attributeVal: sun),
                Divider(height: 2.0, indent: 4, endIndent: 10),
                InfoAttribute(attribute: 'Air Temperature:', attributeVal: ambientTemp),
                Divider(height: 2.0, indent: 4, endIndent: 10),
                InfoAttribute(attribute: 'Growth Period:', attributeVal: harvest),
                Divider(height: 2.0, indent: 4, endIndent: 10),
                InfoAttribute(attribute: 'Planted:', attributeVal: DateFormat.yMd().format(DateTime.parse(widget.plant.date))),
              ],
            )
        ]));
  }
}

class InfoAttribute extends StatelessWidget {
  const InfoAttribute({super.key, required this.attribute, required this.attributeVal});

  final String attribute;
  final String attributeVal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(attribute,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Nunito',
                    fontSize: 30.0))),
        Expanded(
            child: Text(attributeVal,
            textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black, fontFamily: 'Nunito', fontSize: 30.0)))
      ],
    );
  }
}

