import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/data/forecast_data.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/weather.dart';
import 'bottom.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          SystemNavigator.pop();
        }

        return snapshot.hasData
            ? MyweatherScreen(weatherData: snapshot.data)
            : Container(
                width: double.infinity,
                height: double.infinity,
                child: Image(
                  image: AssetImage('images/sq.gif'),
                  fit: BoxFit.fitHeight,
                ),
              );
      },
    );
  }
}

class MyweatherScreen extends StatefulWidget {
  final weatherData;
  MyweatherScreen({this.weatherData});
  @override
  _MyweatherScreenState createState() => _MyweatherScreenState();
}

class _MyweatherScreenState extends State<MyweatherScreen> {
  String place;
  String condition;
  double temperture;
  double pressure;
  int humidty;
  double windSpeed;
  String iconUrl;
  int dayOrNight;

  @override
  void initState() {
    super.initState();
    setState(() {
      place = widget.weatherData['location']['name'];
      condition = widget.weatherData['current']['condition']['text'];
      windSpeed = widget.weatherData['current']['wind_kph'];
      pressure = widget.weatherData['current']['pressure_in'];
      humidty = widget.weatherData['current']['humidity'];
      temperture = widget.weatherData['current']['temp_c'];
      iconUrl = widget.weatherData['current']['condition']['icon'];
      dayOrNight = widget.weatherData['current']['is_day'];
      iconUrl = iconUrl.substring(2);
      if (condition.length >= 22) {
        condition = '${condition.substring(0, 22)}\n${condition.substring(23)}';
      }
    });
  }

  final snackBar = SnackBar(
    duration: Duration(seconds: 1),
    content: Text(
      'Waiting for Forecast Data',
      style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.bold),
    ),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {},
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            //color: Colors.amber,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/n.jpg'), fit: BoxFit.fill),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.my_location),
                      onPressed: () {
                        print('hii');
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
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
                  height: 110,
                ),
                Row(
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      child: Image(
                        image: NetworkImage('https://$iconUrl') ??
                            SvgPicture.asset('images/animated/day.svg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          temperture.toString() + '° C' ?? '25° C',
                          style: GoogleFonts.openSansCondensed(
                            fontSize: 80,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          condition.toString() ?? 'Light rain shower',
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
                  height: 150,
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
                        details: humidty.toString(),
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
          )
        ],
      ),
    );
  }

  Widget _bottomItems({iconsData, String details, String contraints}) {
    return Column(
      children: [
        Icon(iconsData),
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
}
