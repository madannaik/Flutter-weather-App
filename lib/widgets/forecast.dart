// import 'package:flutter/material.dart';
// import 'package:weather_app/data/forecast_data.dart';
// import 'package:http/http.dart' as http;

// class MyForecastData extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('data'),
//       ),
//       body: FutureBuilder<List<Forecast>>(
//         future: fetchForecastData(http.Client()),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) print(snapshot.error);

//           return snapshot.hasData
//               ? forecastWidget(snapshot.data)
//               : Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }

// Widget forecastWidget(List<Forecast> json) {
//   return Container(
//     child: Text(
//       json[1].condition,
//       style: TextStyle(color: Colors.black),
//     ),
//   );
// }
//}
