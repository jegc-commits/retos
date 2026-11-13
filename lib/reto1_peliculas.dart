import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Consigue tu API key gratis en https://www.themoviedb.org/settings/api
const tmdbApiKey = 'TU_API_KEY_TMDB';

class Movie {
  final String title;
  final String overview;
  final String? posterPath;
  final double rating;

  Movie.fromJson(Map<String, dynamic> j)
      : title = j['title'] ?? '',
        overview = j['overview'] ?? '',
        posterPath = j['poster_path'],
        rating = (j['vote_average'] ?? 0).toDouble();

  String? get posterUrl =>
      posterPath == null ? null : 'https://image.tmdb.org/t/p/w500$posterPath';
}

class TmdbService {
  Future<List<Movie>> _get(String path, Map<String, String> extra) async {
    final uri = Uri.https('api.themoviedb.org', path,
        {'api_key': tmdbApiKey, 'language': 'es-MX', ...extra});
    final r = await http.get(uri);
    if (r.statusCode != 200) throw Exception('Error ${r.statusCode}');
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return (data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<Movie>> trending() => _get('/3/trending/movie/week', {});

  Future<List<Movie>> byGenre(int genreId) => _get('/3/discover/movie',
      {'with_genres': '$genreId', 'sort_by': 'popularity.desc'});
}

class Reto1Peliculas extends StatefulWidget {
  const Reto1Peliculas({super.key});

  @override
  State<Reto1Peliculas> createState() => _Reto1State();
}

class _Reto1State extends State<Reto1Peliculas> {
  final _service = TmdbService();
  // estado de ánimo -> id de género de TMDB (null = tendencias)
  final _moods = <String, int?>{
    '😄 Feliz': 35,
    '😢 Triste': 18,
    '🤩 Emocionado': 28,
    '😱 Con miedo': 27,
    '😍 Romántico': 10749,
    '🔥 Tendencias': null,
  };
  String _mood = '🔥 Tendencias';
  List<Movie> _movies = [];
  Movie? _pick;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _pick = null;
    });
    try {
      final g = _moods[_mood];
      final res = g == null ? await _service.trending() : await _service.byGenre(g);
      setState(() => _movies = res);
    } catch (e) {
      setState(() => _error = 'No se pudo cargar: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _random() {
    if (_movies.isEmpty) return;
    setState(() => _pick = _movies[Random().nextInt(_movies.length)]);
  }

  @override
  Widget build(BuildContext context) {
    final shown = _pick != null ? [_pick!] : _movies;
    return Scaffold(
      appBar: AppBar(title: const Text('Película del fin de semana')),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (final m in _moods.keys)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: ChoiceChip(
                      label: Text(m),
                      selected: m == _mood,
                      onSelected: (_) {
                        _mood = m;
                        _load();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                  onPressed: _random,
                  icon: const Icon(Icons.casino),
                  label: const Text('Sorpréndeme')),
              const SizedBox(width: 8),
              if (_pick != null)
                TextButton(
                    onPressed: () => setState(() => _pick = null),
                    child: const Text('Ver lista')),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : ListView.builder(
                        itemCount: shown.length,
                        itemBuilder: (_, i) => MovieCard(movie: shown[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          movie.posterUrl != null
              ? Image.network(movie.posterUrl!,
                  width: 110,
                  height: 165,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                      width: 110, height: 165, child: Icon(Icons.broken_image)))
              : const SizedBox(width: 110, height: 165, child: Icon(Icons.movie)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' ${movie.rating.toStringAsFixed(1)}'),
                  ]),
                  const SizedBox(height: 6),
                  Text(movie.overview,
                      maxLines: 5, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
