import 'package:flutter/material.dart';

class Reto2Gatos extends StatefulWidget {
  const Reto2Gatos({super.key});

  @override
  State<Reto2Gatos> createState() => _Reto2State();
}

class _Reto2State extends State<Reto2Gatos> {
  final _ctrl = TextEditingController();
  String _text = '';
  int _seed = DateTime.now().millisecondsSinceEpoch;

  // URL dinámica: /cat/says/<texto>?... ; el parámetro "t" evita que se cachee la misma imagen
  String get _url {
    final base = _text.trim().isEmpty
        ? 'https://cataas.com/cat'
        : 'https://cataas.com/cat/says/${Uri.encodeComponent(_text.trim())}';
    return '$base?fontSize=40&fontColor=white&t=$_seed';
  }

  void _apply() => setState(() => _seed = DateTime.now().millisecondsSinceEpoch);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memes de gatos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                  labelText: 'Escribe tu frase', border: OutlineInputBorder()),
              onChanged: (v) => _text = v,
              onSubmitted: (_) => _apply(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                    onPressed: _apply,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Nuevo gato / aplicar texto')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _url,
                  key: ValueKey(_url),
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, p) => p == null
                      ? child
                      : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Text('No se pudo cargar el gato 😿')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
