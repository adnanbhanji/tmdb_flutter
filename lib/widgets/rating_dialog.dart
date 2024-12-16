import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/movie.dart';

class RatingDialog extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final String? posterPath;
  final double? currentRating;
  final Map<String, dynamic> details;

  const RatingDialog({
    Key? key,
    required this.movieId,
    required this.movieTitle,
    this.posterPath,
    this.currentRating,
    required this.details,
  }) : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 5.0;

  @override
  void initState() {
    super.initState();
    if (widget.currentRating != null) {
      _rating = widget.currentRating!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rate ${widget.movieTitle}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _rating,
            min: 0,
            max: 10,
            divisions: 10,
            label: _rating.toString(),
            onChanged: (value) {
              setState(() {
                _rating = value;
              });
            },
          ),
          Text('Rating: ${_rating.toStringAsFixed(1)}/10'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final movie = Movie(
              id: widget.movieId,
              title: widget.movieTitle,
              posterPath: widget.posterPath,
              overview: widget.details['overview'],
              voteAverage: widget.details['vote_average'].toDouble(),
              releaseDate: widget.details['release_date'] ??
                  widget.details['first_air_date'],
              userRating: _rating,
            );
            context.read<AppState>().addToRatedMovies(movie);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
