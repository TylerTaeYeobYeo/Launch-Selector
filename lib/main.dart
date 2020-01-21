import 'package:flutter/material.dart';
import 'package:lunch_menu/home_page/home_page.dart';
import 'package:lunch_menu/login_page/login.dart';
import 'package:lunch_menu/menu/menu_all.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunch Chooser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: 'login',
      routes: {
        'login' : (BuildContext context) => LoginPage(),
        'home' : (BuildContext context) => HomePage(),
        'menu_all' : (BuildContext context) => MenuListPage(),
      }
    );
  }
}
