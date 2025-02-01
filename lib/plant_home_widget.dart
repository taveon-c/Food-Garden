import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/database.dart';
import 'package:flutter_application/plant.dart';
import 'package:flutter_application/plant_page.dart';
import 'package:flutter_application/plants_dict.dart';

class PlantWidget extends StatefulWidget {
  final Plant plant;
  final GardenDB _gardenDB;
  final Function pressHandler;

  const PlantWidget(this.plant, this._gardenDB, this.pressHandler, {super.key});

  @override
  State<PlantWidget> createState() => _PlantWidgetState();
}

class _PlantWidgetState extends State<PlantWidget> {
  late Color progressColor;
  late IconData progressIcon;

  deleteData() async {
    var response = await widget._gardenDB
        .deleteData('DELETE FROM plants WHERE id = ${widget.plant.id}');
    return response;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plant.getProgress() == 1.0) {
      progressColor = Colors.green;
      progressIcon = Icons.check_circle;
    } else if (widget.plant.shouldWater()) {
      progressColor = const Color.fromARGB(255, 24, 120, 199);
      progressIcon = Icons.water_drop;
    } else {
      progressColor = Colors.blue;
      progressIcon = Icons.access_time_filled;
    }
    return TextButton(
      style: TextButton.styleFrom(
        shape: ContinuousRectangleBorder(),
        overlayColor: CupertinoColors.secondarySystemFill
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 10.0,
          children: [
            Icon(progressIcon, color: progressColor, size: 35.0),
            Expanded(
              child: Column(
                spacing: 10.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.plant.name,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      color: Colors.black,
                    )
                  ),
                  SizedBox(
                    width: plantVarieties[widget.plant.name]?['harvest'].toDouble()*5,
                    child: LinearProgressIndicator(
                      value: widget.plant.getProgress(),
                      color: progressColor,
                      backgroundColor: const Color.fromARGB(255, 202, 202, 202)
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  color: Colors.black,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text(widget.plant.name, style: TextStyle(fontFamily: 'Nunito',)),
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
                                    TextStyle(color: CupertinoColors.inactiveGray, fontFamily: 'Nunito',),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                  overlayColor: CupertinoColors.systemRed),
                              child: Text(
                                'remove',
                                style: TextStyle(color: CupertinoColors.systemRed, fontFamily: 'Nunito',),
                              ),
                              onPressed: () {
                                deleteData();
                                widget.pressHandler(() {});
                                Navigator.pop(context);
                              },
                            )
                          ],
                          contentPadding: EdgeInsets.all(20.0),
                          content: Text(
                    'Do you want to remove ${widget.plant.name}? \nYou will not be able to undo this action',
                          style: TextStyle(fontFamily: 'Nunito',)
                          )
                      )
                    );
                  }, 
                  icon: const Icon(Icons.delete, size: 30.0, color: Colors.black,)
                ),
              ),
            )
          ],
        ),
      ),
      
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => PlantPage(widget.plant)));
      },
    );
  }
}