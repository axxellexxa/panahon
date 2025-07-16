import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  // String apiKey = '82febee1d40b64392c1d7d487e63b875';
  String apiUrl =
      'https://panahon.observatory.ph/data/api/v1/observations/latest';
  String selectedLocation =
      "Manila Observatory"; // TODO: should default to closest location

  List<dynamic> data = [];
  List<CircleMarker> outputCircles = [];

  void initializeData() async {
    // Example HTTP request using http package
    print("========== fetch data ==========");
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
    } else {
      print('Failed to fetch weather data');
    }
  }

  Future<String> getDataField(String location, String field) async {
    return data
        .firstWhere((element) => element["name"] == location,
            orElse: () => {field: null})[field]
        .toString();
  }

  Future<Map<String, dynamic>> getData_(String location) async {
    return data.firstWhere((element) => element["name"] == location,
        orElse: () =>
            {});
  }

  Future<Map<String, dynamic>> getData(String location) async {
    Map source = data.firstWhere((element) => element["name"] == location,
        orElse: () => {});
    Map<String, dynamic> outputData = {
      "id": source["id"],
      "name": source["name"],
      "lat": source["lat"],
      "lon": source["lon"],
      "rain": source["obs"]["rain"],
      "rain_accum": source["obs"]["rain_accum"].toStringAsFixed(2),
      "temp": source["obs"]["temp"],
      "hi": calcHeatIndex(source["obs"]["temp"], source["obs"]["rh"])
          .toStringAsFixed(1),
      "wspd": (source["obs"]["wspd"] as double).toStringAsFixed(2),
      "wdir": calcWindDirection(source["obs"]["wdir"]),
      "mslp": source["obs"]["mslp"].toString(),
      "date": DateFormat("d MMM y").format(DateTime.parse(source["obs"]["timestamp"]).toLocal()),
      "time": DateFormat("jm").format(DateTime.parse(source["obs"]["timestamp"]).toLocal()),
    };
    return outputData;
  }

  Future<List<DropdownMenuEntry>> getLocations() async {
    List<DropdownMenuEntry> outputList = [];
    for (var location in data) {
      outputList.add(
          DropdownMenuEntry(value: location["name"], label: location["name"]));
    }
    return outputList;
  }

  Future<List<CircleMarker>> getLocationCoords() async {
    for (var location in data) {
      LatLng coords = LatLng(location["lat"], location["lon"]);
      CircleMarker circle = CircleMarker(
        point: coords,
        radius: 5,
        borderStrokeWidth: 2,
        color: Colors.blue.withAlpha(125),
        borderColor: Colors.indigo,
        hitValue: location["name"],
      );
      outputCircles.add(circle);
      // print(outputCircles);
    }
    return outputCircles;
  }

  double calcHeatIndex(double temp, double rh) {
    // source: https://github.com/mcci-catena/heat-index/blob/master/heat-index.js
    double tf = (temp * 9.0) / 5.0 + 32.0;
    double tfRounded = (tf + 0.5).floorToDouble();

    // return null outside the specified range of input parameters
    if (tfRounded < 76 || tfRounded > 126) {
      return -0.0;
    }
    if (rh < 0 || rh > 100) {
      return -0.0;
    }

    // according to the NWS, we try this first, and use it if we can
    double hiEasyF = 0.5 * (tf + 61.0 + (tf - 68.0) * 1.2 + rh * 0.094);

    // The NWS says we use tHeatEasy if (tHeatHeasy + t)/2 < 80.0
    // This is the same computation:
    if (hiEasyF + tf < 160.0) {
      double hiEasy = ((hiEasyF - 32.0) * 5.0) / 9.0;
      return ((hiEasy * 10).roundToDouble() / 10);
    }

    // need to use the hard form, and possibly adjust.
    double tf2 = tf * tf;
    double rh2 = rh * rh;
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
      return -0.0;
    } else {
      double hiC = ((hiF - 32.0) * 5.0) / 9.0;
      return (hiC * 10).roundToDouble() / 10;
    }
  }

  String calcWindDirection(int wdir) {
    if (!(wdir >= 0 && wdir <= 360)) {
      return '';
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
