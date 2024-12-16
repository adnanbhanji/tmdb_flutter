import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/actor_screen.dart';
import 'screens/season_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => appState,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) => DetailScreen(
          id: int.parse(state.pathParameters['id']!),
          type: 'movie',
        ),
      ),
      GoRoute(
        path: '/tv/:id',
        builder: (context, state) => DetailScreen(
          id: int.parse(state.pathParameters['id']!),
          type: 'tv',
        ),
      ),
      GoRoute(
        path: '/actor/:id',
        builder: (context, state) => ActorScreen(
          id: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/tv/:id/season/:seasonNumber',
        builder: (context, state) => SeasonScreen(
          showId: int.parse(state.pathParameters['id']!),
          seasonNumber: int.parse(state.pathParameters['seasonNumber']!),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'TMDB Movies',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: context.watch<AppState>().isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
    );
  }
}
