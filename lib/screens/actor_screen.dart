import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class ActorScreen extends StatefulWidget {
  final int id;

  const ActorScreen({Key? key, required this.id}) : super(key: key);

  @override
  _ActorScreenState createState() => _ActorScreenState();
}

class _ActorScreenState extends State<ActorScreen> {
  final TMDBService _tmdbService = TMDBService();
  Map<String, dynamic>? _actorDetails;
  List<dynamic>? _credits;

  @override
  void initState() {
    super.initState();
    _loadActorDetails();
  }

  Future<void> _loadActorDetails() async {
    try {
      final details = await _tmdbService.getPersonDetails(widget.id);
      final credits = await _tmdbService.getPersonCredits(widget.id);
      setState(() {
        _actorDetails = details;
        _credits = credits;
      });
    } catch (e) {
      print('Error loading actor details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_actorDetails == null) {
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
              context.go('/'); // Fallback to home if can't pop
            }
          },
        ),
        title: Text(_actorDetails?['name'] ?? 'Actor Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_actorDetails!['profile_path'] != null)
              CachedNetworkImage(
                imageUrl:
                    'https://image.tmdb.org/t/p/w500${_actorDetails!['profile_path']}',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_actorDetails!['age'] != null)
                    Text('Age: ${_actorDetails!['age']}',
                        style: Theme.of(context).textTheme.titleMedium),
                  if (_actorDetails!['biography'] != null)
                    Text(_actorDetails!['biography'],
                        style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  const Text('Known For:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _credits?.take(5).length ?? 0,
                      itemBuilder: (context, index) {
                        final credit = _credits![index];
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              final type = credit['media_type'];
                              context.go('/$type/${credit['id']}');
                            },
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (credit['poster_path'] != null)
                                    CachedNetworkImage(
                                      imageUrl:
                                          'https://image.tmdb.org/t/p/w200${credit['poster_path']}',
                                      width: 140,
                                      height: 160,
                                      fit: BoxFit.cover,
                                    ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        credit['title'] ?? credit['name'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateAge(String? birthday) {
    if (birthday == null) return 0;
    final birthDate = DateTime.parse(birthday);
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
