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
  String _selectedType = 'movie';
  int _currentPage = 1;
  bool _isLoading = false;
  String _currentQuery = '';

  Future<void> _performSearch({bool resetResults = true}) async {
    if (_searchController.text.isEmpty) return;

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

      final formattedResults = results.map((item) {
        if (_selectedType == 'movie') {
          return Movie.fromJson(item);
        } else if (_selectedType == 'tv') {
          return TVShow.fromJson(item);
        }
        return item;
      }).toList();

      setState(() {
        if (resetResults) {
          _searchResults = formattedResults;
        } else {
          _searchResults.addAll(formattedResults);
        }
        _isLoading = false;
      });

      context.read<AppState>().addToRecentSearches(_currentQuery);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
      return GestureDetector(
        onTap: () => context.go('/person/${item['id']}'),
        child: Card(
          child: ListTile(
            leading: item['profile_path'] != null
                ? CachedNetworkImage(
                    imageUrl:
                        'https://image.tmdb.org/t/p/w200${item['profile_path']}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(Icons.person)),
                  )
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(item['name'] ?? 'Unknown'),
            subtitle: Text(item['known_for_department'] ?? ''),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          context.go('/${_selectedType}/${item.id}');
        },
        child: Card(
          child: Column(
            children: [
              if (item.posterPath != null)
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://image.tmdb.org/t/p/w500${item.posterPath}',
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _selectedType == 'tv' ? item.name : item.title,
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
