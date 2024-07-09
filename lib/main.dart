import 'package:flutter/material.dart';
import 'SplashScreen.dart';
import 'QuickViewScreen.dart';
// import 'ModelsScreen.dart';
// import 'ClimateScreen.dart';
// import 'ReportsScreen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panahon',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    // Uncomment and add your screen widgets here
    const QuickViewScreen(),
    // ModelsScreen(),
    // ClimateScreen(),
    // ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panahon'),
      ),
      body: _children.isNotEmpty ? _children[_currentIndex] : Container(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index.clamp(0, _children.length - 1);
          });
        },
        selectedItemColor: Colors.orange, // Set the selected item color
        unselectedItemColor: Colors.grey, // Set the unselected item color
        items: const [
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
