import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:dio/dio.dart';

class WeatherData {
  final String city;
  final String country;
  final double temperatureC;
  final double feelsLikeC;
  final String wind;
  final String conditionText;
  final String conditionImg;
  final int humidity;
  final double precipitationMm;

  WeatherData({
    required this.city,
    required this.country,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.wind,
    required this.conditionText,
    required this.conditionImg,
    required this.humidity,
    required this.precipitationMm,
  });
}

class WeatherForecast {
  final String date;
  final double maxTempC;
  final String conditionText;
  final String conditionImg;

  WeatherForecast({
    required this.date,
    required this.maxTempC,
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
  List<WeatherForecast> forecasts = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWeather("Ljubljana");
    fetchWeatherForecast("Ljubljana").then((value) {
      setState(() {
        forecasts = value;
      });
    });
  }

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
            feelsLikeC: responseData['current']['feelslike_c'],
            wind:
                'Wind: ${responseData['current']['wind_kph']} km/h ${responseData['current']['wind_dir']}',
            conditionText: responseData['current']['condition']['text'],
            conditionImg:
                'http:' + responseData['current']['condition']['icon'],
            humidity: responseData['current']['humidity'],
            precipitationMm: responseData['current']['precip_mm'].toDouble(),
          );
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<WeatherForecast>> fetchWeatherForecast(String city) async {
    try {
      final response = await dio.get(
          'http://api.weatherapi.com/v1/forecast.json?key=<api_key>&q=$city&days=3&aqi=no&alerts=no');
      if (response.statusCode == 200) {
        final responseData = response.data;
        final forecastList =
            responseData['forecast']['forecastday'] as List<dynamic>;

        List<WeatherForecast> forecasts = [];
        int daysAdded = 0;

        for (var forecastData in forecastList) {
          final date = forecastData['date'] as String;

          final maxTempC = forecastData['day']['maxtemp_c'] as double;
          final conditionText =
              forecastData['day']['condition']['text'] as String;
          final conditionImg =
              'http:' + forecastData['day']['condition']['icon'] as String;

          forecasts.add(WeatherForecast(
            date: date,
            maxTempC: maxTempC,
            conditionText: conditionText,
            conditionImg: conditionImg,
          ));
          daysAdded++;

          if (daysAdded == 3) {
            break;
          }
        }

        return forecasts;
      }
    } catch (e) {
      print(e);
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Weather App'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logOut(context),
            ),
          ],
        ),
        body: ListView(padding: const EdgeInsets.all(16.0), children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter city',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  fetchWeather(_controller.text);
                  fetchWeatherForecast(_controller.text).then((value) {
                    setState(() {
                      forecasts = value;
                    });
                  });
                },
              ),
            ),
          ),
          if (weatherData != null)
            Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${weatherData!.city}, ${weatherData!.country}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Temperature: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${weatherData!.temperatureC}°C',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Feels Like: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${weatherData!.feelsLikeC}°C',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Wind: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weatherData!.wind,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Humidity: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${weatherData!.humidity}%',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Precipitation: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${weatherData!.precipitationMm.toStringAsFixed(2)} mm',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weatherData!.conditionText,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      weatherData!.conditionImg,
                      width: 200,
                      height: 200,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          if (forecasts.isNotEmpty)
            const Center(
              child: Text(
                '3-Day Forecast:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Row(
            children: [
              for (var forecast in forecasts) ...[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(forecast.date),
                      Text(
                        'Temperature: ${forecast.maxTempC.toStringAsFixed(1)}°C',
                      ),
                      Text(forecast.conditionText),
                      Image.network(
                        forecast.conditionImg,
                        width: 64,
                        height: 64,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          )
        ]));
  }
}
