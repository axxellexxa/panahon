import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class WeatherAPI {
  WeatherAPI();

  double temperature = 0.0;
  double rain = 0.0;
  double windSpeed = 0.0;
  double pressure = 0.0;
  // String apiKey = '82febee1d40b64392c1d7d487e63b875';
  String apiUrl = 'https://panahon.observatory.ph/data/api/v1/observations/latest';

  List<dynamic> data = [];

  void initializeData() async {

    // Example HTTP request using http package
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
    } else {
      print('Failed to fetch weather data');
    }
  }

  Future<dynamic> getData(String location, String field) async {
    return data.firstWhere((element) => element[field] == location, orElse: () => {"${field}": null})[field];
  }

  Future<List<DropdownMenuEntry>> getLocations() async {
    List<DropdownMenuEntry> outputList = [];
    for (var location in data) {outputList.add(
      DropdownMenuEntry(value: location["name"], label: location["name"])
    );}
    return outputList;
  }
}