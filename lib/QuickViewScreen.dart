import 'package:flutter/material.dart';
import 'weather_api.dart'; // Import your WeatherMapWidget.dart file
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class QuickViewScreen extends StatefulWidget {
  const QuickViewScreen({super.key});

  @override
  _QuickViewScreenState createState() => _QuickViewScreenState();
}

class _QuickViewScreenState extends State<QuickViewScreen> {
  final MapController _mapController = MapController();

  var weather = WeatherAPI();
  var weatherData;

  @override
  void initState() {
    super.initState();
    print("quick view state");
    // print(weather.data[0] ?? "no data =============");
    weatherData = weather.fetchWeatherData("Manila Observatory");
  }

  @override
  Widget build(BuildContext context) {
    print("quick view build");
    return Scaffold(
      body: Column(
        children: [
          FutureBuilder<dynamic>(
              future: weatherData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!["name"].toString());
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              }),
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.center,
                children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(14.599512, 120.984222), // Initial map center (Philippines)
                  minZoom: 0.0, // Initial zoom level
                  onPositionChanged: (position, bounds) {
                    // print('Position changed to ${position.center.latitude}, ${position.center.longitude}');
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  // Custom Overlay for weather data (e.g., circles or custom markers for rain, wind speed, etc.)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: const LatLng(14.5995, 120.9842),
                        color: Colors.blue.withOpacity(0.5),
                        radius: 5, // Adjust radius based on rain intensity
                        borderColor: Colors.blue,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
