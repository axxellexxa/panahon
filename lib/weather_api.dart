import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class WeatherMapWidget extends StatefulWidget {
  @override
  _WeatherMapWidgetState createState() => _WeatherMapWidgetState();
}

class _WeatherMapWidgetState extends State<WeatherMapWidget> {
  double temperature = 0.0;
  double rain = 0.0;
  double windSpeed = 0.0;
  double pressure = 0.0;

  @override
  void initState() {
    super.initState();
    // Example: Fetch weather data for initial location
    fetchWeatherData(14.5995, 120.9842); // Example: Manila, Philippines coordinates
  }

  void fetchWeatherData(double lat, double lon) async {
    // Replace with your actual weather API integration logic
    String apiKey = 'your_api_key_here';
    String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey';

    // Example HTTP request using http package
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        temperature = data['main']['temp'];
        rain = data['rain'] != null ? data['rain']['1h'] ?? 0.0 : 0.0;
        windSpeed = data['wind']['speed'];
        pressure = data['main']['pressure'];
      });
    } else {
      print('Failed to fetch weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(14.5995, 120.9842), // Initial map center (Manila, Philippines)
        zoom: 10.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        // Custom Overlay for weather data (e.g., circles or custom markers for rain, wind speed, etc.)
        CircleLayerOptions(
          circles: [
            CircleMarker(
              point: LatLng(14.5995, 120.9842),
              color: Colors.blue.withOpacity(0.5),
              radius: rain * 500, // Adjust radius based on rain intensity
              borderColor: Colors.blue,
              borderStrokeWidth: 2,
            ),
          ],
        ),
      ],
    );
  }
}
