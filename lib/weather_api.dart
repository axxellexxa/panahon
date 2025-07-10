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

  Future<List<dynamic>> fetchWeatherData(String location) async {

    // Example HTTP request using http package
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      return data;
    } else {
      print('Failed to fetch weather data');
    }
    return [];
  }
// var curLocationData = data.firstWhere((element) => element["name"] == location);
}
