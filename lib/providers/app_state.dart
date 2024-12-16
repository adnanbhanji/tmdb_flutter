import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';
import '../models/streaming_service.dart';
import 'dart:convert';

class AppState extends ChangeNotifier {
  late SharedPreferences _prefs;
  String _username = '';
  bool _isDarkMode = false;
  String _language = 'en';
  List<String> _recentSearches = [];
  List<Movie> _watchlist = [];
  List<Movie> _ratedMovies = [];
  List<StreamingService> _streamingServices = [
    StreamingService(
      id: 'netflix',
      name: 'Netflix',
      logoPath: 'assets/images/Netflix.png',
    ),
    StreamingService(
      id: 'prime',
      name: 'Amazon Prime',
      logoPath: 'assets/images/apv.png',
    ),
    StreamingService(
      id: 'disney',
      name: 'Disney+',
      logoPath: 'assets/images/disney.webp',
    ),
  ];

  // Getters
  String get username => _username;
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  List<String> get recentSearches => _recentSearches;
  List<Movie> get watchlist => _watchlist;
  List<Movie> get ratedMovies => _ratedMovies;
  List<StreamingService> get streamingServices => _streamingServices;

  // Initialize from SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _username = _prefs.getString('username') ?? '';
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _language = _prefs.getString('language') ?? 'en';
    _recentSearches = _prefs.getStringList('recentSearches') ?? [];

    final watchlistJson = _prefs.getStringList('watchlist') ?? [];
    _watchlist =
        watchlistJson.map((json) => Movie.fromJson(jsonDecode(json))).toList();

    final ratedMoviesJson = _prefs.getStringList('ratedMovies') ?? [];
    _ratedMovies = ratedMoviesJson
        .map((json) => Movie.fromJson(jsonDecode(json)))
        .toList();

    final subscribedServices = _prefs.getStringList('subscribedServices') ?? [];
    for (var service in _streamingServices) {
      service.isSubscribed = subscribedServices.contains(service.id);
    }
    notifyListeners();
  }

  // Setters with persistence
  void setUsername(String username) {
    _username = username;
    _prefs.setString('username', username);
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void setLanguage(String language) {
    _language = language;
    _prefs.setString('language', language);
    notifyListeners();
  }

  void addToRecentSearches(String query) {
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) _recentSearches.removeLast();
      _prefs.setStringList('recentSearches', _recentSearches);
      notifyListeners();
    }
  }

  void toggleStreamingService(String id) {
    final index = _streamingServices.indexWhere((service) => service.id == id);
    if (index != -1) {
      _streamingServices[index].isSubscribed =
          !_streamingServices[index].isSubscribed;
      final subscribedServices = _streamingServices
          .where((service) => service.isSubscribed)
          .map((service) => service.id)
          .toList();
      _prefs.setStringList('subscribedServices', subscribedServices);
      notifyListeners();
    }
  }

  void addToWatchlist(Movie movie) {
    if (!_watchlist.any((m) => m.id == movie.id)) {
      _watchlist.add(movie);
      final watchlistJson =
          _watchlist.map((movie) => jsonEncode(movie.toJson())).toList();
      _prefs.setStringList('watchlist', watchlistJson);
      notifyListeners();
    }
  }

  void addToRatedMovies(Movie movie) {
    if (!_ratedMovies.any((m) => m.id == movie.id)) {
      _ratedMovies.add(movie);
      final ratedMoviesJson =
          _ratedMovies.map((movie) => jsonEncode(movie.toJson())).toList();
      _prefs.setStringList('ratedMovies', ratedMoviesJson);
      notifyListeners();
    }
  }

  void removeFromRecentSearches(String query) {
    _recentSearches.remove(query);
    notifyListeners();
    _saveRecentSearches();
  }

  void _saveRecentSearches() {
    _prefs.setStringList('recentSearches', _recentSearches);
  }

  void removeFromWatchlist(int movieId) {
    _watchlist.removeWhere((movie) => movie.id == movieId);
    final watchlistJson =
        _watchlist.map((movie) => jsonEncode(movie.toJson())).toList();
    _prefs.setStringList('watchlist', watchlistJson);
    notifyListeners();
  }

  void updateRating(Movie movie) {
    final index = _ratedMovies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      _ratedMovies[index] = movie;
    } else {
      _ratedMovies.add(movie);
    }
    final ratedMoviesJson =
        _ratedMovies.map((movie) => jsonEncode(movie.toJson())).toList();
    _prefs.setStringList('ratedMovies', ratedMoviesJson);
    notifyListeners();
  }
}
