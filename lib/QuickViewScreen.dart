import 'package:flutter/material.dart';
import 'weather_api.dart'; // Import your WeatherMapWidget.dart file

class QuickViewScreen extends StatefulWidget {
  @override
  _QuickViewScreenState createState() => _QuickViewScreenState();
}

class _QuickViewScreenState extends State<QuickViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick View'),
      ),
      body: WeatherAPI(), // Display WeatherMapWidget
    );
  }
}
