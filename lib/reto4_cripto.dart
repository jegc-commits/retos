import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _coins = <String, String>{
  'bitcoin': 'Bitcoin (BTC)',
  'ethereum': 'Ethereum (ETH)',
  'solana': 'Solana (SOL)',
};

Future<Map<String, double>> fetchPrices() async {
  final uri = Uri.https('api.coingecko.com', '/api/v3/simple/price', {
    'ids': _coins.keys.join(','),
    'vs_currencies': 'usd',
  });
  final r = await http.get(uri);
  if (r.statusCode != 200) throw Exception('Error ${r.statusCode}');
  final data = jsonDecode(r.body) as Map<String, dynamic>;
  return {for (final k in _coins.keys) k: (data[k]['usd'] as num).toDouble()};
}

class Reto4Cripto extends StatefulWidget {
  const Reto4Cripto({super.key});

  @override
  State<Reto4Cripto> createState() => _Reto4State();
}

class _Reto4State extends State<Reto4Cripto> {
  late Future<Map<String, double>> _future = fetchPrices();
  final _ctrl = TextEditingController(text: '100');

  double get _usd => double.tryParse(_ctrl.text.replaceAll(',', '.')) ?? 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cripto en tiempo real'), actions: [
        IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _future = fetchPrices())),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Monto en USD',
                  prefixText: '\$ ',
                  border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<Map<String, double>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }
                  final prices = snap.data!;
                  return ListView(
                    children: [
                      for (final e in _coins.entries)
                        Card(
                          child: ListTile(
                            title: Text(e.value),
                            subtitle: Text('Precio: \$${prices[e.key]!.toStringAsFixed(2)} USD'),
                            trailing: Text(
                              (_usd / prices[e.key]!).toStringAsFixed(8),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
