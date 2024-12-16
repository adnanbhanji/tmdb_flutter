import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
        title: const Text('My Profile'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            children: [
              // Username Section
              ListTile(
                title: const Text('Username'),
                subtitle: Text(
                    appState.username.isEmpty ? 'Not set' : appState.username),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    final controller =
                        TextEditingController(text: appState.username);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Set Username'),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              appState.setUsername(controller.text);
                              Navigator.pop(context);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              // Settings Section
              ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: appState.isDarkMode,
                  onChanged: (value) => appState.toggleTheme(),
                ),
              ),
              ListTile(
                title: const Text('Language'),
                trailing: DropdownButton<String>(
                  value: appState.language,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                  ],
                  onChanged: (value) => appState.setLanguage(value!),
                ),
              ),
              const Divider(),
              // Streaming Services Section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Streaming Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: appState.streamingServices.map((service) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Image.asset(
                          service.logoPath,
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                        Switch(
                          value: service.isSubscribed,
                          onChanged: (bool value) {
                            appState.toggleStreamingService(service.id);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const Divider(),
              // Watchlist Section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'My Watchlist',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (appState.watchlist.isEmpty)
                const Center(child: Text('No movies in watchlist'))
              else
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: appState.watchlist.length,
                    itemBuilder: (context, index) {
                      final movie = appState.watchlist[index];
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => context.go('/movie/${movie.id}'),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (movie.posterPath != null)
                                  CachedNetworkImage(
                                    imageUrl:
                                        'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                    width: 140,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      movie.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
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
              const Divider(),
              // Rated Movies Section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Rated Movies',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (appState.ratedMovies.isEmpty)
                const Center(child: Text('No rated movies'))
              else
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: appState.ratedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = appState.ratedMovies[index];
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => context.go('/movie/${movie.id}'),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (movie.posterPath != null)
                                  CachedNetworkImage(
                                    imageUrl:
                                        'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                    width: 140,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          movie.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        if (movie.userRating != null)
                                          Text(
                                            'Rating: ${movie.userRating}/10',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
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
          );
        },
      ),
    );
  }
}
