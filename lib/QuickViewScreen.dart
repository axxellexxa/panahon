import 'package:flutter/material.dart';
import 'weather_api.dart'; // Import your WeatherMapWidget.dart file
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'WeatherDataSection.dart';
import 'package:collection/collection.dart';

class QuickViewScreen extends StatefulWidget {
  const QuickViewScreen({super.key});

  @override
  _QuickViewScreenState createState() => _QuickViewScreenState();
}

class _QuickViewScreenState extends State<QuickViewScreen> {
  final MapController _mapController = MapController();
  final TextEditingController locationController = TextEditingController();

  var weather = WeatherAPI();
  var weatherData;

  final LayerHitNotifier<Object> hitNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    weather.initializeData();
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    controller: locationController,
                    leadingIcon: Icon(Icons.pin_drop),
                    // width: 500,
                    expandedInsets: EdgeInsetsGeometry.all(8),
                    menuHeight: 200,
                    hintText: "Location",
                    dropdownMenuEntries: snapshot.data!,
                    initialSelection: snapshot.data!
                        .firstWhereOrNull(
                            (element) => element.value == "Manila Observatory")
                        ?.value, // TODO: Default to closest station
                    onSelected: (location) {
                      setState(() {
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
            child: Stack(alignment: AlignmentDirectional.center, children: [
              FutureBuilder(
                  future: weather.getLocationCoords(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(14.599512,
                              120.984222), // Initial map center (Philippines)
                          minZoom: 0.0, // Initial zoom level
                          onPositionChanged: (position, bounds) {
                            // print('Position changed to ${position.center.latitude}, ${position.center.longitude}');
                          },
                        ),
                        children: [
                          TileLayer(
                            userAgentPackageName: "com.example.panahon",
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // TODO: take care of tile use policy
                          ),
                          // Custom Overlay for weather data (e.g., circles or custom markers for rain, wind speed, etc.)
                          GestureDetector(
                            onTap: () {
                              final LayerHitResult<Object>? result =
                                  hitNotifier.value;
                              locationController.text = result!.hitValues.first.toString();
                              if (result == null) return;
                              // print('Tapped on ${result.hitValues.first}');
                              setState(() {
                                weather.selectedLocation =
                                    result.hitValues.first.toString();
                              });
                            },
                            child: CircleLayer(
                                hitNotifier: hitNotifier,
                                circles: snapshot.data!),
                          ),
                        ],
                      );
                    }
                    return FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(14.599512,
                            120.984222), // Initial map center (Philippines)
                        minZoom: 0.0, // Initial zoom level
                        onPositionChanged: (position, bounds) {
                          // print('Position changed to ${position.center.latitude}, ${position.center.longitude}');
                        },
                      ),
                      children: [
                        TileLayer(
                          userAgentPackageName: "com.example.panahon",
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // TODO: take care of tile use policy
                          // 'https://api.mapbox.com/styles/v1/rcandari/cmd6y916r03bp01r54nqogxg9/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicmNhbmRhcmkiLCJhIjoiY21jYTYwMGdqMDAxYTJtcG9waTIyb2dnZiJ9.frUb6ustrXPs2zPS6m6VzQ', // TODO: take care of tile use policy
                        ),
                        // Custom Overlay for weather data (e.g., circles or custom markers for rain, wind speed, etc.)
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: const LatLng(14.5995, 120.9842),
                              color: Colors.blue.withAlpha(125),
                              radius:
                                  5, // Adjust radius based on rain intensity
                              borderColor: Colors.indigo,
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
              Positioned.fill(
                  bottom: 8, child: WeatherDataSection(weatherAPI: weather)),
            ]),
          ),
        ],
      ),
    );
  }
}
