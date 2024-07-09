import 'package:flutter/material.dart';
import 'weather_api.dart'; // Import your WeatherMapWidget.dart file

class QuickViewScreen extends StatefulWidget {
  const QuickViewScreen({super.key});

  @override
  _QuickViewScreenState createState() => _QuickViewScreenState();
}

class _QuickViewScreenState extends State<QuickViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick View'),
      ),
      body: const WeatherAPI(), // Display WeatherMapWidget
    );
  }
}