import 'package:flutter/material.dart';
import 'package:panahon/weather_api.dart';

class WeatherDataSection extends StatefulWidget {
  final WeatherAPI weatherAPI;
  const WeatherDataSection({super.key, required this.weatherAPI});

  @override
  State<WeatherDataSection> createState() =>
      _WeatherDataSectionState(weather: weatherAPI);
}

// enum WeatherData { rain, temperature, wind, pressure }
List<String> WeatherData = ["Rain", "Temperature", "Wind", "Pressure"];

class _WeatherDataSectionState extends State<WeatherDataSection> {
  WeatherAPI weather;
  _WeatherDataSectionState({required this.weather});
  String weatherDataView = WeatherData[1];
  late String primaryUnit;
  late String primaryObservation;
  late String secondaryText;
  late String secondaryObservation;
  late String secondaryUnit;

  @override
  Widget build(BuildContext context) {
    // weather.initializeData();
    switch (weatherDataView) {
      case "Rain":
        primaryObservation = "rain";
        primaryUnit = "mm";
        secondaryText = "24hr total";
        secondaryObservation = "rain_accum";
        secondaryUnit = primaryUnit;
        break;
      case "Temperature":
        primaryObservation = "temp";
        primaryUnit = "°C";
        secondaryText = "Feels like";
        secondaryObservation = "hi";
        secondaryUnit = "°C";
        break;
      case "Wind":
        primaryObservation = "wspd";
        primaryUnit = "m/s";
        secondaryText = "Direction";
        secondaryObservation = "wdir";
        secondaryUnit = "";
        break;
      case "Pressure":
        primaryObservation = "mslp";
        primaryUnit = "hPa";
        secondaryText = "";
        secondaryObservation = "mslp";
        secondaryUnit = "hPa";
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Column(
          spacing: 8,
          children: [
            Expanded(child: Container()),
            Container(
              // height: 56,
              decoration: const BoxDecoration(
                  color: Color.fromRGBO(238, 237, 244, 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(36))),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ),
                child: Text(
                  weatherDataView,
                  textScaler: TextScaler.linear(2.0),
                ),
              ),
            ),
            FutureBuilder(
                future: weather.getData(weather.selectedLocation),
                builder: (context, snapshot) {
                  Widget leftSection;
                  Widget middleSection;
                  Widget rightSection;
                  if (snapshot.hasData) {
                    leftSection = Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("as of", textScaler: TextScaler.linear(0.8)),
                          Text(snapshot.data!["date"]!,
                              textScaler: TextScaler.linear(0.8)),
                          Text(snapshot.data!["time"]!,
                              textScaler: TextScaler.linear(0.8)),
                        ]);
                    middleSection = RichText(
                        text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: snapshot.data![primaryObservation],
                                style: TextStyle(fontSize: 36),
                              ),
                              WidgetSpan(
                                  child: SizedBox(
                                    width: 8,
                                  )),
                              TextSpan(
                                text: primaryUnit,
                                style: TextStyle(fontSize: 12),
                              )
                            ]));
                    rightSection = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(secondaryText, textScaler: TextScaler.linear(0.8)),
                          Row(mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(snapshot.data![secondaryObservation]!,
                                  textScaler: TextScaler.linear(2)),
                              Text(secondaryUnit,
                                  textScaler: TextScaler.linear(0.8)),
                            ],
                          ),
                        ]);
                  } else {
                    leftSection = CircularProgressIndicator();
                    middleSection = CircularProgressIndicator();
                    rightSection = CircularProgressIndicator();
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Flexible(
                        child: Container(
                          height: 80,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(32),
                                right: Radius.circular(16)),
                            color: Color.fromRGBO(238, 237, 244, 1.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            child: leftSection,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadiusGeometry.circular(16),
                            color: const Color.fromRGBO(238, 237, 244, 1.0),
                          ),
                          child: Center(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                child: middleSection),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: 88, // TODO: make adaptive
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(16),
                              right: Radius.circular(32),
                            ),
                            color: Color.fromRGBO(238, 237, 244, 1.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            child: rightSection,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
            Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              // height: 32,
              decoration: BoxDecoration(
                color: Color.fromRGBO(238, 237, 244, 1.0),
                borderRadius: BorderRadiusGeometry.circular(32),
              ),
              child: SegmentedButton<String>(
                style: SegmentedButton.styleFrom(),
                segments: <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: WeatherData[0],
                    tooltip: WeatherData[0],
                    // label: Text('Rain'),
                    icon: const Icon(Icons.cloudy_snowing),
                  ),
                  ButtonSegment<String>(
                    value: WeatherData[1],
                    tooltip: WeatherData[1],
                    // label: Text('Temp'),
                    icon: const Icon(Icons.thermostat),
                  ),
                  ButtonSegment<String>(
                    value: WeatherData[2],
                    tooltip: WeatherData[2],
                    // label: Text('Wind'),
                    icon: const Icon(Icons.air),
                  ),
                  ButtonSegment<String>(
                    value: WeatherData[3],
                    tooltip: WeatherData[3],
                    // label: Text('Pressure'),
                    icon: const Icon(Icons.speed),
                  ),
                ],
                selected: <String>{weatherDataView},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    // By default there is only a single segment that can be
                    // selected at one time, so its value is always the first
                    // item in the selected set.
                    weatherDataView = newSelection.first;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
