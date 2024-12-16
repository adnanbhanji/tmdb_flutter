import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/tmdb_service.dart';
import '../widgets/media_grid.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TMDBService _tmdbService = TMDBService();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _selectedType = 'movie';
  int _currentPage = 1;
  String _currentQuery = '';
  bool _mounted = true;

  @override
  void dispose() {
    _searchController.dispose();
    _mounted = false;
    super.dispose();
  }

  Future<void> _performSearch({bool resetResults = true}) async {
    if (_searchController.text.isEmpty) return;

    if (!_mounted) return; // Check if widget is still mounted

    setState(() {
      _isLoading = true;
      if (resetResults) {
        _searchResults = [];
        _currentPage = 1;
      }
      _currentQuery = _searchController.text;
    });

    try {
      final results = await _tmdbService.search(
        _currentQuery,
        _selectedType,
        page: _currentPage,
      );

      if (!_mounted) return; // Check again after async operation

      setState(() {
        if (resetResults) {
          _searchResults = results;
        } else {
          _searchResults.addAll(results);
        }
        _isLoading = false;
      });

      if (_mounted) {
        // Check before updating state
        context.read<AppState>().addToRecentSearches(_currentQuery);
      }
    } catch (e) {
      if (!_mounted) return;

      setState(() => _isLoading = false);
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _loadMore() {
    if (!_isLoading) {
      _currentPage++;
      _performSearch(resetResults: false);
    }
  }

  Widget _buildSearchResult(dynamic item) {
    if (_selectedType == 'person') {
      final profilePath = item['profile_path'];
      final name = item['name'] ?? 'Unknown';
      final department = item['known_for_department'] ?? '';

      return GestureDetector(
        onTap: () => context.go('/person/${item['id']}'),
        child: Card(
          child: ListTile(
            leading: (profilePath == null || profilePath == '')
                ? const CircleAvatar(child: Icon(Icons.person))
                : ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: 'https://image.tmdb.org/t/p/w200$profilePath',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const CircleAvatar(child: Icon(Icons.person)),
                      placeholder: (_, __) => const CircleAvatar(
                          child: CircularProgressIndicator()),
                    ),
                  ),
            title: Text(name),
            subtitle: Text(department),
          ),
        ),
      );
    } else {
      final posterPath = item['poster_path'];
      final title = _selectedType == 'tv'
          ? item['name'] ?? 'Unknown'
          : item['title'] ?? 'Unknown';

      return GestureDetector(
        onTap: () => context.go('/${_selectedType}/${item['id']}'),
        child: Card(
          child: Column(
            children: [
              Expanded(
                child: (posterPath == null || posterPath == '')
                    ? const Center(child: Icon(Icons.movie, size: 50))
                    : CachedNetworkImage(
                        imageUrl: 'https://image.tmdb.org/t/p/w500$posterPath',
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.movie, size: 50),
                        placeholder: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search movies, TV shows, or people...',
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: 'movie', child: Text('Movies')),
                    DropdownMenuItem(value: 'tv', child: Text('TV Shows')),
                    DropdownMenuItem(value: 'person', child: Text('People')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      if (_currentQuery.isNotEmpty) {
                        _performSearch();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          Consumer<AppState>(
            builder: (context, appState, child) {
              return Wrap(
                spacing: 8.0,
                children: appState.recentSearches
                    .map((search) => Chip(
                          label: GestureDetector(
                            onTap: () {
                              _searchController.text = search;
                              _performSearch();
                            },
                            child: Text(search),
                          ),
                          onDeleted: () {
                            appState.removeFromRecentSearches(search);
                          },
                        ))
                    .toList(),
              );
            },
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) =>
                  _buildSearchResult(_searchResults[index]),
            ),
          ),
        ],
      ),
    );
  }
}
