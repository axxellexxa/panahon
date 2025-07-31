import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SplashScreen.dart';
import 'QuickViewScreen.dart';
import 'ModelsScreen.dart';
import 'ClimateScreen.dart';
import 'ReportsScreen.dart';

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
      initialRoute: '/home',
      routes: {
        '/splash': (context) => const SplashScreen(),
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
    const ModelsScreen(),
    const ClimateScreen(),
    const ReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panahon'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.thermostat),
            label: 'Quick View',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Models',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud),
            label: 'Climate',
          ),
          NavigationDestination(
            icon: Icon(Icons.article),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
