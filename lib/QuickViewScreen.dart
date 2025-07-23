import 'package:flutter/material.dart';
import 'weather_api.dart'; // Import your WeatherMapWidget.dart file
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'WeatherDataSection.dart';
import 'package:collection/collection.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

class QuickViewScreen extends StatefulWidget {
  const QuickViewScreen({super.key});

  @override
  _QuickViewScreenState createState() => _QuickViewScreenState();
}

class _QuickViewScreenState extends State<QuickViewScreen> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
    cancelPreviousAnimations: true, // Default to false
  );
  final TextEditingController locationTextController = TextEditingController();

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
    locationTextController.dispose();
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
          FutureBuilder(
              future: weather.getLocations2(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DropdownMenu(
                    controller: locationTextController,
                    leadingIcon: Icon(Icons.pin_drop),
                    // width: 500,
                    expandedInsets: EdgeInsetsGeometry.all(8),
                    menuHeight: 200,
                    hintText: "Location",
                    dropdownMenuEntries: snapshot.data![0] as List<DropdownMenuEntry<String>>,
                    initialSelection: (snapshot.data![0] as List)
                        .firstWhereOrNull(
                            (element) => element.value == "Manila Observatory")
                        ?.value, // TODO: Default to closest station
                    onSelected: (location) {
                      _mapController.animateTo(dest: snapshot.data![1][location], zoom: 12);
                      setState(() {
                        weather.selectedLocation = location.toString(); // TODO: Check if this updates the info section
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
              ValueListenableBuilder(
                valueListenable: weather.selectedDataL,
                builder: (context, value, child) {
                  return FutureBuilder(
                      future: weather.getLocationCoords2(),
                      builder: (context, snapshot) {
                        int selectedCircleIndex = 1;
                        switch (weather.selectedDataL.value) {
                          case "Rain":
                            selectedCircleIndex = 0;
                            break;
                          case "Temperature":
                            selectedCircleIndex = 1;
                            break;
                          case "Wind":
                            selectedCircleIndex = 2;
                            break;
                          case "Pressure":
                            selectedCircleIndex = 3;
                            break;
                        }
                        if (snapshot.hasData) {
                          return FlutterMap(
                            mapController: _mapController.mapController,
                            options: MapOptions(
                              onMapReady: () {
                                _mapController.mapController.mapEventStream.listen((evt) {});
                              },
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
                                  locationTextController.text = result!.hitValues.first.toString();
                                  if (result == null) return;
                                  // print('Tapped on ${result.hitValues.first}');
                                  setState(() {
                                    weather.selectedLocation =
                                        result.hitValues.first.toString();
                                  });
                                  _mapController.animateTo(
                                      dest: LatLng(
                                          weather.data.firstWhereOrNull((element) => element["name"] == result.hitValues.first.toString())["lat"],
                                          weather.data.firstWhereOrNull((element) => element["name"] == result.hitValues.first.toString())["lon"]),
                                      zoom: _mapController.mapController.camera.zoom);
                                },
                                onDoubleTap: () {
                                  final LayerHitResult<Object>? result =
                                      hitNotifier.value;
                                  locationTextController.text = result!.hitValues.first.toString();
                                  if (result == null) return;
                                  // print('Tapped on ${result.hitValues.first}');
                                  setState(() {
                                    weather.selectedLocation =
                                        result.hitValues.first.toString();
                                  });
                                  _mapController.animateTo(
                                      dest: LatLng(
                                          weather.data.firstWhereOrNull((element) => element["name"] == result.hitValues.first.toString())["lat"],
                                          weather.data.firstWhereOrNull((element) => element["name"] == result.hitValues.first.toString())["lon"]),
                                      zoom: 12);
                                },
                                child: CircleLayer(
                                    hitNotifier: hitNotifier,
                                    circles: snapshot.data![selectedCircleIndex]),
                              ),
                            ],
                          );
                        }
                        print("===== MAP IS NOT WORKING =====");
                        return Center(child: CircularProgressIndicator(),);
                      });
                }
              ),
              Positioned.fill(
                  bottom: 8, child: WeatherDataSection(weatherAPI: weather)),
            ]),
          ),
        ],
      ),
    );
  }
}
