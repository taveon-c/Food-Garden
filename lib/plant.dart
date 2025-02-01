import 'dart:math';
import 'package:flutter_application/plants_dict.dart';

//Times from planting to harvest in days

class Plant {
  final String name;
  final String date;
  final int id;

  Plant(this.name, this.date, this.id);

  double getProgress(){
    var timeElapsed = DateTime.now().difference(DateTime.parse(date)).inDays;
    var growthTime = plantVarieties[name]?['harvest'];
    return min(timeElapsed/growthTime, 1.0);
  }

  int getDaysLeft() {
    var timeElapsed = DateTime.now().difference(DateTime.parse(date)).inDays;
    var growthTime = plantVarieties[name]?['harvest'];
    return max(growthTime - timeElapsed, 0);
  }

  bool shouldWater() {
    if (getDaysLeft() % plantVarieties[name]?['water'] == 0) {
      return true;
    } else {
      return false;
    }
  }
}