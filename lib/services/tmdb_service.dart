import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';

class TMDBService {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    queryParameters: {'api_key': apiKey},
  ));

  Future<List<Movie>> getTrendingMovies() async {
    final response = await _dio.get('/trending/movie/day');
    return (response.data['results'] as List)
        .map((json) => Movie.fromJson(json))
        .toList();
  }

  Future<List<TVShow>> getTrendingTVShows() async {
    final response = await _dio.get('/trending/tv/day');
    return (response.data['results'] as List)
        .map((json) => TVShow.fromJson(json))
        .toList();
  }

  Future<List<dynamic>> search(String query, String type,
      {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/search/$type',
        queryParameters: {
          'query': query,
          'page': page,
        },
      );

      final results = response.data['results'] as List;

      // Debug print to check the data
      print('Search Results for $type:');
      results.forEach((item) {
        if (type == 'person') {
          print('Person: ${item['name']}, Profile: ${item['profile_path']}');
        } else {
          print(
              'Title: ${item['title'] ?? item['name']}, Poster: ${item['poster_path']}');
        }
      });

      return results;
    } catch (e) {
      print('Search Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    final response =
        await _dio.get('/movie/$movieId?append_to_response=credits');
    return response.data;
  }

  Future<Map<String, dynamic>> getTVShowDetails(int tvId) async {
    final response = await _dio.get('/tv/$tvId?append_to_response=credits');
    return response.data;
  }

  Future<Map<String, dynamic>> getPersonDetails(int personId) async {
    final response = await _dio.get('/person/$personId');
    final data = response.data;
    if (data['birthday'] != null) {
      final birthday = DateTime.parse(data['birthday']);
      final age = DateTime.now().difference(birthday).inDays ~/ 365;
      data['age'] = age;
    }
    return data;
  }

  Future<List<dynamic>> getPersonCredits(int personId) async {
    final response = await _dio.get('/person/$personId/combined_credits');
    return response.data['cast'];
  }

  Future<List<dynamic>> getCastMembers(int id, String type) async {
    final response = await _dio.get('/$type/$id/credits');
    return response.data['cast'];
  }

  Future<Map<String, dynamic>> getContentRatings(int id, String type) async {
    final response = await _dio.get('/$type/$id/content_ratings');
    return response.data;
  }

  Future<Map<String, dynamic>> getWatchProviders(int id, String type) async {
    final response = await _dio.get('/$type/$id/watch/providers');
    return response.data['results']['US'] ?? {};
  }

  Future<Map<String, dynamic>> getSeasonDetails(
      int showId, int seasonNumber) async {
    final response = await _dio.get('/tv/$showId/season/$seasonNumber');
    return response.data;
  }

  Future<Map<String, dynamic>> getStreamingProviders(
      String type, int id) async {
    try {
      final response = await _dio.get('/$type/$id/watch/providers');
      final results = response.data['results'];
      // Return US results if available, otherwise return empty map
      return results['US'] ?? {};
    } catch (e) {
      print('Error fetching streaming providers: $e');
      return {};
    }
  }

  Future<String?> getContentRating(int id, String type) async {
    try {
      if (type == 'movie') {
        final response = await _dio.get('/movie/$id/release_dates');
        final results = response.data['results'] as List;
        final usRating = results.firstWhere(
          (r) => r['iso_3166_1'] == 'US',
          orElse: () => null,
        );
        return usRating?['release_dates']?[0]?['certification'];
      } else {
        final response = await _dio.get('/tv/$id/content_ratings');
        final results = response.data['results'] as List;
        final usRating = results.firstWhere(
          (r) => r['iso_3166_1'] == 'US',
          orElse: () => null,
        );
        return usRating?['rating'];
      }
    } catch (e) {
      print('Error fetching content rating: $e');
      return null;
    }
  }
}
