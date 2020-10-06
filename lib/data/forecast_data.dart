import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<List<Forecast>> fetchForecastData(
    http.Client client, String place) async {
  final response = await client.get(
      'http://api.weatherapi.com/v1/forecast.json?key=a9c6320e20bf40c686d91935200310&q=$place&days=1');

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parsePhotos, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Forecast> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody);
  final halfparsed = parsed['forecast']['forecastday'][0]['hour'];

  return halfparsed.map<Forecast>((json) => Forecast.fromJson(json)).toList();
}

class Forecast {
  double temperature;
  String condition;
  double windSpeed;
  double pressure;
  String time;
  int humidity;
  String chancesOfRain;
  String url;

  Forecast(
      {this.chancesOfRain,
      this.condition,
      this.humidity,
      this.pressure,
      this.temperature,
      this.time,
      this.windSpeed,
      this.url});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      time: json['time'],
      temperature: json['temp_c'],
      chancesOfRain: json['chance_of_rain'],
      windSpeed: json['wind_kph'],
      pressure: json['pressure_in'],
      humidity: json['humidity'],
      condition: json['condition']['text'],
      url: json['condition']['icon'],
    );
  }
}
