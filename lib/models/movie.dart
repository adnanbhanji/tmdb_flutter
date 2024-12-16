class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? overview;
  final double voteAverage;
  final String? releaseDate;
  double? userRating;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.overview,
    required this.voteAverage,
    this.releaseDate,
    this.userRating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? '',
      posterPath: json['poster_path'],
      overview: json['overview'],
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['release_date'] ?? json['first_air_date'],
      userRating: json['user_rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'overview': overview,
      'vote_average': voteAverage,
      'release_date': releaseDate,
      'user_rating': userRating,
    };
  }
}
