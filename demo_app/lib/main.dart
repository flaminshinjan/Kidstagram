import 'package:demo_app/screens/login.dart';
import 'package:demo_app/screens/new_taskpage.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/screens/homepage.dart';
import 'package:demo_app/screens/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => Login(),
        '/home': (context) => HomePage(),
        '/newtask': (context) => NewTaskPage(),
      },
    );
  }
}
