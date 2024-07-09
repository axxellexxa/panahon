import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class WeatherAPI extends StatefulWidget {
  const WeatherAPI({super.key});

  @override
  _WeatherAPIState createState() => _WeatherAPIState();
}

class _WeatherAPIState extends State<WeatherAPI> {
  double temperature = 0.0;
  double rain = 0.0;
  double windSpeed = 0.0;
  double pressure = 0.0;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Example: Fetch weather data for initial location
    fetchWeatherData(14.5995, 120.9842); // Example: Manila, Philippines coordinates
  }

  void fetchWeatherData(double lat, double lon) async {
    // Replace with your actual weather API integration logic
    String apiKey = '82febee1d40b64392c1d7d487e63b875';
    String apiUrl = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey';

    // Example HTTP request using http package
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        temperature = data['main']['temp'];
        rain = data['rain']!= null? data['rain']['1h']?? 0.0 : 0.0;
        windSpeed = data['wind']['speed'];
        pressure = data['main']['pressure'];
      });
    } else {
      print('Failed to fetch weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Map'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(14.599512,120.984222), // Initial map center (Philippines)
          minZoom: 0.0, // Initial zoom level
          onPositionChanged: (position, bounds) {
            print('Position changed to ${position.center.latitude}, ${position.center.longitude}');
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          // Custom Overlay for weather data (e.g., circles or custom markers for rain, wind speed, etc.)
          CircleLayer(
            circles: [
              CircleMarker(
                point: const LatLng(14.5995, 120.9842),
                color: Colors.blue.withOpacity(0.5),
                radius: rain * 500, // Adjust radius based on rain intensity
                borderColor: Colors.blue,
                borderStrokeWidth: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() => runApp(const MaterialApp(home: WeatherAPI()));
