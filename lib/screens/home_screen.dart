import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:dio/dio.dart';

class WeatherData {
  final String city;
  final String country;
  final double temperatureC;
  final String wind;
  final String conditionText;
  final String conditionImg;

  WeatherData({
    required this.city,
    required this.country,
    required this.temperatureC,
    required this.wind,
    required this.conditionText,
    required this.conditionImg,
  });
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dio = Dio();
  WeatherData? weatherData;
  final TextEditingController _controller = TextEditingController();

  Future<void> _logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate back to the login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> fetchWeather(String city) async {
    try {
      final response = await dio.get(
          'http://api.weatherapi.com/v1/current.json?key=<api_key>&q=$city&aqi=no');
      if (response.statusCode == 200) {
        final responseData = response.data;
        setState(() {
          weatherData = WeatherData(
            city: responseData['location']['name'],
            country: responseData['location']['country'],
            temperatureC: responseData['current']['temp_c'],
            wind:
                'Wind: ${responseData['current']['wind_kph']} km/h ${responseData['current']['wind_dir']}',
            conditionText: responseData['current']['condition']['text'],
            conditionImg:
                'http:' + responseData['current']['condition']['icon'],
          );
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logOut(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter city',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  fetchWeather(_controller.text);
                },
              ),
            ),
          ),
          if (weatherData != null)
            Column(
              children: [
                Text(
                    '${weatherData!.city}, ${weatherData!.country}'),
                Text(
                    'Temperature (°C): ${weatherData!.temperatureC.toStringAsFixed(1)}'),
                Text(weatherData!.wind),
                Text('Condition: ${weatherData!.conditionText}'),
                Image.network(weatherData!.conditionImg),
              ],
            ),
        ],
      ),
    );
  }
}
