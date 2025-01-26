import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/home_page.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionColor: CupertinoColors.placeholderText,
              selectionHandleColor: CupertinoColors.activeBlue)),
      home: HomePage()));
}
