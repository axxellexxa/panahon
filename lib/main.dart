import 'package:flutter/material.dart';
import 'QuickViewScreen.dart';
import 'ModelsScreen.dart';
import 'ClimateScreen.dart';
import 'ReportsScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    QuickViewScreen(),
    ModelsScreen(),
    ClimateScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panahon'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.thermostat),
            label: 'Quick View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Models',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Climate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
