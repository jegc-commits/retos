import 'package:flutter/material.dart';
import 'reto1_peliculas.dart';
import 'reto2_gatos.dart';
import 'reto3_clima.dart';
import 'reto4_cripto.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Los Cuatro Retos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const Home(),
      );
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final retos = <(String, String, IconData, Widget)>[
      ('Reto 1', 'Recomendador de películas', Icons.movie, const Reto1Peliculas()),
      ('Reto 2', 'Memes de gatos', Icons.pets, const Reto2Gatos()),
      ('Reto 3', 'Clima minimalista', Icons.wb_sunny, const Reto3Clima()),
      ('Reto 4', 'Convertidor de cripto', Icons.currency_bitcoin, const Reto4Cripto()),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Los Cuatro Retos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final r in retos)
            Card(
              child: ListTile(
                leading: Icon(r.$3, size: 32),
                title: Text(r.$1),
                subtitle: Text(r.$2),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => r.$4)),
              ),
            ),
        ],
      ),
    );
  }
}
