import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';
import 'cached_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MediaGrid extends StatelessWidget {
  final List<dynamic> items;
  final Function()? onLoadMore;
  final bool isLoading;

  const MediaGrid({
    Key? key,
    required this.items,
    this.onLoadMore,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            onLoadMore != null &&
            !isLoading) {
          onLoadMore!();
        }
        return true;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: items.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final item = items[index];
          final posterPath = item is Movie
              ? item.posterPath
              : (item is TVShow ? item.posterPath : '');
          final title =
              item is Movie ? item.title : (item is TVShow ? item.name : '');

          return GestureDetector(
            onTap: () {
              if (item is Movie) {
                context.go('/movie/${item.id}');
              } else if (item is TVShow) {
                context.go('/tv/${item.id}');
              }
            },
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: 'https://image.tmdb.org/t/p/w500$posterPath',
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error_outline, size: 50),
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
        },
      ),
    );
  }
}
