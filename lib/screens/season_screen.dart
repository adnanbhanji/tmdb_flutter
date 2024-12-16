import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import 'package:go_router/go_router.dart';

class SeasonScreen extends StatefulWidget {
  final int showId;
  final int seasonNumber;

  const SeasonScreen({
    Key? key,
    required this.showId,
    required this.seasonNumber,
  }) : super(key: key);

  @override
  _SeasonScreenState createState() => _SeasonScreenState();
}

class _SeasonScreenState extends State<SeasonScreen> {
  final TMDBService _tmdbService = TMDBService();
  Map<String, dynamic>? _seasonDetails;

  @override
  void initState() {
    super.initState();
    _loadSeasonDetails();
  }

  Future<void> _loadSeasonDetails() async {
    final details = await _tmdbService.getSeasonDetails(
      widget.showId,
      widget.seasonNumber,
    );
    setState(() {
      _seasonDetails = details;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_seasonDetails == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Season ${widget.seasonNumber}'),
      ),
      body: ListView.builder(
        itemCount: _seasonDetails!['episodes'].length,
        itemBuilder: (context, index) {
          final episode = _seasonDetails!['episodes'][index];
          return ListTile(
            title: Text(
                'Episode ${episode['episode_number']}: ${episode['name']}'),
            subtitle: Text(episode['overview']),
            onTap: () {
              // Navigate to episode details if needed
            },
          );
        },
      ),
    );
  }
}
