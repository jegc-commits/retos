import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// API key gratis en https://openweathermap.org/api (tarda ~1-2 h en activarse)
const owmApiKey = '4271a18bfd105351aede323201726e8a';

class Weather {
  final String city, description, icon;
  final double temp, feelsLike, wind;
  final int humidity;

  Weather.fromJson(Map<String, dynamic> j)
      : city = j['name'] ?? '',
        description = j['weather'][0]['description'] ?? '',
        icon = j['weather'][0]['icon'] ?? '01d',
        temp = (j['main']['temp'] as num).toDouble(),
        feelsLike = (j['main']['feels_like'] as num).toDouble(),
        humidity = j['main']['humidity'] as int,
        wind = (j['wind']['speed'] as num).toDouble();
}

class Reto3Clima extends StatefulWidget {
  const Reto3Clima({super.key});

  @override
  State<Reto3Clima> createState() => _Reto3State();
}

class _Reto3State extends State<Reto3Clima> {
  final _ctrl = TextEditingController(text: 'Dolores Hidalgo');
  Weather? _weather;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
        'q': _ctrl.text.trim(),
        'appid': owmApiKey,
        'units': 'metric',
        'lang': 'es',
      });
      final r = await http.get(uri);
      if (r.statusCode == 404) throw Exception('Ciudad no encontrada');
      if (r.statusCode == 401)
        throw Exception('API key inválida o aún no activa');
      if (r.statusCode != 200) throw Exception('Error ${r.statusCode}');
      setState(() => _weather = Weather.fromJson(jsonDecode(r.body)));
    } catch (e) {
      setState(() {
        _weather = null;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = _weather;
    return Scaffold(
      appBar: AppBar(title: const Text('Clima')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                labelText: 'Ciudad',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                    icon: const Icon(Icons.search), onPressed: _fetch),
              ),
              onSubmitted: (_) => _fetch(),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(child: Center(child: Text(_error!)))
            else if (w != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(w.city,
                        style: Theme.of(context).textTheme.headlineMedium),
                    Image.network(
                        'https://openweathermap.org/img/wn/${w.icon}@4x.png',
                        width: 140,
                        height: 140),
                    Text('${w.temp.toStringAsFixed(1)}°C',
                        style: Theme.of(context).textTheme.displayMedium),
                    Text(w.description.toUpperCase()),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _info(Icons.thermostat, 'Sensación',
                            '${w.feelsLike.toStringAsFixed(1)}°C'),
                        _info(Icons.water_drop, 'Humedad', '${w.humidity}%'),
                        _info(Icons.air, 'Viento', '${w.wind} m/s'),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData i, String label, String value) => Column(
        children: [
          Icon(i),
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
        ],
      );
}
