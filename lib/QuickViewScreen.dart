import 'package:flutter/material.dart';
import 'weather_api.dart'; // Import your WeatherMapWidget.dart file
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'WeatherDataSection.dart';

class QuickViewScreen extends StatefulWidget {
  const QuickViewScreen({super.key});

  @override
  _QuickViewScreenState createState() => _QuickViewScreenState();
}

class _QuickViewScreenState extends State<QuickViewScreen> {
  final MapController _mapController = MapController();

  var weather = WeatherAPI();
  var weatherData;
  String selectedLocation = "Manila Observatory";

  @override
  void initState() {
    super.initState();
    // print(weather.data[0] ?? "no data =============");
    print("intialized");
    weather.initializeData();
  }

  @override
  Widget build(BuildContext context) {
    List<CircleMarker> circles = [
      CircleMarker(
        point: const LatLng(14.5995, 120.9842),
        color: Colors.blue.withAlpha(125),
        radius: 5, // Adjust radius based on rain intensity
        borderColor: Colors.indigo,
        borderStrokeWidth: 2,
      ),
      CircleMarker(
        point: const LatLng(14.635350998990003, 121.07793937540339),
        color: Colors.blue.withAlpha(125),
        radius: 5, // Adjust radius based on rain intensity
        borderColor: Colors.indigo,
        borderStrokeWidth: 2,
      ),
    ];
    return Scaffold(
      body: Column(
        children: [
          // FutureBuilder<dynamic>(
          //   future: weather.getData(selectedLocation, "id"),
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData && snapshot.data != "null") {
          //         return Text(snapshot.data!);
          //     } else if (snapshot.hasError) {
          //       return Text('${snapshot.error}');
          //     }
          //     return Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: const CircularProgressIndicator(),
          //     );
          //   }
          // ),
          FutureBuilder<List<DropdownMenuEntry>>(
            future: weather.getLocations(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DropdownMenu(
                  // width: 500,
                  expandedInsets: EdgeInsetsGeometry.all(8),
                  menuHeight: 200,
                  hintText: "Location",
                  dropdownMenuEntries: snapshot.data!,
                  initialSelection: selectedLocation, // TODO: Fix this
                  onSelected: (location){
                    setState(() {
                      selectedLocation = location;
                      weather.selectedLocation = location;
                    });
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            }),
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.center,
                children: [
              FutureBuilder(
                future: weather.getLocationCoords(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return FlutterMap(
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
                          // urlTemplate:
                          //     'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          // subdomains: const ['a', 'b', 'c'],
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // TODO: take care of tile use policy
                        ),
                        // Custom Overlay for weather data (e.g., circles or custom markers for rain, wind speed, etc.)
                        CircleLayer(
                          circles: snapshot.data!
                        ),
                      ],
                    );
                  }
                  return FlutterMap(
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
                        // urlTemplate:
                        //     'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        // subdomains: const ['a', 'b', 'c'],
                        urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // TODO: take care of tile use policy
                      ),
                      // Custom Overlay for weather data (e.g., circles or custom markers for rain, wind speed, etc.)
                      CircleLayer(
                      circles: [
                      CircleMarker(
                      point: const LatLng(14.5995, 120.9842),
                  color: Colors.blue.withAlpha(125),
                  radius: 5, // Adjust radius based on rain intensity
                  borderColor: Colors.indigo,
                  borderStrokeWidth: 2,
                  ),
                  ],
                  ),
                    ],
                  );
                }
              ),
              Positioned.fill(
                  bottom: 8,
                  child: WeatherDataSection(weatherAPI: weather)
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
