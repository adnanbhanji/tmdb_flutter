class TVShow {
  final int id;
  final String name;
  final String posterPath;
  final String overview;
  final double voteAverage;
  final String firstAirDate;
  final int numberOfSeasons;
  final int numberOfEpisodes;

  TVShow({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.overview,
    required this.voteAverage,
    required this.firstAirDate,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
  });

  factory TVShow.fromJson(Map<String, dynamic> json) {
    return TVShow(
      id: json['id'],
      name: json['name'],
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      firstAirDate: json['first_air_date'] ?? '',
      numberOfSeasons: json['number_of_seasons'] ?? 0,
      numberOfEpisodes: json['number_of_episodes'] ?? 0,
    );
  }
}
