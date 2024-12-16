import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state.dart';
import 'package:provider/provider.dart';
import '../widgets/streaming_providers.dart';
import '../widgets/rating_dialog.dart';
import '../models/movie.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final String type;

  const DetailScreen({
    Key? key,
    required this.id,
    required this.type,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TMDBService _tmdbService = TMDBService();
  Map<String, dynamic>? _details;
  Map<String, dynamic> _streamingProviders = {};
  String? _contentRating;

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _loadStreamingProviders();
    _loadContentRating();
  }

  Future<void> _loadDetails() async {
    final details = widget.type == 'movie'
        ? await _tmdbService.getMovieDetails(widget.id)
        : await _tmdbService.getTVShowDetails(widget.id);
    setState(() {
      _details = details;
    });
  }

  Future<void> _loadStreamingProviders() async {
    final providers =
        await _tmdbService.getStreamingProviders(widget.type, widget.id);
    setState(() {
      _streamingProviders = providers;
    });
  }

  Future<void> _loadContentRating() async {
    final rating = await _tmdbService.getContentRating(widget.id, widget.type);
    setState(() {
      _contentRating = rating;
    });
  }

  Widget _buildCastSection() {
    return FutureBuilder<List<dynamic>>(
      future: _tmdbService.getCastMembers(widget.id, widget.type),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final cast = snapshot.data!.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cast:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cast.length,
                itemBuilder: (context, index) {
                  final actor = cast[index];
                  return GestureDetector(
                    onTap: () => context.go('/actor/${actor['id']}'),
                    child: Card(
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                                'https://image.tmdb.org/t/p/w200${actor['profile_path']}',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                          Text(actor['name']),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPEGIInfo() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _tmdbService.getContentRatings(widget.id, widget.type),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final rating = widget.type == 'movie'
            ? snapshot.data!['results'].firstWhere(
                (r) => r['iso_3166_1'] == 'US',
                orElse: () => {'rating': 'N/A'})['rating']
            : 'TV-' +
                (snapshot.data!['results'].firstWhere(
                        (r) => r['iso_3166_1'] == 'US',
                        orElse: () => {'rating': 'N/A'})['rating'] ??
                    'N/A');

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.warning),
              const SizedBox(width: 8),
              Text('Rating: $rating'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdditionalInfo() {
    final director = _details!['credits']['crew']
        .firstWhere((crew) => crew['job'] == 'Director', orElse: () => null);
    final genres = (_details!['genres'] as List?)
        ?.map((genre) => genre['name'])
        .join(', ');
    final runtime =
        widget.type == 'movie' ? '${_details!['runtime']} min' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (director != null)
          Text('Director: ${director['name']}',
              style: Theme.of(context).textTheme.bodyMedium),
        if (genres != null)
          Text('Genres: $genres',
              style: Theme.of(context).textTheme.bodyMedium),
        if (runtime != null)
          Text('Duration: $runtime',
              style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildContentRating() {
    if (_contentRating == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _contentRating!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Content Rating'),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (_details == null) return const SizedBox.shrink();

    final appState = context.watch<AppState>();
    final isInWatchlist = appState.watchlist.any((m) => m.id == widget.id);
    final ratedMovie = appState.ratedMovies.firstWhere(
      (m) => m.id == widget.id,
      orElse: () => Movie(id: -1, title: '', voteAverage: 0),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: Icon(isInWatchlist ? Icons.bookmark : Icons.bookmark_border),
          label: Text(isInWatchlist ? 'In Watchlist' : 'Add to Watchlist'),
          onPressed: () {
            if (!isInWatchlist && _details != null) {
              final movie = Movie(
                id: widget.id,
                title: _details!['title'] ?? _details!['name'] ?? 'Unknown',
                posterPath: _details!['poster_path'],
                overview: _details!['overview'] ?? '',
                voteAverage: (_details!['vote_average'] ?? 0.0).toDouble(),
                releaseDate:
                    _details!['release_date'] ?? _details!['first_air_date'],
              );
              context.read<AppState>().addToWatchlist(movie);
            }
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.star),
          label: Text(ratedMovie.id != -1
              ? 'Your Rating: ${ratedMovie.userRating}/10'
              : 'Rate'),
          onPressed: () {
            if (_details != null) {
              showDialog(
                context: context,
                builder: (context) => RatingDialog(
                  movieId: widget.id,
                  movieTitle:
                      _details!['title'] ?? _details!['name'] ?? 'Unknown',
                  posterPath: _details!['poster_path'],
                  currentRating: ratedMovie.userRating,
                  details: _details!,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_details == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(_details!['title'] ?? _details!['name'] ?? 'Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl:
                  'https://image.tmdb.org/t/p/w500${_details!['poster_path']}',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error_outline),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _details!['overview'],
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  _buildAdditionalInfo(),
                  const SizedBox(height: 16),
                  Text(
                    'Release Date: ${_details!['release_date'] ?? _details!['first_air_date']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Rating: ${_details!['vote_average']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (widget.type == 'tv') ...[
                    Text(
                      'Seasons: ${_details!['number_of_seasons']}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Episodes: ${_details!['number_of_episodes']}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  _buildCastSection(),
                  _buildPEGIInfo(),
                  StreamingProviders(providers: _streamingProviders),
                  _buildContentRating(),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
