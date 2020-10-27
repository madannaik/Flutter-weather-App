import 'dart:async' show Future;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/data/forecast_data.dart';
import 'package:weather_icons/weather_icons.dart';

import '../data/weather.dart';
import 'bottom.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var future;
  var weatherData;

  WeatherModel weatherModel = new WeatherModel();
  Future weatherdata() async {
    weatherData = await weatherModel.getLocationWeather();
    return weatherData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: weatherdata(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Future.delayed(Duration(seconds: 2));
          Fluttertoast.showToast(
              msg: "Check you internet or enable Location",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 4,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          SystemNavigator.pop();
        }

        return snapshot.hasData
            ? MyWeatherScreen(
                weatherData: snapshot.data,
              )
            : Container(
                width: double.infinity,
                height: double.infinity,
                child: Image(
                  image: AssetImage('images/img.png'),
                  fit: BoxFit.fitWidth,
                ),
              );
      },
    );
  }
}

class MyWeatherScreen extends StatefulWidget {
  final weatherData;

  MyWeatherScreen({this.weatherData});
  @override
  _MyWeatherScreenState createState() => _MyWeatherScreenState();
}

class _MyWeatherScreenState extends State<MyWeatherScreen> {
  String place;
  String condition;
  double temperature;
  double pressure;
  int humidity;
  double windSpeed;
  String iconUrl;
  int dayOrNight;
  double height, width;
  int code;
  bool day;
  bool isCollapsed = false;
  var cityWeather;
  String cityInput;

  WeatherModel weatherModel = new WeatherModel();
  void getCityWeather() async {
    if (cityInput != null) {
      cityWeather = await weatherModel.getCityWeather(cityInput);
      if (cityWeather == 400) {
        Fluttertoast.showToast(
          msg: "Enter a Correct City Name",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.white,
          textColor: Color(0xFF28df99),
          fontSize: 16.0,
        );
      } else {
        getData(cityWeather);
      }
    }
  }

  void getData(weatherData) {
    setState(() {
      place = weatherData['location']['name'];
      condition = weatherData['current']['condition']['text'];
      windSpeed = weatherData['current']['wind_kph'];
      pressure = weatherData['current']['pressure_in'];
      humidity = weatherData['current']['humidity'];
      temperature = weatherData['current']['temp_c'];
      iconUrl = weatherData['current']['condition']['icon'];
      dayOrNight = weatherData['current']['is_day'];
      code = weatherData['current']['condition']['code'];
      iconUrl = iconUrl.substring(2);
      if (condition.length >= 22) {
        condition = '${condition.substring(0, 22)}\n${condition.substring(23)}';
      }
      if (code == 0) {
        day = true;
      } else {
        day = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getData(widget.weatherData);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            //color: Colors.amber,
            decoration: BoxDecoration(
              color: Color(0xFF28df99),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: height * 0.045,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.my_location),
                      onPressed: () {
                        print('hii');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()));
                      },
                    ),
                    IconButton(
                        icon: Icon(Icons.search),
                        color: Colors.black,
                        iconSize: 30,
                        onPressed: () {
                          setState(() {
                            isCollapsed = !isCollapsed;
                          });
                        })
                  ],
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Text(
                  place ?? 'Home',
                  style: GoogleFonts.roboto(fontSize: 50, color: Colors.white),
                ),
                Text(
                  'Today',
                  style: GoogleFonts.openSansCondensed(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: height * 0.1,
                ),
                Row(
                  children: [
                    Container(
                      height: height * 0.17,
                      width: width * 0.35,
                      child: Image(
                        image: NetworkImage("https://$iconUrl"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          temperature.toString() + '° C' ?? '25° C',
                          style: GoogleFonts.openSansCondensed(
                            fontSize: 80,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          condition.toString(),
                          style: GoogleFonts.openSansCondensed(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _bottomItems(
                        iconsData: WeatherIcons.windy,
                        details: windSpeed.toString(),
                        contraints: 'km/h'),
                    _bottomItems(
                        iconsData: WeatherIcons.humidity,
                        details: humidity.toString(),
                        contraints: '%'),
                    _bottomItems(
                        iconsData: WeatherIcons.barometer,
                        details: pressure.toString(),
                        contraints: 'inches'),
                  ],
                )
              ],
            ),
          ),
          FutureBuilder<List<Forecast>>(
            future: fetchForecastData(http.Client(), place),
            builder: (context, snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              return snapshot.hasData
                  ? BottomSheetNew(
                      futureForecast: snapshot.data,
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.transparent,
                      ),
                    );
            },
          ),
          animatedSearchBox(),
        ],
      ),
    );
  }

  Widget _bottomItems({iconsData, String details, String contraints}) {
    return Column(
      children: [
        Icon(iconsData),
        SizedBox(
          height: 5,
        ),
        Text(
          details,
          style: GoogleFonts.openSansCondensed(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        Text(
          contraints,
          style: GoogleFonts.openSansCondensed(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget animatedSearchBox() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      top: isCollapsed ? height * 0.4 : -height * 0.4,
      left: width * 0.1,
      right: width * 0.1,
      curve: Curves.linear,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          color: Colors.white,
          width: width * 0.8,
          height: height * 0.25,
          child: Column(
            children: [
              SizedBox(
                height: height * 0.05,
              ),
              Container(
                width: width * 0.6,
                child: TextField(
                  onChanged: (value) {
                    cityInput = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter City Name',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: MaterialButton(
                  onPressed: () {
                    getCityWeather();
                    setState(() {
                      isCollapsed = !isCollapsed;
                    });
                  },
                  child: Text("Search"),
                  color: Color(0xFF28df99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
