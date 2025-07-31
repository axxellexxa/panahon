import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class WeatherAPI {
  WeatherAPI();

  double temperature = 0.0;
  double rain = 0.0;
  double windSpeed = 0.0;
  double pressure = 0.0;
  String apiUrl =
      'https://panahon.observatory.ph/data/api/v1/observations/latest';
  String selectedLocation =
      "Manila Observatory"; // TODO: should default to closest location
  ValueNotifier<String> selectedData = ValueNotifier<String>("Temperature");

  List<dynamic> data = [];

  /// Fetches data from the API
  void initializeData() async {
    // Example HTTP request using http package
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
    } else {
      print('Failed to fetch weather data');
    }
  }

  /// Ensures that the [input] is non-null and rounds it to the specified amount of [digits]
  String nullHelper(dynamic input, int digits) {
    if (input.runtimeType == int || input.runtimeType == double) {
      return input.toStringAsFixed(digits);
    } else {
      return "n/a";
    }
  }

  /// Collates needed data about the specified location
  Future<Map<String, String>> getData(String location) async {
    Map source = data.firstWhere((element) => element["name"] == location,
        orElse: () => {});
    Map<String, String> outputData = {
      "id": source["id"].toString(),
      "name": source["name"],
      "lat": source["lat"].toString(),
      "lon": source["lon"].toString(),
      "rain": nullHelper(source["obs"]["rain"], 1),
      "rain_accum": nullHelper(source["obs"]["rain_accum"], 1),
      "temp": nullHelper(source["obs"]["temp"], 1),
      "hi": calcHeatIndex(source["obs"]["temp"], source["obs"]["rh"]),
      "wspd": nullHelper(source["obs"]["wspd"], 1),
      "wdir": calcWindDirection(source["obs"]["wdir"]),
      "mslp": nullHelper(source["obs"]["mslp"], 1),
      "date": DateFormat("d MMM y").format(DateTime.parse(source["obs"]["timestamp"]).toLocal()),
      "time": DateFormat("jm").format(DateTime.parse(source["obs"]["timestamp"]).toLocal()),
    };
    return outputData;
  }

  /// Returns a two lists: a list of [DropdownMenuEntry] and another list with their respective coordinates.
  Future<List<dynamic>> getDropdownLocations() async { // TODO: rename function
    List<DropdownMenuEntry<String>> entries = [];
    Map<String, LatLng> coords = {};
    for (var location in data) {
      entries.add(
         DropdownMenuEntry(value: location["name"], label: location["name"]));
      coords[location["name"]] = LatLng(location["lat"] ?? 0, location["lon"] ?? 0);
    }
    return [entries, coords];
  }

  /// Returns four sets of [CircleMarker] for each coordinate, one for each data type
  Future<List<List<CircleMarker>>> getMapLocations() async { // TODO: rename function
    List<List<CircleMarker>> output = [];
    List types = ["Rain", "Temperature", "Wind", "Pressure"];
    String obs = "";
    Color borderColor = Colors.black;
    Color startColor = Colors.white70;
    Color endColor = Colors.white10;
    double minimum = 0;
    double diff = 0;
    for (var t in types) {
      switch (t) {
        case "Rain":
          obs = "rain";
          borderColor = Colors.blue;
          startColor = Color.fromRGBO(0xde, 0xeb, 0xf7, 1);
          endColor = Color.fromRGBO(0x08, 0x50, 0x9b, 1);
          minimum = 0;
          diff = 25;
          break;
        case "Temperature":
          obs = "temp";
          borderColor = Colors.red;
          startColor = Color.fromRGBO(0xfe, 0xe0, 0xd2, 1);
          endColor = Color.fromRGBO(0xa3, 0x0f, 0x15, 1);
          minimum = 25;
          diff = 10;
          break;
        case "Wind":
          obs = "wspd";
          borderColor = Colors.green;
          startColor = Colors.green.shade200;
          endColor = Colors.green.shade900;
          minimum = 0;
          diff = 10;
          break;
        case "Pressure":
          obs = "mslp";
          borderColor = Colors.orange;
          startColor = Colors.orange.shade200;
          endColor = Colors.orange.shade900;
          minimum = 1000;
          diff = 200;
          break;
      }
      List<CircleMarker> outputCircles = [];
      for (var location in data) {
        try {
          bool isObsNull = (location["obs"][obs] == null);
          LatLng coords = LatLng(location["lat"] ?? 0, location["lon"] ?? 0);
          CircleMarker circle = CircleMarker(
            point: coords,
            radius: 5,
            borderStrokeWidth: isObsNull ? 2 : 5,
            color: colorHelper(location["obs"][obs], startColor, endColor, minimum, diff),
            borderColor: isObsNull ? Colors.black : borderColor,
            hitValue: location["name"],
          );
        outputCircles.add(circle);
        } catch (e) {
          print("something bad happened with ${location["id"]} : $e");
        }
      }
      output.add(outputCircles);
    }
    return output;
  }

  /// Handles null and out-of-bounds values to be used in the colors for [getMapLocations]
  Color colorHelper(dynamic value, Color start, Color end, double minimum, double diff) {
    if (value != null) {
      num t = value;
      if (value > minimum + diff) {
        t = minimum + diff;
      } else if (value < minimum) {
        t = minimum;
      }
      return Color.lerp(start, end, (t - minimum)/diff)!;
    }
    return Colors.black.withAlpha(0);
  }

  /// Calculates heat index from a given temperature and relative humidity
  String calcHeatIndex(dynamic temp, dynamic rh) {
    if (temp == null || rh == null) {
      return "n/a";
    }
    // source: https://github.com/mcci-catena/heat-index/blob/master/heat-index.js
    double tf = (temp * 9.0) / 5.0 + 32.0;
    double tfRounded = (tf + 0.5).floorToDouble();

    // return null outside the specified range of input parameters
    if (tfRounded < 76 || tfRounded > 126) {
      return "n/a";
    }
    if (rh < 0 || rh > 100) {
      return "n/a";
    }

    // according to the NWS, we try this first, and use it if we can
    double hiEasyF = 0.5 * (tf + 61.0 + (tf - 68.0) * 1.2 + rh * 0.094);

    // The NWS says we use tHeatEasy if (tHeatHeasy + t)/2 < 80.0
    // This is the same computation:
    if (hiEasyF + tf < 160.0) {
      double hiEasy = ((hiEasyF - 32.0) * 5.0) / 9.0;
      return ((hiEasy * 10).roundToDouble() / 10).toStringAsFixed(1);
    }

    // need to use the hard form, and possibly adjust.
    double tf2 = tf * tf;
    double rh2 = pow(rh, 2).toDouble();
    double hiF = -42.379 +
        2.04901523 * tf +
        10.14333127 * rh -
        0.22475541 * tf * rh -
        0.00683783 * tf2 -
        0.05481717 * rh2 +
        0.00122874 * tf2 * rh +
        0.00085282 * tf * rh2 -
        0.00000199 * tf2 * rh2;

    // these adjustments come from the NWA page, and are needed to
    // match the reference table.
    double tAdjF;
    if (rh < 13.0 && 80.0 <= tf && tf <= 112.0) {
      tAdjF = -((13.0 - rh) / 4.0) * sqrt((17.0 - (tf - 95.0).abs()) / 17.0);
    } else if (rh > 85.0 && 80.0 <= tf && tf <= 87.0) {
      tAdjF = ((rh - 85.0) / 10.0) * ((87.0 - tf) / 5.0);
    } else {
      tAdjF = 0;
    }

    // apply the adjustment
    hiF += tAdjF;

    // finally, the reference tables have no data above 183 (rounded),
    // so filter out answers that we have no way to vouch for.
    if (hiF >= 183.5) {
      return "n/a";
    } else {
      double hiC = ((hiF - 32.0) * 5.0) / 9.0;
      return ((hiC * 10).roundToDouble() / 10).toStringAsFixed(1);
    }
  }

  /// Determines wind direction from angle [wdir]
  String calcWindDirection(dynamic wdir) {
    if (wdir.runtimeType != double && wdir.runtimeType != int) { // TODO: consider erroneous values (e.g. < 0 || > 360)
      return 'n/a';
    }
    if (wdir <= 22.5) {
      return 'N';
    } else if (wdir <= 45) {
      return 'NNE';
    } else if (wdir <= 67.5) {
      return 'NE';
    } else if (wdir <= 90) {
      return 'ENE';
    } else if (wdir <= 112.5) {
      return 'E';
    } else if (wdir <= 135) {
      return 'ESE';
    } else if (wdir <= 157.5) {
      return 'SE';
    } else if (wdir <= 180) {
      return 'SSE';
    } else if (wdir <= 202.5) {
      return 'S';
    } else if (wdir <= 225) {
      return 'SSW';
    } else if (wdir <= 247.5) {
      return 'SW';
    } else if (wdir <= 270) {
      return 'WSW';
    } else if (wdir <= 292.5) {
      return 'W';
    } else if (wdir <= 315) {
      return 'WNW';
    } else if (wdir <= 337.5) {
      return 'NW';
    } else {
      return 'NNW';
    }
  }
}
