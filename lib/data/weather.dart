import 'location.dart';
import 'networking.dart';

const apiKey = 'a9c6320e20bf40c686d91935200310';
const openWeatherMapURL = 'http://api.weatherapi.com/v1';

class WeatherModel {
  Future<dynamic> getCityWeather(String cityName) async {
    NetworkHelper networkHelper = NetworkHelper(
        '$openWeatherMapURL/current.json?key=$apiKey&q=$cityName');

    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  Future<dynamic> getLocationWeather() async {
    Location location = Location();
    await location.getCurrentLocation();

    NetworkHelper networkHelper = NetworkHelper(
        '$openWeatherMapURL/current.json?key=$apiKey&q=${location.latitude},${location.longitude}');

    var weatherData = await networkHelper.getData();
    return weatherData;
  }
}
