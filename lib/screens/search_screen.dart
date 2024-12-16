import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/tmdb_service.dart';
import '../widgets/media_grid.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';
import 'package:go_router/go_router.dart';

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
                children: appState.recentSearches
                    .map((search) => Chip(
                          label: Text(search),
                          onDeleted: () {
                            // Add functionality to remove search
                          },
                        ))
                    .toList(),
              );
            },
          ),
          Expanded(
            child: MediaGrid(
              items: _searchResults,
              onLoadMore: _loadMore,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
